// auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<fb.User?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: userData['email'],
        password: userData['password'],
      );

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'username': userData['username'],
        'firstName': userData['firstName'],
        'lastName': userData['lastName'],
        'email': userData['email'],
        'phoneNumber': userData['phoneNumber'],
        'city': userData['city'],
        'userType': userData['userType'],
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<bool> resetPassword(String email, String trim) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<bool> emailExists(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> insertTestUser() async {
    // Optionnel : uniquement si tu veux créer un compte test
    try {
      await register({
        'username': 'testuser',
        'password': 'test1234',
        'email': 'test@example.com',
        'firstName': 'Test',
        'lastName': 'User',
        'phoneNumber': '0600000000',
        'city': 'Testville',
        'userType': 'customer',
      });
    } catch (_) {
      // Ignorer si déjà créé
    }
  }
}
