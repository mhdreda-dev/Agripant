// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agriplant/models/user_profile.dart';
import 'package:agriplant/models/product.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collections principales
  static const String usersCollection = 'users';
  static const String expertsCollection = 'experts';
  static const String farmersCollection = 'farmers';
  static const String buyersCollection = 'buyers';
  static const String productsCollection = 'products';
  static const String categoriesCollection = 'categories';
  static const String servicesCollection = 'services';
  static const String ordersCollection = 'orders';
  static const String reviewsCollection = 'reviews';

  // Références aux collections
  CollectionReference get _usersRef => _firestore.collection(usersCollection);
  CollectionReference get _expertsRef => _firestore.collection(expertsCollection);
  CollectionReference get _farmersRef => _firestore.collection(farmersCollection);
  CollectionReference get _buyersRef => _firestore.collection(buyersCollection);
  CollectionReference get _productsRef => _firestore.collection(productsCollection);
  CollectionReference get _categoriesRef => _firestore.collection(categoriesCollection);
  CollectionReference get _servicesRef => _firestore.collection(servicesCollection);
  CollectionReference get _ordersRef => _firestore.collection(ordersCollection);
  CollectionReference get _reviewsRef => _firestore.collection(reviewsCollection);

  // Référence à l'utilisateur actuel
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  // Stream pour écouter les changements d'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ===== GESTION DES PROFILS UTILISATEUR =====

  /// Récupérer le profil de l'utilisateur actuel
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      if (currentUserId == null) return null;

      final doc = await _usersRef.doc(currentUserId).get();

      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération du profil: $e');
      return null;
    }
  }

  /// Sauvegarder ou mettre à jour le profil utilisateur
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _usersRef
          .doc(profile.uid)
          .set(profile.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      print('Erreur lors de la sauvegarde du profil: $e');
      throw Exception('Impossible de sauvegarder le profil: $e');
    }
  }

  /// Vérifier si l'utilisateur a un profil complet
  Future<bool> isProfileComplete() async {
    try {
      final profile = await getCurrentUserProfile();
      return profile?.isProfileComplete == true;
    } catch (e) {
      print('Erreur lors de la vérification du profil: $e');
      return false;
    }
  }

  /// Stream pour écouter les changements du profil utilisateur
  Stream<UserProfile?> getUserProfileStream() {
    if (currentUserId == null) {
      return Stream.value(null);
    }

    return _usersRef
        .doc(currentUserId)
        .snapshots()
        .map((doc) => doc.exists ? UserProfile.fromFirestore(doc) : null);
  }

  // ===== GESTION DES PRODUITS =====

  /// Ajouter un nouveau produit à Firestore
  Future<String> addProduct(Product product) async {
    try {
      DocumentReference docRef = await _productsRef.add({
        'name': product.name,
        'description': product.description,
        'image': product.image,
        'price': product.price,
        'unit': product.unit,
        'rating': product.rating,
        'category': product.category,
        'isFeatured': product.isFeatured,
        'isFavorite': product.isFavorite,
        'sellerId': currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
      return docRef.id;
    } catch (e) {
      print('Erreur lors de l\'ajout du produit: $e');
      rethrow;
    }
  }

  /// Récupérer tous les produits depuis Firestore
  Future<List<Product>> getAllProducts() async {
    try {
      QuerySnapshot querySnapshot = await _productsRef
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Product.fromMap(data);
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des produits: $e');
      return [];
    }
  }

  /// Récupérer les produits par catégorie
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      QuerySnapshot querySnapshot = await _productsRef
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Product.fromMap(data);
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des produits par catégorie: $e');
      return [];
    }
  }

  /// Récupérer les produits en vedette
  Future<List<Product>> getFeaturedProducts() async {
    try {
      QuerySnapshot querySnapshot = await _productsRef
          .where('isFeatured', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .limit(10)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Product.fromMap(data);
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des produits en vedette: $e');
      return [];
    }
  }

  /// Mettre à jour un produit
  Future<void> updateProduct(String productId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _productsRef.doc(productId).update(updates);
    } catch (e) {
      print('Erreur lors de la mise à jour du produit: $e');
      rethrow;
    }
  }

  /// Supprimer un produit (soft delete)
  Future<void> deleteProduct(String productId) async {
    try {
      await _productsRef.doc(productId).update({
        'isActive': false,
        'deletedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur lors de la suppression du produit: $e');
      rethrow;
    }
  }

  /// Rechercher des produits par nom
  Future<List<Product>> searchProducts(String searchTerm) async {
    try {
      QuerySnapshot querySnapshot = await _productsRef
          .where('isActive', isEqualTo: true)
          .get();

      List<Product> allProducts = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Product.fromMap(data);
      }).toList();

      // Filtrer localement car Firestore ne supporte pas LIKE
      return allProducts.where((product) =>
      product.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
          product.description.toLowerCase().contains(searchTerm.toLowerCase())
      ).toList();
    } catch (e) {
      print('Erreur lors de la recherche de produits: $e');
      return [];
    }
  }

  /// Stream pour écouter les changements de produits en temps réel
  Stream<List<Product>> getProductsStream() {
    return _productsRef
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Product.fromMap(data);
      }).toList();
    });
  }

  // ===== GESTION DES EXPERTS =====

  /// Récupérer tous les experts actifs
  Future<List<Map<String, dynamic>>> getActiveExperts() async {
    try {
      final query = await _expertsRef
          .where('isActive', isEqualTo: true)
          .orderBy('rating', descending: true)
          .limit(20)
          .get();

      return query.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des experts: $e');
      return [];
    }
  }

  /// Récupérer les experts par spécialité
  Future<List<Map<String, dynamic>>> getExpertsBySpeciality(String speciality) async {
    try {
      final query = await _expertsRef
          .where('speciality', isEqualTo: speciality)
          .where('isActive', isEqualTo: true)
          .orderBy('rating', descending: true)
          .get();

      return query.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des experts par spécialité: $e');
      return [];
    }
  }

  // ===== GESTION DES AGRICULTEURS =====

  /// Récupérer tous les agriculteurs actifs
  Future<List<Map<String, dynamic>>> getActiveFarmers() async {
    try {
      final query = await _farmersRef
          .where('isActive', isEqualTo: true)
          .orderBy('rating', descending: true)
          .limit(20)
          .get();

      return query.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des agriculteurs: $e');
      return [];
    }
  }

  /// Récupérer les agriculteurs par méthode de culture
  Future<List<Map<String, dynamic>>> getFarmersByMethod(String method) async {
    try {
      final query = await _farmersRef
          .where('farmingMethods', arrayContains: method)
          .where('isActive', isEqualTo: true)
          .orderBy('rating', descending: true)
          .get();

      return query.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des agriculteurs par méthode: $e');
      return [];
    }
  }

  // ===== GESTION DES ACHETEURS =====

  /// Récupérer tous les acheteurs actifs
  Future<List<Map<String, dynamic>>> getActiveBuyers() async {
    try {
      final query = await _buyersRef
          .where('isActive', isEqualTo: true)
          .orderBy('rating', descending: true)
          .limit(20)
          .get();

      return query.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des acheteurs: $e');
      return [];
    }
  }

  /// Récupérer les acheteurs par type d'entreprise
  Future<List<Map<String, dynamic>>> getBuyersByBusinessType(String businessType) async {
    try {
      final query = await _buyersRef
          .where('businessType', isEqualTo: businessType)
          .where('isActive', isEqualTo: true)
          .orderBy('rating', descending: true)
          .get();

      return query.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des acheteurs par type: $e');
      return [];
    }
  }

  // ===== GESTION DES CATÉGORIES =====

  /// Récupérer toutes les catégories
  Future<List<String>> getCategories() async {
    try {
      QuerySnapshot querySnapshot = await _categoriesRef.get();
      return querySnapshot.docs.map((doc) =>
      (doc.data() as Map<String, dynamic>)['name'] as String
      ).toList();
    } catch (e) {
      print('Erreur lors de la récupération des catégories: $e');
      return [];
    }
  }

  /// Ajouter une catégorie
  Future<void> addCategory(String categoryName) async {
    try {
      await _categoriesRef.add({
        'name': categoryName,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur lors de l\'ajout de la catégorie: $e');
      rethrow;
    }
  }

  // ===== GESTION DES SERVICES =====

  /// Créer un nouveau service
  Future<String> createService(Map<String, dynamic> serviceData) async {
    try {
      serviceData['createdAt'] = FieldValue.serverTimestamp();
      serviceData['updatedAt'] = FieldValue.serverTimestamp();
      serviceData['providerId'] = currentUserId;

      final docRef = await _servicesRef.add(serviceData);

      return docRef.id;
    } catch (e) {
      print('Erreur lors de la création du service: $e');
      throw Exception('Impossible de créer le service: $e');
    }
  }

  /// Récupérer les services d'un utilisateur
  Future<List<Map<String, dynamic>>> getUserServices(String userId) async {
    try {
      final query = await _servicesRef
          .where('providerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des services utilisateur: $e');
      return [];
    }
  }

  /// Rechercher des services par catégorie
  Future<List<Map<String, dynamic>>> getServicesByCategory(String category) async {
    try {
      final query = await _servicesRef
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      return query.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      print('Erreur lors de la recherche de services: $e');
      return [];
    }
  }

  // ===== GESTION DES COMMANDES =====

  /// Créer une nouvelle commande
  Future<String> createOrder(Map<String, dynamic> orderData) async {
    try {
      orderData['createdAt'] = FieldValue.serverTimestamp();
      orderData['updatedAt'] = FieldValue.serverTimestamp();
      orderData['buyerId'] = currentUserId;
      orderData['status'] = 'pending';

      final docRef = await _ordersRef.add(orderData);

      return docRef.id;
    } catch (e) {
      print('Erreur lors de la création de la commande: $e');
      throw Exception('Impossible de créer la commande: $e');
    }
  }

  /// Récupérer les commandes d'un utilisateur
  Future<List<Map<String, dynamic>>> getUserOrders(String userId, {String? role}) async {
    try {
      Query query = _ordersRef;

      if (role == 'buyer') {
        query = query.where('buyerId', isEqualTo: userId);
      } else if (role == 'seller') {
        query = query.where('sellerId', isEqualTo: userId);
      } else {
        query = query.where('buyerId', isEqualTo: userId);
      }

      final result = await query
          .orderBy('createdAt', descending: true)
          .get();

      return result.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des commandes: $e');
      return [];
    }
  }

  /// Mettre à jour le statut d'une commande
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _ordersRef.doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur lors de la mise à jour de la commande: $e');
      throw Exception('Impossible de mettre à jour la commande: $e');
    }
  }

  // ===== GESTION DES AVIS =====

  /// Ajouter un avis
  Future<void> addReview(Map<String, dynamic> reviewData) async {
    try {
      reviewData['createdAt'] = FieldValue.serverTimestamp();
      reviewData['reviewerId'] = currentUserId;

      await _reviewsRef.add(reviewData);

      // Mettre à jour la note moyenne de l'utilisateur évalué
      await _updateUserRating(reviewData['reviewedUserId']);
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'avis: $e');
      throw Exception('Impossible d\'ajouter l\'avis: $e');
    }
  }

  /// Récupérer les avis d'un utilisateur
  Future<List<Map<String, dynamic>>> getUserReviews(String userId) async {
    try {
      final query = await _reviewsRef
          .where('reviewedUserId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      return query.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des avis: $e');
      return [];
    }
  }

  /// Mettre à jour la note moyenne d'un utilisateur
  Future<void> _updateUserRating(String userId) async {
    try {
      final reviews = await getUserReviews(userId);
      if (reviews.isEmpty) return;

      double totalRating = 0;
      for (var review in reviews) {
        totalRating += (review['rating'] as num).toDouble();
      }

      double averageRating = totalRating / reviews.length;

      // Mettre à jour dans la collection users
      await _usersRef.doc(userId).update({
        'rating': averageRating,
        'totalReviews': reviews.length,
      });

      // Mettre à jour dans les collections spécialisées
      final userDoc = await _usersRef.doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        String? profileType = userData['profileType'];

        String collection = '';
        switch (profileType) {
          case 'Expert':
            collection = expertsCollection;
            break;
          case 'Agriculteur':
            collection = farmersCollection;
            break;
          case 'Acheteur':
            collection = buyersCollection;
            break;
        }

        if (collection.isNotEmpty) {
          await _firestore.collection(collection).doc(userId).update({
            'rating': averageRating,
            'totalReviews': reviews.length,
          });
        }
      }
    } catch (e) {
      print('Erreur lors de la mise à jour de la note: $e');
    }
  }

  // ===== RECHERCHE ET FILTRES =====

  /// Recherche globale
  Future<List<Map<String, dynamic>>> globalSearch(String searchTerm) async {
    try {
      List<Map<String, dynamic>> results = [];

      // Recherche dans les utilisateurs
      final usersQuery = await _usersRef
          .where('displayName', isGreaterThanOrEqualTo: searchTerm)
          .where('displayName', isLessThan: searchTerm + 'z')
          .where('isActive', isEqualTo: true)
          .limit(10)
          .get();

      for (var doc in usersQuery.docs) {
        results.add({
          'id': doc.id,
          'type': 'user',
          ...doc.data() as Map<String, dynamic>,
        });
      }

      // Recherche dans les services
      final servicesQuery = await _servicesRef
          .where('title', isGreaterThanOrEqualTo: searchTerm)
          .where('title', isLessThan: searchTerm + 'z')
          .where('isActive', isEqualTo: true)
          .limit(10)
          .get();

      for (var doc in servicesQuery.docs) {
        results.add({
          'id': doc.id,
          'type': 'service',
          ...doc.data() as Map<String, dynamic>,
        });
      }

      return results;
    } catch (e) {
      print('Erreur lors de la recherche globale: $e');
      return [];
    }
  }

  // ===== GESTION DES STATISTIQUES =====

  /// Récupérer les statistiques de l'utilisateur
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      Map<String, dynamic> stats = {
        'totalOrders': 0,
        'completedOrders': 0,
        'totalServices': 0,
        'activeServices': 0,
        'totalProducts': 0,
        'activeProducts': 0,
        'totalReviews': 0,
        'averageRating': 0.0,
      };

      // Statistiques des commandes
      final orders = await getUserOrders(userId);
      stats['totalOrders'] = orders.length;
      stats['completedOrders'] = orders.where((order) => order['status'] == 'completed').length;

      // Statistiques des services
      final services = await getUserServices(userId);
      stats['totalServices'] = services.length;
      stats['activeServices'] = services.where((service) => service['isActive'] == true).length;

      // Statistiques des produits
      final productsQuery = await _productsRef
          .where('sellerId', isEqualTo: userId)
          .get();
      final products = productsQuery.docs;
      stats['totalProducts'] = products.length;
      stats['activeProducts'] = products.where((doc) =>
      (doc.data() as Map<String, dynamic>)['isActive'] == true
      ).length;

      // Statistiques des avis
      final reviews = await getUserReviews(userId);
      stats['totalReviews'] = reviews.length;

      if (reviews.isNotEmpty) {
        double totalRating = 0;
        for (var review in reviews) {
          totalRating += (review['rating'] as num).toDouble();
        }
        stats['averageRating'] = totalRating / reviews.length;
      }

      return stats;
    } catch (e) {
      print('Erreur lors de la récupération des statistiques: $e');
      return {};
    }
  }

  // ===== MÉTHODES UTILITAIRES =====

  /// Initialiser les données par défaut (catégories)
  Future<void> initializeDefaultCategories() async {
    try {
      final categories = ['Machines', 'Fruits', 'Outils', 'Semences',
        'Légumes', 'Engrais', 'Protection'];

      for (String category in categories) {
        QuerySnapshot existing = await _categoriesRef
            .where('name', isEqualTo: category)
            .get();

        if (existing.docs.isEmpty) {
          await addCategory(category);
        }
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation des catégories: $e');
    }
  }

  /// Migrer les produits locaux vers Firestore
  Future<void> migrateLocalProductsToFirestore(List<Product> localProducts) async {
    try {
      for (Product product in localProducts) {
        await addProduct(product);
      }
      print('Migration des produits terminée avec succès');
    } catch (e) {
      print('Erreur lors de la migration des produits: $e');
    }
  }

  /// Vérifier la connectivité et l'état de Firebase
  Future<bool> checkFirebaseConnection() async {
    try {
      await _firestore.collection('test').limit(1).get();
      return true;
    } catch (e) {
      print('Erreur de connexion Firebase: $e');
      return false;
    }
  }

  /// Nettoyer les données utilisateur lors de la déconnexion
  Future<void> cleanupUserData() async {
    try {
      if (currentUserId != null) {
        await _usersRef.doc(currentUserId).update({
          'lastSeen': FieldValue.serverTimestamp(),
          'isOnline': false,
        });
      }
    } catch (e) {
      print('Erreur lors du nettoyage des données: $e');
    }
  }

  /// Marquer l'utilisateur comme en ligne
  Future<void> markUserOnline() async {
    try {
      if (currentUserId != null) {
        await _usersRef.doc(currentUserId).update({
          'lastSeen': FieldValue.serverTimestamp(),
          'isOnline': true,
        });
      }
    } catch (e) {
      print('Erreur lors de la mise à jour du statut en ligne: $e');
    }
  }
}