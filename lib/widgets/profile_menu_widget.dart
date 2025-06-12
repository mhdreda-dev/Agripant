// lib/widgets/profile_menu_widget.dart

import 'package:flutter/material.dart';

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.account_circle),
      onSelected: (String value) {
        switch (value) {
          case 'add_user':
            Navigator.pushNamed(context, '/addUser');
            break;
          case 'services':
            Navigator.pushNamed(context, '/services');
            break;
          case 'edit_profile':
            Navigator.pushNamed(context, '/editProfile');
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'add_user',
          child: Row(
            children: [
              Icon(Icons.person_add, color: Colors.blue),
              SizedBox(width: 8),
              Text('Ajouter un utilisateur'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'services',
          child: Row(
            children: [
              Icon(Icons.build, color: Colors.green),
              SizedBox(width: 8),
              Text('Gérer les services'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'edit_profile',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.orange),
              SizedBox(width: 8),
              Text('Éditer le profil'),
            ],
          ),
        ),
      ],
    );
  }
}

// Widget pour un drawer avec les options de profil
class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.green),
                ),
                SizedBox(height: 8),
                Text(
                  'Gestion des Profils',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_add, color: Colors.blue),
            title: const Text('Ajouter un utilisateur'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/addUser');
            },
          ),
          ListTile(
            leading: const Icon(Icons.build, color: Colors.green),
            title: const Text('Gérer les services'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/services');
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.orange),
            title: const Text('Éditer le profil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/editProfile');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Retour à l\'accueil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
