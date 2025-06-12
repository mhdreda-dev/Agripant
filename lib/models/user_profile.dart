// lib/models/user_profile.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String? profileType; // Expert, Agriculteur, Acheteur
  final String? profileOption; // Spécialité sélectionnée
  final String? description;
  final bool isProfileComplete;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final double rating;
  final int completedTasks;
  final String? location;
  final String? phoneNumber;
  final String? profileImageUrl;
  final bool isOnline;
  final DateTime? lastSeen;
  final List<String> languages;
  final Map<String, dynamic>? preferences;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.profileType,
    this.profileOption,
    this.description,
    this.isProfileComplete = false,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.rating = 0.0,
    this.completedTasks = 0,
    this.location,
    this.phoneNumber,
    this.profileImageUrl,
    this.isOnline = false,
    this.lastSeen,
    this.languages = const ['Français'],
    this.preferences,
  });

  /// Créer un UserProfile à partir d'un document Firestore
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      profileType: data['profileType'],
      profileOption: data['profileOption'],
      description: data['description'],
      isProfileComplete: data['isProfileComplete'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      completedTasks: data['completedTasks'] ?? 0,
      location: data['location'],
      phoneNumber: data['phoneNumber'],
      profileImageUrl: data['profileImageUrl'],
      isOnline: data['isOnline'] ?? false,
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
      languages: List<String>.from(data['languages'] ?? ['Français']),
      preferences: data['preferences'],
    );
  }

  /// Créer un UserProfile à partir d'un Map
  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      profileType: data['profileType'],
      profileOption: data['profileOption'],
      description: data['description'],
      isProfileComplete: data['isProfileComplete'] ?? false,
      createdAt: data['createdAt'] is DateTime
          ? data['createdAt']
          : (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt'] is DateTime
          ? data['updatedAt']
          : (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      completedTasks: data['completedTasks'] ?? 0,
      location: data['location'],
      phoneNumber: data['phoneNumber'],
      profileImageUrl: data['profileImageUrl'],
      isOnline: data['isOnline'] ?? false,
      lastSeen: data['lastSeen'] is DateTime
          ? data['lastSeen']
          : (data['lastSeen'] as Timestamp?)?.toDate(),
      languages: List<String>.from(data['languages'] ?? ['Français']),
      preferences: data['preferences'],
    );
  }

  /// Convertir en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'profileType': profileType,
      'profileOption': profileOption,
      'description': description,
      'isProfileComplete': isProfileComplete,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'rating': rating,
      'completedTasks': completedTasks,
      'location': location,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'languages': languages,
      'preferences': preferences,
    };
  }

  /// Convertir en Map simple
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'profileType': profileType,
      'profileOption': profileOption,
      'description': description,
      'isProfileComplete': isProfileComplete,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isActive': isActive,
      'rating': rating,
      'completedTasks': completedTasks,
      'location': location,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      'languages': languages,
      'preferences': preferences,
    };
  }

  /// Créer une copie avec des modifications
  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? profileType,
    String? profileOption,
    String? description,
    bool? isProfileComplete,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    double? rating,
    int? completedTasks,
    String? location,
    String? phoneNumber,
    String? profileImageUrl,
    bool? isOnline,
    DateTime? lastSeen,
    List<String>? languages,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profileType: profileType ?? this.profileType,
      profileOption: profileOption ?? this.profileOption,
      description: description ?? this.description,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      completedTasks: completedTasks ?? this.completedTasks,
      location: location ?? this.location,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      languages: languages ?? this.languages,
      preferences: preferences ?? this.preferences,
    );
  }

  /// Vérifier si le profil est valide
  bool get isValid {
    return uid.isNotEmpty && email.isNotEmpty && displayName.isNotEmpty;
  }

  /// Obtenir le nom d'affichage formaté
  String get formattedDisplayName {
    if (displayName.isNotEmpty) {
      return displayName;
    }
    return email.split('@').first;
  }

  /// Obtenir la description du profil ou une description par défaut
  String get profileDescription {
    if (description != null && description!.isNotEmpty) {
      return description!;
    }

    switch (profileType) {
      case 'Expert':
        return 'Expert en $profileOption';
      case 'Agriculteur':
        return 'Agriculteur spécialisé en $profileOption';
      case 'Acheteur':
        return 'Acheteur ($profileOption)';
      default:
        return 'Utilisateur AgriPlant';
    }
  }

  /// Obtenir l'icône du profil
  String get profileIcon {
    switch (profileType) {
      case 'Expert':
        return '🧑‍🏫';
      case 'Agriculteur':
        return '🌾';
      case 'Acheteur':
        return '🛒';
      default:
        return '👤';
    }
  }

  /// Obtenir le statut en ligne
  String get onlineStatus {
    if (isOnline) {
      return 'En ligne';
    } else if (lastSeen != null) {
      final difference = DateTime.now().difference(lastSeen!);
      if (difference.inMinutes < 5) {
        return 'À l\'instant';
      } else if (difference.inHours < 1) {
        return 'Il y a ${difference.inMinutes} min';
      } else if (difference.inDays < 1) {
        return 'Il y a ${difference.inHours}h';
      } else {
        return 'Il y a ${difference.inDays}j';
      }
    }
    return 'Hors ligne';
  }

  /// Obtenir la note formatée
  String get formattedRating {
    return rating > 0 ? '${rating.toStringAsFixed(1)} ⭐' : 'Pas encore noté';
  }

  /// Vérifier si l'utilisateur est un nouveau membre
  bool get isNewMember {
    final difference = DateTime.now().difference(createdAt);
    return difference.inDays <= 30;
  }

  /// Obtenir le niveau d'expérience basé sur les tâches complétées
  String get experienceLevel {
    if (completedTasks < 5) {
      return 'Débutant';
    } else if (completedTasks < 20) {
      return 'Intermédiaire';
    } else if (completedTasks < 50) {
      return 'Expérimenté';
    } else {
      return 'Expert';
    }
  }

  @override
  String toString() {
    return 'UserProfile(uid: $uid, email: $email, displayName: $displayName, profileType: $profileType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
