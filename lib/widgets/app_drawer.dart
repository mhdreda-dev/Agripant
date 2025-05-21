import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class AppDrawer extends StatelessWidget {
  final int currentPageIndex;
  final Function(int) onPageSelected;

  const AppDrawer({
    Key? key,
    required this.currentPageIndex,
    required this.onPageSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context),
          _buildDrawerItem(context, IconlyBold.home, 'Accueil', 0),
          _buildDrawerItem(context, IconlyBold.discovery, 'Explorer', 1),
          _buildDrawerItem(context, IconlyBold.call, 'Services', 2),
          _buildDrawerItem(context, IconlyBold.buy, 'Panier', 3),
          _buildDrawerItem(context, IconlyBold.profile, 'Profil', 4),
          const Divider(),
          _buildDrawerItem(context, IconlyBold.chat, 'Assistant IA', -1,
              onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/chat');
          }),
          _buildDrawerItem(context, IconlyBold.bookmark, 'Mes favoris', -1),
          _buildDrawerItem(context, IconlyBold.calendar, 'Mes rendez-vous', -1),
          _buildDrawerItem(context, IconlyBold.setting, 'Paramètres', -1),
          const Divider(),
          _buildDrawerItem(context, IconlyBold.logout, 'Déconnexion', -1,
              color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Colors.green.shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(45),
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset(
                'assets/profile.jpg',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      IconlyBold.profile,
                      size: 35,
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Mhd Reda',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Premium',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    int index, {
    Color? color,
    VoidCallback? onTap,
  }) {
    final isSelected = index == currentPageIndex;

    return ListTile(
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.green.shade50,
      onTap: onTap ??
          () {
            if (index >= 0) {
              onPageSelected(index);
            }
          },
    );
  }
}
