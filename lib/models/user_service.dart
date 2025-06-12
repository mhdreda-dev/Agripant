import '../model/user_model.dart';

// Singleton pour la gestion des utilisateurs
class UserService {
  // Instance unique de la classe
  static final UserService _instance = UserService._internal();

  // Factory constructor pour retourner l'instance existante
  factory UserService() {
    return _instance;
  }

  // Constructeur privé
  UserService._internal();

  // Liste des utilisateurs (simulée pour le moment, à remplacer par une base de données)
  final List<User> _users = [];

  // Utilisateur actuellement connecté
  User? _currentUser;

  // Getters
  List<User> get users => List.unmodifiable(_users);
  User? get currentUser => _currentUser;

  // Méthode pour ajouter un nouvel utilisateur
  Future<bool> addUser(User user) async {
    try {
      // Vérifier si l'email existe déjà
      final existingUser =
          _users.where((u) => u.email == user.email).firstOrNull;
      if (existingUser != null) {
        return false; // Email déjà utilisé
      }

      // Simuler un délai réseau
      await Future.delayed(const Duration(milliseconds: 500));

      // Ajouter l'utilisateur
      _users.add(user);

      // Définir comme utilisateur courant
      _currentUser = user;

      return true;
    } catch (e) {
      print('Erreur lors de l\'ajout d\'un utilisateur: $e');
      return false;
    }
  }

  // Méthode pour mettre à jour un utilisateur existant
  Future<bool> updateUser(User updatedUser) async {
    try {
      // Simuler un délai réseau
      await Future.delayed(const Duration(milliseconds: 500));

      // Trouver l'index de l'utilisateur dans la liste
      final index = _users.indexWhere((user) => user.id == updatedUser.id);

      if (index >= 0) {
        // Mettre à jour l'utilisateur
        _users[index] = updatedUser;

        // Mettre à jour l'utilisateur courant si c'est lui qui a été modifié
        if (_currentUser?.id == updatedUser.id) {
          _currentUser = updatedUser;
        }

        return true;
      } else {
        return false; // Utilisateur non trouvé
      }
    } catch (e) {
      print('Erreur lors de la mise à jour d\'un utilisateur: $e');
      return false;
    }
  }

  // Méthode pour supprimer un utilisateur
  Future<bool> deleteUser(int userId) async {
    // Changed from String to int to match User.id type
    try {
      // Simuler un délai réseau
      await Future.delayed(const Duration(milliseconds: 500));

      // Trouver l'utilisateur à supprimer
      final index = _users.indexWhere((user) => user.id == userId);

      if (index >= 0) {
        // Si l'utilisateur courant est celui supprimé, le déconnecter
        if (_currentUser?.id == userId) {
          _currentUser = null;
        }
        _users.removeAt(index);
        return true;
      } else {
        return false; // Utilisateur non trouvé
      }
    } catch (e) {
      print('Erreur lors de la suppression d\'un utilisateur: $e');
      return false;
    }
  }

  // Méthode pour connecter un utilisateur (login)
  Future<bool> login(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        print('Login failed: Email or password is empty');
        return false;
      }

      // Simuler un délai réseau
      await Future.delayed(const Duration(milliseconds: 500));

      final user = _users
          .where((u) => u.email == email && u.password == password)
          .firstOrNull;

      if (user != null) {
        _currentUser = user;
        return true;
      }

      print('Login failed: Invalid credentials');
      return false;
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      return false;
    }
  }

  // Méthode pour déconnecter l'utilisateur courant (logout)
  void logout() {
    _currentUser = null;
  }
}
