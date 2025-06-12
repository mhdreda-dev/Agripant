import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BuyerDashboardPage extends StatefulWidget {
  const BuyerDashboardPage({super.key});

  @override
  State<BuyerDashboardPage> createState() => _BuyerDashboardPageState();
}

class _BuyerDashboardPageState extends State<BuyerDashboardPage> {
  String? userSpecialty;
  String? userName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && mounted) {
          setState(() {
            userSpecialty = doc.data()?['profileOption'];
            userName =
                doc.data()?['displayName'] ?? user.displayName ?? 'Acheteur';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des données: $e')),
        );
      }
    }
  }

  // Nouvelle fonction pour naviguer vers la page d'accueil sans déconnexion
  Future<void> _navigateToHome() async {
    try {
      // Afficher un dialogue de confirmation
      final bool? shouldNavigate = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Retour à l\'accueil'),
            content: const Text(
                'Êtes-vous sûr de vouloir retourner à la page d\'accueil ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirmer'),
              ),
            ],
          );
        },
      );

      if (shouldNavigate == true) {
        // Navigation vers la page d'accueil SANS déconnexion
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home', // Utilise la route nommée
            (Route<dynamic> route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la navigation: $e')),
        );
      }
    }
  }

  // Fonction de déconnexion (optionnelle, si vous voulez la garder ailleurs)
  Future<void> _logout() async {
    try {
      // Afficher un dialogue de confirmation
      final bool? shouldLogout = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Déconnexion'),
            content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Déconnecter'),
              ),
            ],
          );
        },
      );

      if (shouldLogout == true) {
        // Déconnexion Firebase
        await FirebaseAuth.instance.signOut();

        // Navigation vers la page d'accueil
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home', // Utilise la route nommée
            (Route<dynamic> route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la déconnexion: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Acheteur'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.home), // Changé l'icône pour plus de clarté
            onPressed: _navigateToHome, // Utilise la nouvelle fonction
            tooltip: 'Retour à l\'accueil',
          ),
          // Optionnel: Garder un bouton de déconnexion séparé
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Déconnexion'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
                    Card(
                      color: Colors.orange.shade50,
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.orange,
                              radius: 25,
                              child: Icon(Icons.shopping_cart,
                                  color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bienvenue, ${userName ?? 'Acheteur'}!',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (userSpecialty != null)
                                    Text(
                                      'Type: $userSpecialty',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quick Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Commandes',
                            '5',
                            Icons.shopping_bag,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Fournisseurs',
                            '3',
                            Icons.store,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Main Actions
                    const Text(
                      'Actions Principales',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Actions Grid
                    SizedBox(
                      height:
                          400, // Hauteur fixe pour éviter les problèmes de layout
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _buildActionCard(
                            'Parcourir Produits',
                            Icons.search,
                            Colors.blue,
                            () {
                              // Navigate to products
                              Navigator.pushNamed(context, '/products');
                            },
                          ),
                          _buildActionCard(
                            'Mes Commandes',
                            Icons.shopping_bag_outlined,
                            Colors.orange,
                            () {
                              // Navigate to orders
                              Navigator.pushNamed(context, '/orders');
                            },
                          ),
                          _buildActionCard(
                            'Mes Fournisseurs',
                            Icons.store_outlined,
                            Colors.green,
                            () {
                              // Navigate to suppliers
                              Navigator.pushNamed(context, '/suppliers');
                            },
                          ),
                          _buildActionCard(
                            'Profil',
                            Icons.person_outline,
                            Colors.purple,
                            () {
                              // Navigate to profile
                              Navigator.pushNamed(context, '/profile');
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 48),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
