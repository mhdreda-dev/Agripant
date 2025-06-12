import 'package:agriplant/pages/BuyerDashboardPage.dart';
import 'package:agriplant/pages/ExpertDashboardPage.dart';
import 'package:agriplant/pages/FarmerDashboardPage.dart';
import 'package:agriplant/pages/add_profile.dart' as profile;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RedirectBasedOnProfile extends StatelessWidget {
  const RedirectBasedOnProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Utilisateur non connecté → aller à la page de configuration
      return const profile.ServicesPage();
    }

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          // Aucun document Firestore → envoyer à ServicesPage
          return const profile.ServicesPage();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;

        if (data == null ||
            data['profileType'] == null ||
            data['isProfileComplete'] != true) {
          // Profil incomplet → rediriger vers la configuration
          return const profile.ServicesPage();
        }

        final String profileType = data['profileType'];

        // Rediriger selon le type de profil
        switch (profileType) {
          case 'Farmer':
            return const FarmerDashboardPage();
          case 'Expert':
            return const ExpertDashboardPage();
          case 'Buyer':
            return const BuyerDashboardPage();
          default:
            return const profile.ServicesPage();
        }
      },
    );
  }
}
