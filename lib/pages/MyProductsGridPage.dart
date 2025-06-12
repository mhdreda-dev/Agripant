import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class MyProductsGridPage extends StatefulWidget {
  const MyProductsGridPage({super.key});

  @override
  State<MyProductsGridPage> createState() => _MyProductsGridPageState();
}

class _MyProductsGridPageState extends State<MyProductsGridPage> {
  bool _isGridView = true;
  String _searchQuery = '';
  String _sortBy = 'createdAt';
  bool _sortDescending = true;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "Utilisateur non connecté",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_showAll ? "Tous les Produits" : "Mes Produits"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: _isGridView ? 'Vue liste' : 'Vue grille',
          ),
          IconButton(
            icon: Icon(_showAll ? Icons.person : Icons.public),
            onPressed: () => setState(() => _showAll = !_showAll),
            tooltip: _showAll ? 'Voir mes produits' : 'Voir tous les produits',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                switch (value) {
                  case 'name':
                  case 'price':
                  case 'createdAt':
                    _sortBy = value;
                    break;
                  case 'toggle_order':
                    _sortDescending = !_sortDescending;
                    break;
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'name',
                child: Text('Trier par nom'),
              ),
              const PopupMenuItem(
                value: 'price',
                child: Text('Trier par prix'),
              ),
              const PopupMenuItem(
                value: 'createdAt',
                child: Text('Trier par date'),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'toggle_order',
                child: Text(
                    _sortDescending ? 'Ordre croissant' : 'Ordre décroissant'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade50,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.white,
                filled: true,
              ),
              onChanged: (value) =>
                  setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildQuery(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          "Erreur: ${snapshot.error}",
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _showAll
                              ? Icons.public_off
                              : Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showAll
                              ? "Aucun produit disponible"
                              : "Vous n'avez pas encore de produits",
                          style:
                              const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        if (!_showAll) ...[
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/addProduct'),
                            icon: const Icon(Icons.add),
                            label: const Text('Ajouter un produit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                final products = _filterProducts(snapshot.data!.docs);

                if (products.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "Aucun résultat pour la recherche",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: _isGridView
                      ? _buildGridView(products, user.uid)
                      : _buildListView(products, user.uid),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addProduct');
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Stream<QuerySnapshot> _buildQuery(String userId) {
    Query query = FirebaseFirestore.instance.collection('produits');

    if (!_showAll) {
      query = query.where('uid', isEqualTo: userId);
    }

    return query.orderBy(_sortBy, descending: _sortDescending).snapshots();
  }

  List<DocumentSnapshot> _filterProducts(List<DocumentSnapshot> products) {
    if (_searchQuery.isEmpty) return products;

    return products.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final name = (data['name'] ?? '').toString().toLowerCase();
      final description = (data['description'] ?? '').toString().toLowerCase();
      final category = (data['category'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery) ||
          description.contains(_searchQuery) ||
          category.contains(_searchQuery);
    }).toList();
  }

  Widget _buildGridView(List<DocumentSnapshot> products, String currentUserId) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final doc = products[index];
        final data = doc.data() as Map<String, dynamic>;
        final name = data['name'] ?? 'Sans nom';
        final price = data['price']?.toString() ?? '0';
        final unit = data['unit'] ?? '';
        final quantity = data['quantity']?.toString() ?? '';
        final images = List<String>.from(data['images'] ?? []);
        final imageUrl = images.isNotEmpty ? images.first : null;
        final isOrganic = data['isOrganic'] ?? false;
        final isOwner = data['uid'] == currentUserId;

        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          child: InkWell(
            onTap: () => _showProductDetails(doc),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                        child: Container(
                          width: double.infinity,
                          child: imageUrl != null
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.broken_image,
                                          size: 40),
                                    );
                                  },
                                )
                              : Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image_not_supported,
                                      size: 40),
                                ),
                        ),
                      ),
                      if (isOrganic)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'BIO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      if (isOwner)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _editProduct(doc);
                              } else if (value == 'delete') {
                                _deleteProduct(doc);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 16),
                                    SizedBox(width: 8),
                                    Text('Modifier'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete,
                                        size: 16, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Supprimer',
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.more_vert, size: 16),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$price DH",
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (quantity.isNotEmpty && unit.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            "$quantity $unit",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListView(List<DocumentSnapshot> products, String currentUserId) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final doc = products[index];
        final data = doc.data() as Map<String, dynamic>;
        final name = data['name'] ?? 'Sans nom';
        final price = data['price']?.toString() ?? '0';
        final description = data['description'] ?? '';
        final unit = data['unit'] ?? '';
        final quantity = data['quantity']?.toString() ?? '';
        final images = List<String>.from(data['images'] ?? []);
        final imageUrl = images.isNotEmpty ? images.first : null;
        final isOrganic = data['isOrganic'] ?? false;
        final isOwner = data['uid'] == currentUserId;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 60,
                height: 60,
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported),
                      ),
              ),
            ),
            title: Row(
              children: [
                Expanded(child: Text(name)),
                if (isOrganic)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'BIO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "$price DH${quantity.isNotEmpty && unit.isNotEmpty ? ' - $quantity $unit' : ''}"),
                if (description.isNotEmpty)
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
              ],
            ),
            isThreeLine: description.isNotEmpty,
            trailing: isOwner
                ? PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editProduct(doc);
                      } else if (value == 'delete') {
                        _deleteProduct(doc);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Supprimer',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  )
                : null,
            onTap: () => _showProductDetails(doc),
          ),
        );
      },
    );
  }

  void _showProductDetails(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  data['name'] ?? 'Sans nom',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "${data['price']} DH",
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (data['description'] != null &&
                            data['description'].isNotEmpty) ...[
                          const Text('Description:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(data['description']),
                          const SizedBox(height: 12),
                        ],
                        if (data['category'] != null) ...[
                          Text('Catégorie: ${data['category']}'),
                          const SizedBox(height: 8),
                        ],
                        if (data['quantity'] != null &&
                            data['unit'] != null) ...[
                          Text('Quantité: ${data['quantity']} ${data['unit']}'),
                          const SizedBox(height: 8),
                        ],
                        if (data['location'] != null &&
                            data['location'].isNotEmpty) ...[
                          Text('Lieu: ${data['location']}'),
                          const SizedBox(height: 8),
                        ],
                        if (data['harvestDate'] != null &&
                            data['harvestDate'].isNotEmpty) ...[
                          Text('Date de récolte: ${data['harvestDate']}'),
                          const SizedBox(height: 8),
                        ],
                        if (data['isOrganic'] == true) ...[
                          const Text('✅ Produit biologique'),
                          const SizedBox(height: 8),
                        ],
                        if (data['isDeliveryAvailable'] == true) ...[
                          const Text('🚚 Livraison disponible'),
                          const SizedBox(height: 8),
                        ],
                      ],
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

  void _editProduct(DocumentSnapshot doc) {
    // Navigation vers la page d'édition
    Navigator.pushNamed(
      context,
      '/editProduct',
      arguments: doc.id,
    );
  }

  Future<void> _deleteProduct(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final productName = data['name'] ?? 'ce produit';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer "$productName" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Afficher un indicateur de chargement
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Supprimer les images du Storage
        final images = List<String>.from(data['images'] ?? []);
        for (final imageUrl in images) {
          try {
            await FirebaseStorage.instance.refFromURL(imageUrl).delete();
          } catch (e) {
            print('Erreur lors de la suppression de l\'image: $e');
          }
        }

        // Supprimer le document Firestore
        await doc.reference.delete();

        // Fermer l'indicateur de chargement
        if (mounted) Navigator.pop(context);

        // Afficher un message de succès
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$productName a été supprimé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Fermer l'indicateur de chargement
        if (mounted) Navigator.pop(context);

        // Afficher l'erreur
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
