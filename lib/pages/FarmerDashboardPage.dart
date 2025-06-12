import 'package:agriplant/pages/Edit_Profile_Page.dart';
import 'package:agriplant/pages/MyProductsPage.dart';
import 'package:agriplant/pages/home_page.dart';
import 'package:agriplant/pages/orders_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/experts_list_screen.dart';
import 'AddProductPage.dart';
import 'MyProductsGridPage.dart';

// Modèle pour les données utilisateur
class UserData {
  final String displayName;
  final String email;
  final String? profileOption;
  final String? description;
  final String? photoURL;

  UserData({
    required this.displayName,
    required this.email,
    this.profileOption,
    this.description,
    this.photoURL,
  });

  factory UserData.fromMap(Map<String, dynamic> data, String userEmail) {
    return UserData(
      displayName: data['displayName'] ?? 'Agriculteur',
      email: data['email'] ?? userEmail,
      profileOption: data['profileOption'],
      description: data['description'],
      photoURL: data['photoURL'],
    );
  }
}

// Modèle pour les statistiques
class DashboardStats {
  final int productsCount;
  final int ordersCount;
  final bool isLoading;
  final String? error;

  DashboardStats({
    this.productsCount = 0,
    this.ordersCount = 0,
    this.isLoading = false,
    this.error,
  });
}

class FarmerDashboardPage extends StatefulWidget {
  const FarmerDashboardPage({super.key});

  @override
  State<FarmerDashboardPage> createState() => _FarmerDashboardPageState();
}

class _FarmerDashboardPageState extends State<FarmerDashboardPage>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  // Constantes pour améliorer la maintenabilité
  static const int _recentActivityLimit = 3;
  static const double _cardElevation = 4.0;
  static const double _borderRadius = 12.0;

  Future<void> _signOut() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/Homepage', (route) => false);
      }
    } catch (e) {
      _showErrorSnackBar('Erreur de déconnexion: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    // Déclencher le refresh des StreamBuilders
    setState(() {});
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showFeatureComingSoon(String feature) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$feature - Fonctionnalité à venir'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/Homepage', (route) => false);
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScaffold();
        }

        if (snapshot.hasError) {
          return _buildErrorScaffold(snapshot.error.toString());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildNoDataScaffold();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final userData =
            UserData.fromMap(data, user.email ?? 'Email non disponible');

        return _buildDashboard(context, user, userData);
      },
    );
  }

  Widget _buildLoadingScaffold() {
    return const Scaffold(
      appBar: null,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScaffold(String error) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Agriculteur'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Une erreur est survenue',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _refreshData,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoDataScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Agriculteur'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Aucune donnée utilisateur trouvée'),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, User user, UserData userData) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(userData),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(userData),
              const SizedBox(height: 24),
              _buildStatsRow(user.uid),
              const SizedBox(height: 24),
              _buildExpertContactButton(),
              const SizedBox(height: 24),
              _buildSectionTitle("Actions rapides"),
              const SizedBox(height: 16),
              _buildActionGrid(),
              const SizedBox(height: 24),
              _buildRecentActivity(user.uid),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Dashboard Agriculteur'),
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      elevation: 2,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _isLoading ? null : _refreshData,
          tooltip: 'Actualiser',
        ),
        IconButton(
          icon: const Icon(Icons.logout), // ← Remplacé ici
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          },
          tooltip: 'Accueil',
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildDrawer(UserData userData) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(userData),
          if (userData.profileOption != null)
            _buildSpecialtyTile(userData.profileOption!),
          if (userData.description != null)
            _buildDescriptionTile(userData.description!),
          const Divider(),
          ..._buildDrawerMenuItems(),
          const Divider(),
          _buildHomeNavigationTile(),
          if (_isLoading) const LinearProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(UserData userData) {
    return UserAccountsDrawerHeader(
      decoration: const BoxDecoration(
        color: Colors.green,
        image: DecorationImage(
          image: AssetImage('assets/drawer_background.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.green, BlendMode.overlay),
        ),
      ),
      accountName: Text(
        userData.displayName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      accountEmail: Text(userData.email),
      currentAccountPicture: _buildProfileAvatar(userData.photoURL, radius: 20),
    );
  }

  Widget _buildProfileAvatar(String? photoURL, {double radius = 30}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      child: photoURL != null
          ? ClipOval(
              child: Image.network(
                photoURL,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.person, size: radius, color: Colors.green);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    width: radius * 2,
                    height: radius * 2,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
            )
          : Icon(Icons.person, size: radius, color: Colors.green),
    );
  }

  Widget _buildSpecialtyTile(String specialty) {
    return ListTile(
      leading: const Icon(Icons.category, color: Colors.green),
      title: Text("Spécialité : $specialty"),
      dense: true,
    );
  }

  Widget _buildDescriptionTile(String description) {
    return ListTile(
      leading: const Icon(Icons.description, color: Colors.green),
      title: const Text("Description"),
      subtitle: Text(
        description,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      dense: true,
    );
  }

  List<Widget> _buildDrawerMenuItems() {
    final menuItems = [
      DrawerMenuItem(
        icon: Icons.edit,
        title: "Modifier mon profil",
        color: Colors.blue,
        onTap: () => _navigateToPage(const EditProfilePage()),
      ),
      DrawerMenuItem(
        icon: Icons.settings,
        title: "Paramètres",
        color: Colors.grey,
        onTap: () {
          Navigator.pop(context);
          _showFeatureComingSoon("Paramètres");
        },
      ),
      DrawerMenuItem(
        icon: Icons.help_outline,
        title: "Aide et support",
        color: Colors.orange,
        onTap: () {
          Navigator.pop(context);
          _showFeatureComingSoon("Aide");
        },
      ),
    ];

    return menuItems
        .map((item) => ListTile(
              leading: Icon(item.icon, color: item.color),
              title: Text(item.title),
              onTap: item.onTap,
            ))
        .toList();
  }

  Widget _buildHomeNavigationTile() {
    return ListTile(
      leading: const Icon(Icons.home, color: Colors.green),
      title: const Text("Accueil"),
      onTap: () {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      },
    );
  }

  void _navigateToPage(Widget page) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Widget _buildWelcomeCard(UserData userData) {
    return Card(
      elevation: _cardElevation,
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildProfileAvatar(userData.photoURL),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bienvenue, ${userData.displayName} !",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  if (userData.profileOption != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      "Spécialité : ${userData.profileOption}",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    "Bonne journée de travail !",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
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

  Widget _buildStatsRow(String userId) {
    return Row(
      children: [
        Expanded(child: _buildProductsStatCard(userId)),
        const SizedBox(width: 16),
        Expanded(child: _buildOrdersStatCard(userId)),
      ],
    );
  }

  Widget _buildProductsStatCard(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('produits')
          .where('uid', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildStatCard(
            "Produits",
            "Err",
            Icons.eco,
            Colors.red,
            onTap: () =>
                _showErrorSnackBar("Erreur lors du chargement des produits"),
          );
        }

        if (!snapshot.hasData) {
          return _buildStatCard("Produits", "...", Icons.eco, Colors.green);
        }

        final count = snapshot.data!.docs.length.toString();
        return _buildStatCard(
          "Produits",
          count,
          Icons.eco,
          Colors.green,
          onTap: () => _navigateToPage(const MyProductsPage()),
        );
      },
    );
  }

  Widget _buildOrdersStatCard(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('commandes')
          .where('uid', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildStatCard(
            "Commandes",
            "Err",
            Icons.shopping_cart,
            Colors.red,
            onTap: () =>
                _showErrorSnackBar("Erreur lors du chargement des commandes"),
          );
        }

        if (!snapshot.hasData) {
          return _buildStatCard(
              "Commandes", "...", Icons.shopping_cart, Colors.orange);
        }

        final count = snapshot.data!.docs.length.toString();
        return _buildStatCard(
          "Commandes",
          count,
          Icons.shopping_cart,
          Colors.orange,
          onTap: () => _navigateToPage(const OrdersPage()),
        );
      },
    );
  }

  Widget _buildExpertContactButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.support_agent),
        label: const Text("Contacter un expert"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          elevation: 2,
        ),
        onPressed: () => _navigateToPage(const ExpertsListScreen()),
      ),
    );
  }

  Widget _buildActionGrid() {
    final actions = _getActionItems();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildActionCard(action);
      },
    );
  }

  List<ActionItem> _getActionItems() {
    return [
      ActionItem(
        title: "Mes Produits",
        icon: Icons.local_florist,
        color: Colors.green,
        onTap: () => _navigateToPage(const MyProductsPage()),
      ),
      ActionItem(
        title: "Commandes",
        icon: Icons.list_alt,
        color: Colors.orange,
        onTap: () => _navigateToPage(const OrdersPage()),
      ),
      ActionItem(
        title: "Statistiques",
        icon: Icons.bar_chart,
        color: Colors.blue,
        onTap: () => _showFeatureComingSoon("Statistiques"),
      ),
      ActionItem(
        title: "Profil",
        icon: Icons.person,
        color: Colors.purple,
        onTap: () => _navigateToPage(const EditProfilePage()),
      ),
      ActionItem(
        title: "Ajouter Produit",
        icon: Icons.add_box,
        color: Colors.teal,
        onTap: () => _navigateToPage(const AddProductPage()),
      ),
      ActionItem(
        title: "Voir Produits",
        icon: Icons.grid_view,
        color: Colors.indigo,
        onTap: () => _navigateToPage(const MyProductsGridPage()),
      ),
    ];
  }

  Widget _buildRecentActivity(String userId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Activité récente"),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('produits')
              .where('uid', isEqualTo: userId)
              .orderBy('dateCreation', descending: true)
              .limit(_recentActivityLimit)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorCard(
                  "Erreur lors du chargement de l'activité récente");
            }

            if (!snapshot.hasData) {
              return _buildLoadingCard();
            }

            if (snapshot.data!.docs.isEmpty) {
              return _buildEmptyActivityCard();
            }

            return Column(
              children: snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _buildActivityItem(data);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildEmptyActivityCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Aucune activité récente",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> data) {
    final productName = data['nom'] ?? 'Produit sans nom';
    final price = data['prix']?.toString() ?? '0';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: const Icon(Icons.eco, color: Colors.green),
        ),
        title: Text(productName),
        subtitle: Text('Prix: $price DH'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigation vers les détails du produit
          _showFeatureComingSoon("Détails du produit");
        },
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_borderRadius),
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
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(ActionItem action) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(_borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action.icon, color: action.color, size: 48),
              const SizedBox(height: 12),
              Text(
                action.title,
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

  @override
  void dispose() {
    super.dispose();
  }
}

// Modèles de données
class ActionItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  ActionItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class DrawerMenuItem {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
}
