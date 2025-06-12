import 'package:agriplant/models/ProductSearchDelegate.dart';
import 'package:agriplant/pages/add_profile.dart';
import 'package:agriplant/pages/cartpage.dart';
import 'package:agriplant/pages/explore_page.dart';
import 'package:agriplant/pages/home_content.dart';
import 'package:agriplant/pages/profile_page.dart';
import 'package:agriplant/widgets/app_drawer.dart';
import 'package:agriplant/widgets/chat_fab.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import '../widgets/latest_products_modal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  static const List<Widget> _pages = [
    HomeContent(),
    ExplorePage(),
    ServicesPage(),
    CartPage(),
    ProfilePage(),
  ];

  static const List<_NavigationItem> _navigationItems = [
    _NavigationItem(
        icon: IconlyLight.home, activeIcon: IconlyBold.home, label: "Accueil"),
    _NavigationItem(
        icon: IconlyLight.discovery,
        activeIcon: IconlyBold.discovery,
        label: "Explorer"),
    _NavigationItem(
        icon: IconlyLight.addUser,
        activeIcon: IconlyBold.addUser,
        label: "Nouveau"),
    _NavigationItem(
        icon: IconlyLight.buy, activeIcon: IconlyBold.buy, label: "Panier"),
    _NavigationItem(
        icon: IconlyLight.profile,
        activeIcon: IconlyBold.profile,
        label: "Profil"),
  ];

  int _currentPageIndex = 0;
  late final GlobalKey<ScaffoldState> _scaffoldKey;
  late final AnimationController _fabAnimationController;
  late final Animation<double> _fabAnimation;

  String? _userName;
  bool _isLoadingUser = true;
  static const String _welcomeMessage = "Profitez de nos services";
  static const int _notificationCount = 3;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _initializeAnimations();
    _fetchUserData();
  }

  void _initializeAnimations() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    _fabAnimationController.forward();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _userName = doc.data()?['username'] ?? 'Utilisateur';
          _isLoadingUser = false;
        });
      } else {
        setState(() {
          _userName = 'Utilisateur';
          _isLoadingUser = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _navigateToPage(int index) {
    if (_isValidPageIndex(index) && index != _currentPageIndex) {
      setState(() {
        _currentPageIndex = index;
      });
      _fabAnimationController.reset();
      _fabAnimationController.forward();
    }
  }

  bool _isValidPageIndex(int index) {
    return index >= 0 && index < _pages.length;
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _openSearch() {
    showSearch(
      context: context,
      delegate: ProductSearchDelegate(),
    );
  }

  void _showLatestProducts() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => LatestProductsModal(
        onExploreAll: () {
          Navigator.pop(context);
          _navigateToPage(1);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      appBar: _buildAppBar(context),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_currentPageIndex],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildDrawer() {
    return AppDrawer(
      currentPageIndex: _currentPageIndex,
      onPageSelected: (index) {
        _navigateToPage(index);
        Navigator.pop(context);
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: false,
      leading: _buildAppBarButton(
        onPressed: _openDrawer,
        icon: Icons.menu,
        tooltip: 'Menu',
      ),
      title: _buildAppBarTitle(context),
      actions: _buildAppBarActions(),
    );
  }

  Widget _buildAppBarButton({
    required VoidCallback onPressed,
    required IconData icon,
    String? tooltip,
  }) {
    return IconButton.filledTonal(
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: Colors.grey.shade200,
        foregroundColor: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildAppBarTitle(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoadingUser) {
      return const CircularProgressIndicator();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hi ${_userName ?? ''} 👋️",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          _welcomeMessage,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      _buildAppBarButton(
        onPressed: _openSearch,
        icon: IconlyLight.search,
        tooltip: 'Rechercher',
      ),
      Padding(
        padding: const EdgeInsets.only(right: 8.0, left: 8.0),
        child: _buildNotificationButton(),
      ),
    ];
  }

  Widget _buildNotificationButton() {
    return IconButton.filledTonal(
      onPressed: _showLatestProducts,
      tooltip: 'Notifications',
      icon: badges.Badge(
        badgeContent: Text(
          _notificationCount.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: badges.BadgePosition.topEnd(top: -15, end: -12),
        badgeStyle: badges.BadgeStyle(
          badgeColor: Theme.of(context).primaryColor,
          elevation: 2,
        ),
        child: const Icon(IconlyBroken.notification),
      ),
      style: IconButton.styleFrom(
        backgroundColor: Colors.grey.shade200,
        foregroundColor: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _fabAnimation,
      child: const ChatFAB(),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: _buildBottomNavigationBarDecoration(),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentPageIndex,
        elevation: 0,
        backgroundColor: Colors.white,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 11,
        ),
        onTap: _navigateToPage,
        items: _navigationItems
            .map((item) => _buildBottomNavigationBarItem(item))
            .toList(),
      ),
    );
  }

  BoxDecoration _buildBottomNavigationBarDecoration() {
    return BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, -4),
          spreadRadius: 0,
        ),
      ],
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(16),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(_NavigationItem item) {
    return BottomNavigationBarItem(
      icon: Icon(item.icon),
      activeIcon: Icon(item.activeIcon),
      label: item.label,
      tooltip: item.label,
    );
  }
}

class _NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
