import 'package:agriplant/models/ProductSearchDelegate.dart';
import 'package:agriplant/pages/explore_page.dart';
import 'package:agriplant/pages/home_content.dart';
import 'package:agriplant/pages/profile_page.dart';
import 'package:agriplant/pages/services_page.dart';
import 'package:agriplant/widgets/app_drawer.dart'; // Nouveau widget extrait
import 'package:agriplant/widgets/chat_fab.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import '../widgets/latest_products_modal.dart';
import 'CartPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> _pages = const [
    HomeContent(),
    ExplorePage(),
    ServicesPage(),
    CartPage(),
    ProfilePage(),
  ];

  int _currentPageIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _navigateToPage(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() {
        _currentPageIndex = index;
      });
    }
  }

  void _showLatestProducts() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
      drawer: AppDrawer(
        currentPageIndex: _currentPageIndex,
        onPageSelected: (index) {
          _navigateToPage(index);
          Navigator.pop(context);
        },
      ),
      appBar: _buildAppBar(),
      body: _pages[_currentPageIndex],
      floatingActionButton: const ChatFAB(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: false,
      leading: IconButton.filledTonal(
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        icon: const Icon(Icons.menu),
        style: IconButton.styleFrom(
          backgroundColor: Colors.grey.shade200,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hi Mhd Reda 👋🏾",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            "Profitez de nos services",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          )
        ],
      ),
      actions: [
        IconButton.filledTonal(
          onPressed: () {
            showSearch(
              context: context,
              delegate: ProductSearchDelegate(),
            );
          },
          icon: const Icon(IconlyLight.search),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade200,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0, left: 8.0),
          child: IconButton.filledTonal(
            onPressed: _showLatestProducts,
            icon: badges.Badge(
              badgeContent: const Text(
                '3',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              position: badges.BadgePosition.topEnd(top: -15, end: -12),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: Colors.green,
              ),
              child: const Icon(IconlyBroken.notification),
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentPageIndex,
        elevation: 8,
        backgroundColor: Colors.white,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        onTap: _navigateToPage,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(IconlyLight.home),
            label: "Accueil",
            activeIcon: Icon(IconlyBold.home),
          ),
          BottomNavigationBarItem(
            icon: Icon(IconlyLight.discovery),
            label: "Explorer",
            activeIcon: Icon(IconlyBold.discovery),
          ),
          BottomNavigationBarItem(
            icon: Icon(IconlyLight.addUser),
            label: "Neuveau",
            activeIcon: Icon(IconlyBold.addUser),
          ),
          BottomNavigationBarItem(
            icon: Icon(IconlyLight.buy),
            label: "Panier",
            activeIcon: Icon(IconlyBold.buy),
          ),
          BottomNavigationBarItem(
            icon: Icon(IconlyLight.profile),
            label: "Profil",
            activeIcon: Icon(IconlyBold.profile),
          ),
        ],
      ),
    );
  }
}
