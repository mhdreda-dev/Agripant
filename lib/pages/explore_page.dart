import 'package:agriplant/data/products.dart';
import 'package:agriplant/models/product.dart';
import 'package:agriplant/pages/addproductpage.dart';
import 'package:agriplant/pages/product_details_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class ProductService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache pour améliorer les performances
  static List<Map<String, dynamic>>? _cachedProducts;
  static DateTime? _lastFetchTime;
  static const Duration _cacheValidityDuration = Duration(minutes: 5);

  // Méthode optimisée pour récupérer les produits combinés
  static Future<List<Map<String, dynamic>>> getCombinedProducts({
    String selectedSource = "All",
    bool forceRefresh = false,
  }) async {
    // Vérifier le cache
    if (!forceRefresh &&
        _cachedProducts != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheValidityDuration) {
      return _filterBySource(_cachedProducts!, selectedSource);
    }

    List<Map<String, dynamic>> combinedProducts = [];

    try {
      // Charger les produits locaux
      final localProducts = products
          .map((product) => {
                'id': product.name.hashCode.toString(),
                'name': product.name,
                'price': product.price,
                'category': product.category,
                'image': product.image,
                'rating': product.rating,
                'unit': product.unit ?? 'kg',
                'source': 'local',
                'createdAt': DateTime.now(),
                'description': product.description ?? '',
                'isAvailable': true,
              })
          .toList();

      // Charger les produits Firebase
      final firebaseSnapshot = await _firestore
          .collection('produits')
          .orderBy('createdAt', descending: true)
          .get();

      final firebaseProducts = firebaseSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'price': (data['price'] ?? 0).toDouble(),
          'category': data['category'] ?? 'Autres',
          'image': data['image'] ?? '',
          'rating': (data['rating'] ?? 0).toDouble(),
          'unit': data['unit'] ?? 'kg',
          'description': data['description'] ?? '',
          'source': 'firebase',
          'createdAt': data['createdAt']?.toDate() ?? DateTime.now(),
          'isAvailable': data['isAvailable'] ?? true,
        };
      }).toList();

      combinedProducts.addAll(localProducts);
      combinedProducts.addAll(firebaseProducts);

      // Mettre à jour le cache
      _cachedProducts = combinedProducts;
      _lastFetchTime = DateTime.now();
    } catch (e) {
      print('Erreur lors du chargement des produits: $e');
      // En cas d'erreur, retourner au moins les produits locaux
      final localProducts = products
          .map((product) => {
                'id': product.name.hashCode.toString(),
                'name': product.name,
                'price': product.price,
                'category': product.category,
                'image': product.image,
                'rating': product.rating,
                'unit': product.unit ?? 'kg',
                'source': 'local',
                'createdAt': DateTime.now(),
              })
          .toList();
      combinedProducts = localProducts;
    }

    return _filterBySource(combinedProducts, selectedSource);
  }

  static List<Map<String, dynamic>> _filterBySource(
      List<Map<String, dynamic>> products, String selectedSource) {
    if (selectedSource == "All") return products;

    final sourceFilter = selectedSource == "Local" ? 'local' : 'national';
    return products.where((p) => p['source'] == sourceFilter).toList();
  }

  // Méthode pour invalider le cache
  static void invalidateCache() {
    _cachedProducts = null;
    _lastFetchTime = null;
  }
}

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  String _searchQuery = "";
  String _selectedCategory = "All";
  double? _minPrice;
  double? _maxPrice;
  String _sortBy = "Popularité";
  String _selectedSource = "All"; // "All", "Local", "Firebase"

  // Updated categories to match products data
  final List<String> _categories = [
    "All",
    "Machines",
    "Outils",
    "Semences",
    "Fruits",
    "Légumes",
    "Engrais",
    "Protection"
  ];

  // Source filter options
  final List<String> _sourceOptions = ["All", "Local", "national"];

  // Map category names to icons
  final Map<String, IconData> _categoryIcons = {
    "All": Icons.apps_rounded,
    "Machines": IconlyBold.work,
    "Outils": Icons.handyman_rounded,
    "Semences": Icons.grass_rounded,
    "Fruits": Icons.apple_rounded,
    "Légumes": Icons.eco_rounded,
    "Engrais": Icons.water_drop_rounded,
    "Protection": Icons.security_rounded,
  };

  // Sorting options
  final List<String> _sortOptions = [
    "Popularité",
    "Plus récent",
    "Prix: croissant",
    "Prix: décroissant",
    "Évaluation"
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {}); // Refresh the page
            await Future.delayed(const Duration(milliseconds: 1500));
          },
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: false,
                backgroundColor: Theme.of(context).primaryColor,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddProductPage()),
                      );
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Nos Produits",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Découvrez nos produits agricoles de qualité",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search and filter row
                      _buildSearchAndFilterRow(),

                      // Filter chips if filters are applied
                      if (_hasActiveFilters()) _buildActiveFiltersRow(),

                      // Source filter row
                      _buildSourceFilterRow(),

                      // Categories row
                      _buildCategoriesRow(),

                      // Products section with StreamBuilder
                      _buildProductsSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Check if any filters are active
  bool _hasActiveFilters() {
    return _minPrice != null ||
        _maxPrice != null ||
        _sortBy != "Popularité" ||
        _selectedSource != "All";
  }

  // Build source filter row
  Widget _buildSourceFilterRow() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 15),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _sourceOptions.length,
        itemBuilder: (context, index) {
          final source = _sourceOptions[index];
          final isSelected = source == _selectedSource;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSource = source;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isSelected ? Theme.of(context).primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  source == "All" ? "Tous" : source,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Convert local product to common format for consistent display
  Map<String, dynamic> _convertLocalProductToMap(dynamic localProduct) {
    return {
      'id': localProduct.name.hashCode.toString(), // Generate unique ID
      'name': localProduct.name,
      'price': localProduct.price,
      'category': localProduct.category,
      'image': localProduct.image,
      'rating': localProduct.rating,
      'unit': localProduct.unit ?? 'kg',
      'source': 'local',
      'createdAt': DateTime.now(),
    };
  }

  // Get combined products from both sources
  Future<List<Map<String, dynamic>>> _getCombinedProducts() async {
    List<Map<String, dynamic>> combinedProducts = [];

    // Add local products if needed
    if (_selectedSource == "All" || _selectedSource == "Local") {
      final localProducts = products
          .map((product) => _convertLocalProductToMap(product))
          .toList();
      combinedProducts.addAll(localProducts);
    }

    // Add Firebase products if needed
    if (_selectedSource == "All" || _selectedSource == "Firebase") {
      try {
        final firebaseSnapshot = await FirebaseFirestore.instance
            .collection('produits')
            .orderBy('createdAt', descending: true)
            .get();

        final firebaseProducts = firebaseSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? '',
            'price': (data['price'] ?? 0).toDouble(),
            'category': data['category'] ?? 'Autres',
            'image': data['image'] ?? '',
            'rating': (data['rating'] ?? 0).toDouble(),
            'unit': data['unit'] ?? 'kg',
            'source': 'national',
            'createdAt': data['createdAt']?.toDate() ?? DateTime.now(),
          };
        }).toList();

        combinedProducts.addAll(firebaseProducts);
      } catch (e) {
        print('Erreur lors du chargement des produits Firebase: $e');
      }
    }

    return _getFilteredProducts(combinedProducts);
  }

  // Get filtered products based on all criteria
  List<Map<String, dynamic>> _getFilteredProducts(
      List<Map<String, dynamic>> allProducts) {
    var filtered = allProducts.where((product) {
      // Filter by search
      final matchesSearch = _searchQuery.isEmpty ||
          product['name'].toLowerCase().contains(_searchQuery.toLowerCase());

      // Filter by category
      final matchesCategory = _selectedCategory == "All" ||
          product['category'] == _selectedCategory;

      // Filter by price range
      final matchesMinPrice =
          _minPrice == null || product['price'] >= _minPrice!;
      final matchesMaxPrice =
          _maxPrice == null || product['price'] <= _maxPrice!;

      return matchesSearch &&
          matchesCategory &&
          matchesMinPrice &&
          matchesMaxPrice;
    }).toList();

    // Sort products
    switch (_sortBy) {
      case "Popularité":
        filtered.sort((a, b) => (b['rating'] ?? 0).compareTo(a['rating'] ?? 0));
        break;
      case "Plus récent":
        filtered.sort((a, b) => (b['createdAt'] ?? DateTime.now())
            .compareTo(a['createdAt'] ?? DateTime.now()));
        break;
      case "Prix: croissant":
        filtered.sort((a, b) => (a['price'] ?? 0).compareTo(b['price'] ?? 0));
        break;
      case "Prix: décroissant":
        filtered.sort((a, b) => (b['price'] ?? 0).compareTo(a['price'] ?? 0));
        break;
      case "Évaluation":
        filtered.sort((a, b) => (b['rating'] ?? 0).compareTo(a['rating'] ?? 0));
        break;
    }

    return filtered;
  }

  // Reset all filters to default values
  void _resetFilters() {
    setState(() {
      _minPrice = null;
      _maxPrice = null;
      _sortBy = "Popularité";
      _selectedSource = "All";
      _minPriceController.clear();
      _maxPriceController.clear();
    });
  }

  Widget _buildSearchAndFilterRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Rechercher des produits...",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(15.0),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(
                      Radius.circular(99),
                    ),
                  ),
                  prefixIcon: Icon(IconlyLight.search,
                      color: Theme.of(context).primaryColor),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear,
                              color: Theme.of(context).primaryColor),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = "";
                            });
                          },
                        )
                      : null,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                color: _hasActiveFilters()
                    ? Theme.of(context).primaryColor.withOpacity(0.8)
                    : Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      _showFilterBottomSheet();
                    },
                    icon: const Icon(IconlyLight.filter, size: 22),
                    color: Colors.white,
                    constraints: const BoxConstraints(
                      minWidth: 50,
                      minHeight: 50,
                    ),
                  ),
                  if (_hasActiveFilters())
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFiltersRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (_minPrice != null || _maxPrice != null)
              _buildFilterTag(
                "Prix: ${_minPrice != null ? '${_minPrice!.toStringAsFixed(0)}MAD' : '0MAD'} - ${_maxPrice != null ? '${_maxPrice!.toStringAsFixed(0)}MAD' : '∞'}",
                () {
                  setState(() {
                    _minPrice = null;
                    _maxPrice = null;
                    _minPriceController.clear();
                    _maxPriceController.clear();
                  });
                },
              ),
            if (_sortBy != "Popularité")
              _buildFilterTag(
                "Tri: $_sortBy",
                () {
                  setState(() {
                    _sortBy = "Popularité";
                  });
                },
              ),
            if (_selectedSource != "All")
              _buildFilterTag(
                "Source: $_selectedSource",
                () {
                  setState(() {
                    _selectedSource = "All";
                  });
                },
              ),
            if (_hasActiveFilters())
              TextButton.icon(
                onPressed: _resetFilters,
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text("Effacer tout"),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTag(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 6, bottom: 6),
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: onRemove,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesRow() {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          final icon = _categoryIcons[category] ?? Icons.category;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 80,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category,
                    style: TextStyle(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getProductSectionTitle(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton.icon(
              onPressed: () {
                // Navigate to all products page
              },
              icon: const Icon(IconlyLight.arrowRight, size: 18),
              label: const Text("Voir tout"),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _getCombinedProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    children: [
                      Icon(Icons.error, size: 60, color: Colors.red.shade400),
                      const SizedBox(height: 16),
                      Text(
                        "Erreur de chargement",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextButton(
                        onPressed: () => setState(() {}),
                        child: const Text("Réessayer"),
                      ),
                    ],
                  ),
                ),
              );
            }

            final products = snapshot.data ?? [];

            if (products.isEmpty) {
              return _buildEmptyProductsMessage();
            }

            return GridView.builder(
              itemCount: products.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                return _buildEnhancedProductCard(products[index]);
              },
            );
          },
        ),
      ],
    );
  }

  // Get the title for the product section based on current filters
  String _getProductSectionTitle() {
    String title = "Tous les produits";

    if (_selectedCategory != "All") {
      title = "Produits $_selectedCategory";
    }

    if (_selectedSource != "All") {
      title += " ($_selectedSource)";
    }

    if (_sortBy != "Popularité") {
      title += " (tri: $_sortBy)";
    }

    return title;
  }

  Widget _buildEnhancedProductCard(Map<String, dynamic> product) {
    final isFirebaseProduct = product['source'] == 'firebase';

    return GestureDetector(
      onTap: () {
        if (isFirebaseProduct) {
          // Create Product object for Firebase products
          final productObj = Product(
            id: product['id'],
            name: product['name'],
            price: product['price'],
            category: product['category'],
            image: product['image'],
            rating: product['rating'],
            unit: product['unit'],
            description: '',
            isFeatured: true,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsPage(product: productObj),
            ),
          );
        } else {
          // For local products, find the original product object
          final originalProduct = products.firstWhere(
            (p) => p.name == product['name'],
            orElse: () => products.first,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsPage(product: originalProduct),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with favorite button and source badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: product['image'].isNotEmpty
                      ? (isFirebaseProduct
                          ? Image.network(
                              product['image'],
                              height: 130,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 130,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image, size: 40),
                                );
                              },
                            )
                          : Image.asset(
                              product['image'],
                              height: 130,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 130,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image, size: 40),
                                );
                              },
                            ))
                      : Container(
                          height: 130,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image, size: 40),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        IconlyLight.heart,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      onPressed: () {
                        // Add to favorites
                      },
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                // Source badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: isFirebaseProduct ? Colors.blue : Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isFirebaseProduct ? "FB" : "LC",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Category label
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      product['category'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Product details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${product['price'].toStringAsFixed(2)} ${isFirebaseProduct ? 'DH' : 'MAD'}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '/ ${product['unit']}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            product['rating'].toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyProductsMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(
              IconlyLight.bag,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "Aucun produit trouvé",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Essayez de modifier vos filtres ou votre recherche",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_hasActiveFilters())
              ElevatedButton.icon(
                onPressed: _resetFilters,
                icon: const Icon(Icons.refresh),
                label: const Text("Réinitialiser les filtres"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Filtres",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _minPrice = null;
                            _maxPrice = null;
                            _sortBy = "Popularité";
                            _minPriceController.clear();
                            _maxPriceController.clear();
                          });
                        },
                        child: const Text("Réinitialiser"),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price range section
                        Text(
                          "Fourchette de prix (MAD)",
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _minPriceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Prix minimum",
                                  hintText: "0",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixText: "MAD ",
                                ),
                                onChanged: (value) {
                                  setModalState(() {
                                    _minPrice = double.tryParse(value);
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _maxPriceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Prix maximum",
                                  hintText: "∞",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixText: "MAD ",
                                ),
                                onChanged: (value) {
                                  setModalState(() {
                                    _maxPrice = double.tryParse(value);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Sort by section
                        Text(
                          "Trier par",
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _sortOptions.map((option) {
                            final isSelected = option == _sortBy;
                            return FilterChip(
                              label: Text(option),
                              selected: isSelected,
                              onSelected: (selected) {
                                setModalState(() {
                                  _sortBy = option;
                                });
                              },
                              selectedColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.2),
                              checkmarkColor: Theme.of(context).primaryColor,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 32),

                        // Quick price filters
                        Text(
                          "Filtres rapides de prix",
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildQuickPriceFilter(
                                "Moins de 50 MAD", null, 50, setModalState),
                            _buildQuickPriceFilter(
                                "50 - 100 MAD", 50, 100, setModalState),
                            _buildQuickPriceFilter(
                                "100 - 200 MAD", 100, 200, setModalState),
                            _buildQuickPriceFilter(
                                "200 - 500 MAD", 200, 500, setModalState),
                            _buildQuickPriceFilter(
                                "Plus de 500 MAD", 500, null, setModalState),
                          ],
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Apply button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // Apply the filters to the main state
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Appliquer les filtres",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickPriceFilter(
      String label, double? min, double? max, StateSetter setModalState) {
    final isSelected = _minPrice == min && _maxPrice == max;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setModalState(() {
          if (selected) {
            _minPrice = min;
            _maxPrice = max;
            _minPriceController.text = min?.toString() ?? '';
            _maxPriceController.text = max?.toString() ?? '';
          } else {
            _minPrice = null;
            _maxPrice = null;
            _minPriceController.clear();
            _maxPriceController.clear();
          }
        });
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
