import 'package:agriplant/pages/onboarding_page.dart';
import 'package:agriplant/pages/orders_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

// Importer la nouvelle page d'édition de profil
import 'FarmerDashboardPage.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        centerTitle: true,
        elevation: 0,
      ),
      body: const _ProfileContent(),
    );
  }
}

class _ProfileContent extends StatefulWidget {
  const _ProfileContent();

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  String userName = "Mhd Reda";
  String userEmail = "Mhdreda@gmail.com";
  String? userPhone;
  String? userAddress;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _ProfileHeader(
          name: userName,
          email: userEmail,
        ),
        const SizedBox(height: 25),
        _buildProfileOptionsList(context),
        const SizedBox(height: 10),
        const _LogoutButton(),
      ],
    );
  }

  Widget _buildProfileOptionsList(BuildContext context) {
    final profileOptions = [
      ProfileOption(
        title: "Mes commandes",
        icon: IconlyBold.bag,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OrdersPage(),
            ),
          );
        },
      ),
      ProfileOption(
        title: "Dashboard",
        icon: IconlyBold.bag,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FarmerDashboardPage(),
            ),
          );
        },
      ),
      ProfileOption(
        title: "Paramètres",
        icon: IconlyBold.setting,
        onTap: () {},
      ),
      ProfileOption(
        title: "Mon profil",
        icon: IconlyBold.profile,
        onTap: () async {
          // Navigation vers la page d'édition du profil
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EditProfilePage(
                initialName: "John Doe",
                initialEmail: "john@example.com",
                userType: UserType.farmer, // Specify the user type here
                farmerProductTypes: "Maïs, Blé, Soja", // Farmer-specific fields
                farmerLandSize: 25.5,
              ),
            ),
          );

          // Mise à jour du profil si des données sont retournées
          if (result != null && mounted) {
            setState(() {
              userName = result['name'];
              userEmail = result['email'];
              userPhone = result['phone'];
              userAddress = result['address'];
            });
          }
        },
      ),
      ProfileOption(
        title: "À propos de nous",
        icon: IconlyBold.infoSquare,
        onTap: () {},
      ),
      ProfileOption(
        title: "Aide et support",
        icon: IconlyBold.chat,
        onTap: () {},
      ),
    ];

    return Column(
      children: profileOptions
          .map(
            (option) => ProfileOptionTile(
              title: option.title,
              icon: option.icon,
              onTap: option.onTap,
            ),
          )
          .toList(),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;

  const _ProfileHeader({
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileAvatar(colorScheme),
          const SizedBox(height: 15),
          Text(
            name,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            email,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(ColorScheme colorScheme) {
    return Hero(
      tag: 'profile-avatar',
      child: CircleAvatar(
        radius: 62,
        backgroundColor: colorScheme.primary,
        child: const CircleAvatar(
          radius: 60,
          backgroundImage: AssetImage('assets/profile.jpg'),
        ),
      ),
    );
  }
}

class ProfileOption {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  ProfileOption({required this.title, required this.icon, required this.onTap});
}

class ProfileOptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const ProfileOptionTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          leading: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
          trailing: const Icon(
            IconlyLight.arrowRight2,
            size: 20,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ElevatedButton.icon(
        onPressed: () => _handleLogout(context),
        icon: const Icon(IconlyBold.logout),
        label: const Text("Déconnexion"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade100,
          foregroundColor: Colors.red.shade700,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Ferme le dialogue
              // Navigation vers la page d'onboarding lors de la déconnexion
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const OnboardingPage(),
                ),
                (route) => false,
              );
            },
            child: const Text('Confirmer'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
