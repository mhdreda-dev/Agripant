import 'dart:async';

import 'package:flutter/material.dart';

import '../data/products.dart' as local_products;
import '../models/product.dart';
import '../services/firebase_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Product>>? _productsSubscription;

  // Getters
  List<Product> get products => List.unmodifiable(_products);
  List<Product> get featuredProducts => List.unmodifiable(_featuredProducts);
  List<String> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialiser le provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await Future.wait([
        loadProducts(),
        loadCategories(),
      ]);
      await loadFeaturedProducts();
      _clearError();
    } catch (e) {
      _setError('Erreur lors de l\'initialisation: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Charger tous les produits depuis Firebase
  Future<void> loadProducts() async {
    try {
      final firebaseService = FirebaseService();
      final products = await firebaseService.getAllProducts();

      // Si aucun produit en base, migrer les produits locaux
      if (products.isEmpty) {
        await _migrateLocalProducts();
        _products = await firebaseService.getAllProducts();
      } else {
        _products = products;
      }

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des produits: $e');
      print('Erreur loadProducts: $e');

      // En cas d'erreur, utiliser les produits locaux comme fallback
      _products = local_products.products;
      notifyListeners();
    }
  }

  /// Charger les produits en vedette
  Future<void> loadFeaturedProducts() async {
    try {
      final firebaseService = FirebaseService();
      _featuredProducts = await firebaseService.getFeaturedProducts();
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des produits en vedette: $e');
      // Fallback avec les produits locaux
      _featuredProducts = _products.where((p) => p.isFeatured == true).toList();
      notifyListeners();
    }
  }

  /// Charger les catégories
  Future<void> loadCategories() async {
    try {
      final firebaseService = FirebaseService();
      _categories = await firebaseService.getCategories();

      // Si aucune catégorie en base, initialiser les catégories par défaut
      if (_categories.isEmpty) {
        await firebaseService.initializeDefaultCategories();
        _categories = await firebaseService.getCategories();
      }

      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des catégories: $e');
      // Catégories par défaut en cas d'erreur
      _categories = [
        'Machines',
        'Fruits',
        'Outils',
        'Semences',
        'Légumes',
        'Engrais',
        'Protection'
      ];
      notifyListeners();
    }
  }

  /// Récupérer les produits par catégorie
  Future<List<Product>> getProductsByCategory(String category) async {
    if (category.isEmpty) return [];

    try {
      final firebaseService = FirebaseService();
      return await firebaseService.getProductsByCategory(category);
    } catch (e) {
      print('Erreur lors de la récupération par catégorie: $e');
      return _products
          .where((p) => p.category.toLowerCase() == category.toLowerCase())
          .toList();
    }
  }

  /// Rechercher des produits
  Future<List<Product>> searchProducts(String searchTerm) async {
    if (searchTerm.trim().isEmpty) return _products;

    final cleanedTerm = searchTerm.trim().toLowerCase();

    try {
      final firebaseService = FirebaseService();
      return await firebaseService.searchProducts(cleanedTerm);
    } catch (e) {
      print('Erreur lors de la recherche: $e');
      // Recherche locale en cas d'erreur
      return _products
          .where((product) =>
              product.name.toLowerCase().contains(cleanedTerm) ||
              product.description.toLowerCase().contains(cleanedTerm) ||
              product.category.toLowerCase().contains(cleanedTerm))
          .toList();
    }
  }

  /// Ajouter un nouveau produit
  Future<bool> addProduct(Product product) async {
    if (product.name.trim().isEmpty) {
      _setError('Le nom du produit ne peut pas être vide');
      return false;
    }

    _setLoading(true);
    try {
      final firebaseService = FirebaseService();
      final productId = await firebaseService.addProduct(product);

      // Créer un nouveau produit avec l'ID généré
      final newProduct = Product(
        id: productId,
        name: product.name.trim(),
        description: product.description.trim(),
        image: product.image,
        price: product.price,
        unit: product.unit,
        rating: product.rating,
        category: product.category,
        isFeatured: product.isFeatured,
        isFavorite: product.isFavorite,
      );

      _products.insert(0, newProduct);

      // Mettre à jour les produits en vedette si nécessaire
      if (newProduct.isFeatured == true) {
        _featuredProducts.insert(0, newProduct);
      }

      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur lors de l\'ajout du produit: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Mettre à jour un produit
  Future<bool> updateProduct(
      String productId, Map<String, dynamic> updates) async {
    if (productId.isEmpty) {
      _setError('ID du produit invalide');
      return false;
    }

    try {
      final firebaseService = FirebaseService();
      await firebaseService.updateProduct(productId, updates);

      // Mettre à jour localement
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final currentProduct = _products[index];
        final updatedProduct = _updateProductFromMap(currentProduct, updates);
        _products[index] = updatedProduct;

        // Mettre à jour dans les produits en vedette si nécessaire
        final featuredIndex =
            _featuredProducts.indexWhere((p) => p.id == productId);
        if (featuredIndex != -1) {
          if (updatedProduct.isFeatured == true) {
            _featuredProducts[featuredIndex] = updatedProduct;
          } else {
            _featuredProducts.removeAt(featuredIndex);
          }
        } else if (updatedProduct.isFeatured == true) {
          _featuredProducts.add(updatedProduct);
        }

        notifyListeners();
      }

      _clearError();
      return true;
    } catch (e) {
      _setError('Erreur lors de la mise à jour: $e');
      return false;
    }
  }

  /// Supprimer un produit
  Future<bool> deleteProduct(String productId) async {
    if (productId.isEmpty) {
      _setError('ID du produit invalide');
      return false;
    }

    try {
      final firebaseService = FirebaseService();
      await firebaseService.deleteProduct(productId);

      _products.removeWhere((p) => p.id == productId);
      _featuredProducts.removeWhere((p) => p.id == productId);

      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur lors de la suppression: $e');
      return false;
    }
  }

  /// Basculer le statut favori d'un produit
  Future<bool> toggleFavorite(String productId) async {
    final product = getProductById(productId);
    if (product == null) return false;

    final updates = {'isFavorite': !product.isFavorite};
    return await updateProduct(productId, updates);
  }

  /// Basculer le statut vedette d'un produit
  Future<bool> toggleFeatured(String productId) async {
    final product = getProductById(productId);
    if (product == null) return false;

    final updates = {'isFeatured': !product.isFeatured};
    return await updateProduct(productId, updates);
  }

  /// Écouter les changements en temps réel
  void listenToProducts() {
    _productsSubscription?.cancel();
    final firebaseService = FirebaseService();
    _productsSubscription = firebaseService.getProductsStream().listen(
      (products) {
        _products = products;
        _featuredProducts =
            products.where((p) => p.isFeatured == true).toList();
        notifyListeners();
      },
      onError: (error) {
        _setError('Erreur temps réel: $error');
        print('Erreur stream products: $error');
      },
    );
  }

  /// Arrêter l'écoute des changements
  void stopListening() {
    _productsSubscription?.cancel();
    _productsSubscription = null;
  }

  /// Rafraîchir les données
  Future<void> refresh() async {
    _setLoading(true);
    try {
      await Future.wait([
        loadProducts(),
        loadFeaturedProducts(),
        loadCategories(),
      ]);
      _clearError();
    } catch (e) {
      _setError('Erreur lors de l\'actualisation: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Obtenir un produit par ID
  Product? getProductById(String id) {
    if (id.isEmpty) return null;

    try {
      return _products.firstWhere((product) => product.id == id);
    } on StateError {
      return null; // Aucun produit trouvé
    } catch (e) {
      print('Erreur getProductById: $e');
      return null;
    }
  }

  /// Obtenir les produits favoris
  List<Product> getFavoriteProducts() {
    return _products.where((p) => p.isFavorite == true).toList();
  }

  /// Obtenir le nombre de produits par catégorie
  Map<String, int> getProductCountByCategory() {
    final Map<String, int> counts = {};
    for (final product in _products) {
      final category = product.category;
      counts[category] = (counts[category] ?? 0) + 1;
    }
    return counts;
  }

  /// Obtenir les statistiques des produits
  Map<String, dynamic> getProductStatistics() {
    if (_products.isEmpty) {
      return {
        'total': 0,
        'featured': 0,
        'favorites': 0,
        'categories': 0,
        'averageRating': 0.0,
      };
    }

    final featuredCount = _products.where((p) => p.isFeatured == true).length;
    final favoritesCount = _products.where((p) => p.isFavorite == true).length;
    final categoriesCount = _products.map((p) => p.category).toSet().length;
    final totalRating =
        _products.fold<double>(0, (sum, p) => sum + (p.rating ?? 0));
    final averageRating = totalRating / _products.length;

    return {
      'total': _products.length,
      'featured': featuredCount,
      'favorites': favoritesCount,
      'categories': categoriesCount,
      'averageRating': double.parse(averageRating.toStringAsFixed(2)),
    };
  }

  /// Vérifier la connexion Firebase
  Future<bool> checkConnection() async {
    try {
      final firebaseService = FirebaseService();
      return await firebaseService.checkFirebaseConnection();
    } catch (e) {
      print('Erreur vérification connexion: $e');
      return false;
    }
  }

  /// Filtrer les produits par prix
  List<Product> filterProductsByPrice(double minPrice, double maxPrice) {
    return _products
        .where(
            (product) => product.price >= minPrice && product.price <= maxPrice)
        .toList();
  }

  /// Trier les produits
  List<Product> sortProducts(String sortBy, {bool ascending = true}) {
    final sortedProducts = List<Product>.from(_products);

    switch (sortBy.toLowerCase()) {
      case 'name':
        sortedProducts.sort((a, b) =>
            ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
        break;
      case 'price':
        sortedProducts.sort((a, b) => ascending
            ? a.price.compareTo(b.price)
            : b.price.compareTo(a.price));
        break;
      case 'rating':
        sortedProducts.sort((a, b) {
          final ratingA = a.rating ?? 0;
          final ratingB = b.rating ?? 0;
          return ascending
              ? ratingA.compareTo(ratingB)
              : ratingB.compareTo(ratingA);
        });
        break;
      case 'category':
        sortedProducts.sort((a, b) => ascending
            ? a.category.compareTo(b.category)
            : b.category.compareTo(a.category));
        break;
      default:
        break;
    }

    return sortedProducts;
  }

  // Méthodes utilitaires privées

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  /// Migrer les produits locaux vers Firebase
  Future<void> _migrateLocalProducts() async {
    try {
      final firebaseService = FirebaseService();
      await firebaseService
          .migrateLocalProductsToFirestore(local_products.products);
      print('Migration des produits locaux terminée avec succès');
    } catch (e) {
      print('Erreur lors de la migration: $e');
      rethrow;
    }
  }

  /// Mettre à jour un produit à partir d'une map
  Product _updateProductFromMap(
      Product currentProduct, Map<String, dynamic> updates) {
    return Product(
      id: currentProduct.id,
      name: updates['name']?.toString() ?? currentProduct.name,
      description:
          updates['description']?.toString() ?? currentProduct.description,
      image: updates['image']?.toString() ?? currentProduct.image,
      price: updates['price']?.toDouble() ?? currentProduct.price,
      unit: updates['unit']?.toString() ?? currentProduct.unit,
      rating: updates['rating']?.toDouble() ?? currentProduct.rating,
      category: updates['category']?.toString() ?? currentProduct.category,
      isFeatured: updates['isFeatured'] as bool? ?? currentProduct.isFeatured,
      isFavorite: updates['isFavorite'] as bool? ?? currentProduct.isFavorite,
    );
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    super.dispose();
  }
}
