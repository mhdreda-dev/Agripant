import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

final List<Map<String, dynamic>> latestProducts = [
  {
    'name': 'Engrais Bio Premium',
    'image': 'assets/images/fertilizer.png',
    'date': '25 Avr 2025',
    'isNew': true,
    'price': '45.99',
  },
  {
    'name': 'Semences de Maïs Hybride',
    'image': 'assets/images/corn_seeds.jpg',
    'date': '23 Avr 2025',
    'isNew': true,
    'price': '23.50',
  },
  {
    'name': 'Pesticide Naturel',
    'image': 'assets/images/pesticide.jpg',
    'date': '20 Avr 2025',
    'isNew': true,
    'price': '38.75',
  },
];

final List<Map<String, dynamic>> dailyPromotions = [
  {
    'title': 'Promo du Printemps',
    'description': '20% de réduction sur tous les outils de jardinage',
    'color': Colors.green.shade100,
    'icon': Icons.colorize,
  },
  {
    'title': 'Lot Économique',
    'description': 'Achetez 2 sacs d\'engrais, obtenez-en 1 gratuit',
    'color': Colors.orange.shade100,
    'icon': Icons.shopping_bag,
  },
  {
    'title': 'Livraison Offerte',
    'description': 'Pour toute commande supérieure à 50€ ce weekend',
    'color': Colors.blue.shade100,
    'icon': Icons.local_shipping,
  },
];

final List<Map<String, dynamic>> categories = [
  {
    'name': 'Seeds',
    'icon': IconlyBold.plus,
    'color': Colors.green.shade600,
    'bgColor': Colors.green.shade50,
  },
  {
    'name': 'Tools',
    'icon': IconlyBold.work,
    'color': Colors.orange.shade600,
    'bgColor': Colors.orange.shade50,
  },
  {
    'name': 'Fertilizers',
    'icon': IconlyBold.ticket,
    'color': Colors.blue.shade600,
    'bgColor': Colors.blue.shade50,
  },
  {
    'name': 'Pest Control',
    'icon': IconlyBold.shieldDone,
    'color': Colors.red.shade600,
    'bgColor': Colors.red.shade50,
  },
];

final List<Map<String, dynamic>> blogPosts = [
  {
    'title': 'Meilleures pratiques pour l\'irrigation',
    'date': '28 Avr 2025',
    'image': 'assets/images/blog1.jpg',
    'category': 'Irrigation',
  },
  {
    'title': 'Cultiver bio: quels avantages?',
    'date': '25 Avr 2025',
    'image': 'images/blog2.jpg',
    'isNew': true,
    'category': 'Bio',
  },
  {
    'title': 'Les semences de saison',
    'date': '20 Avr 2025',
    'image': 'assets/images/guerre-des-semences.jpg',
    'isNew': true,
    'category': 'Semences',
  },
];
