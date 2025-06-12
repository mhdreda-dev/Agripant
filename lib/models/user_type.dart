// Créez ce fichier: lib/models/user_type.dart

enum UserType {
  none,
  expert,
  farmer,
  buyer,
}

// Extension pour obtenir des propriétés utiles
extension UserTypeExtension on UserType {
  String get displayName {
    switch (this) {
      case UserType.expert:
        return 'Expert';
      case UserType.farmer:
        return 'Agriculteur';
      case UserType.buyer:
        return 'Acheteur';
      case UserType.none:
        return 'Aucun';
    }
  }

  String get description {
    switch (this) {
      case UserType.expert:
        return 'Vous conseillez et aidez les agriculteurs dans leurs pratiques.';
      case UserType.farmer:
        return 'Vous produisez et vendez des produits agricoles.';
      case UserType.buyer:
        return 'Vous achetez des produits agricoles pour consommation ou revente.';
      case UserType.none:
        return 'Veuillez sélectionner un type d\'utilisateur.';
    }
  }
}
