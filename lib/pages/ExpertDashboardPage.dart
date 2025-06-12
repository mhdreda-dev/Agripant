import 'package:agriplant/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ExpertDashboardPage extends StatefulWidget {
  const ExpertDashboardPage({super.key});

  @override
  State<ExpertDashboardPage> createState() => _ExpertDashboardPageState();
}

class _ExpertDashboardPageState extends State<ExpertDashboardPage>
    with SingleTickerProviderStateMixin {
  String? userSpecialty;
  String? userName;
  String? userEmail;
  String? userProfileImage;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Stats data
  int totalConsultations = 0;
  int totalClients = 0;
  int pendingRequests = 0;
  double rating = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _loadUserData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Load user profile data
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;

          // Load statistics
          await _loadStatistics(user.uid);

          setState(() {
            userSpecialty = userData['profileOption'];
            userName = userData['displayName'] ?? user.displayName ?? 'Expert';
            userEmail = userData['email'] ?? user.email;
            userProfileImage = userData['profileImage'];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _loadStatistics(String userId) async {
    try {
      // Load consultations count
      final consultationsQuery = await FirebaseFirestore.instance
          .collection('consultations')
          .where('expertId', isEqualTo: userId)
          .get();

      // Load clients count (unique users who had consultations)
      final clientsSet = <String>{};
      for (var doc in consultationsQuery.docs) {
        final clientId = doc.data()['clientId'] as String?;
        if (clientId != null) clientsSet.add(clientId);
      }

      // Load pending requests
      final pendingQuery = await FirebaseFirestore.instance
          .collection('consultations')
          .where('expertId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();

      // Load rating (mock data for now)
      final ratingsQuery = await FirebaseFirestore.instance
          .collection('ratings')
          .where('expertId', isEqualTo: userId)
          .get();

      double totalRating = 0;
      for (var doc in ratingsQuery.docs) {
        totalRating += (doc.data()['rating'] as num).toDouble();
      }

      setState(() {
        totalConsultations = consultationsQuery.docs.length;
        totalClients = clientsSet.length;
        pendingRequests = pendingQuery.docs.length;
        rating = ratingsQuery.docs.isEmpty
            ? 0
            : totalRating / ratingsQuery.docs.length;
      });
    } catch (e) {
      print('Error loading statistics: $e');
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirmer'),
              ),
            ],
          );
        },
      );

      if (shouldNavigate == true) {
        // Navigation vers la page d'accueil SANS déconnexion
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la navigation: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Fonction de déconnexion (gardée comme option dans le menu)
  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern AppBar with gradient
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1976D2),
                      Color(0xFF42A5F5),
                    ],
                  ),
                ),
              ),
            ),
            title: const Text(
              'Dashboard Expert',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_outlined,
                        color: Colors.white),
                    if (pendingRequests > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$pendingRequests',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  // Navigate to notifications
                },
              ),
              IconButton(
                icon: const Icon(Icons.home_outlined, color: Colors.white),
                onPressed: _navigateToHome,
                tooltip: 'Retour à l\'accueil',
              ),
              // Menu popup pour les options supplémentaires
              PopupMenuButton<String>(
                onSelected: (String value) {
                  if (value == 'logout') {
                    _handleLogout();
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
                child: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Enhanced Welcome Card
                          _buildWelcomeCard(),
                          const SizedBox(height: 24),

                          // Enhanced Stats Grid
                          _buildStatsGrid(),
                          const SizedBox(height: 24),

                          // Quick Actions Section
                          _buildQuickActionsSection(),
                          const SizedBox(height: 24),

                          // Recent Activity
                          _buildRecentActivitySection(),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Quick consultation action
        },
        backgroundColor: const Color(0xFF1976D2),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nouvelle Consultation',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.blue.shade100,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: userProfileImage != null
                    ? ClipOval(
                        child: Image.network(
                          userProfileImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenue, $userName!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (userSpecialty != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          userSpecialty!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (userEmail != null)
                      Text(
                        userEmail!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
              if (rating > 0)
                Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        ),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Note',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildEnhancedStatCard(
          'Consultations',
          totalConsultations.toString(),
          Icons.chat_bubble_outline,
          Colors.blue,
          '+12% ce mois',
        ),
        _buildEnhancedStatCard(
          'Clients',
          totalClients.toString(),
          Icons.people_outline,
          Colors.green,
          '+3 nouveaux',
        ),
        _buildEnhancedStatCard(
          'En Attente',
          pendingRequests.toString(),
          Icons.hourglass_empty,
          Colors.orange,
          'À traiter',
        ),
        _buildEnhancedStatCard(
          'Revenus',
          '2,450€',
          Icons.trending_up,
          Colors.purple,
          '+8% ce mois',
        ),
      ],
    );
  }

  Widget _buildEnhancedStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.05),
              color.withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Icon(
                  Icons.trending_up,
                  color: Colors.green,
                  size: 16,
                ),
              ],
            ),
            const Spacer(),
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
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.green.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions Rapides',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildEnhancedActionCard(
              'Mes Consultations',
              Icons.chat_bubble_outline,
              Colors.blue,
              () => _navigateToConsultations(),
            ),
            _buildEnhancedActionCard(
              'Mes Clients',
              Icons.people_outline,
              Colors.green,
              () => _navigateToClients(),
            ),
            _buildEnhancedActionCard(
              'Calendrier',
              Icons.calendar_today_outlined,
              Colors.orange,
              () => _navigateToCalendar(),
            ),
            _buildEnhancedActionCard(
              'Profil',
              Icons.person_outline,
              Colors.purple,
              () => _navigateToProfile(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnhancedActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.05),
                color.withOpacity(0.1),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activité Récente',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final activities = [
                {
                  'title': 'Nouvelle consultation avec Marie D.',
                  'subtitle': 'Il y a 2 heures',
                  'icon': Icons.chat_bubble_outline,
                  'color': Colors.blue,
                },
                {
                  'title': 'Rapport envoyé à Jean M.',
                  'subtitle': 'Il y a 5 heures',
                  'icon': Icons.description_outlined,
                  'color': Colors.green,
                },
                {
                  'title': 'Nouvelle évaluation reçue (5⭐)',
                  'subtitle': 'Hier',
                  'icon': Icons.star_outline,
                  'color': Colors.amber,
                },
              ];

              final activity = activities[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      (activity['color'] as Color).withOpacity(0.2),
                  child: Icon(
                    activity['icon'] as IconData,
                    color: activity['color'] as Color,
                    size: 20,
                  ),
                ),
                title: Text(
                  activity['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(activity['subtitle'] as String),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to activity details
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Navigation methods
  void _navigateToConsultations() {
    // TODO: Implement navigation to consultations page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigation vers les consultations'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToClients() {
    // TODO: Implement navigation to clients page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigation vers les clients'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToCalendar() {
    // TODO: Implement navigation to calendar page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigation vers le calendrier'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToProfile() {
    // TODO: Implement navigation to profile page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigation vers le profil'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
