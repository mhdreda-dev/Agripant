import 'package:agriplant/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import '../pages/onboarding_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cityController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Validation des champs
    if (_emailController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _phoneNumberController.text.isEmpty ||
        !_agreeToTerms) {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs!';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Les mots de passe ne correspondent pas!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Simuler la vérification si le nom d'utilisateur ou l'email existe déjà
      bool usernameExists =
          await _mockUsernameExists(_usernameController.text.trim());
      if (usernameExists) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Ce nom d\'utilisateur existe déjà!';
        });
        return;
      }

      bool emailExists = await _mockEmailExists(_emailController.text.trim());
      if (emailExists) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Cet email est déjà utilisé!';
        });
        return;
      }

      // Création de l'utilisateur
      User newUser = User(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        email: _emailController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        city: _cityController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        name: '',
        userType: '',
      );

      // Simuler l'enregistrement de l'utilisateur
      bool isRegistered = await _mockRegisterUser(newUser);

      setState(() {
        _isLoading = false;
      });

      if (isRegistered) {
        // Naviguer directement vers OnboardingPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingPage()),
        );
      } else {
        setState(() {
          _errorMessage = 'Erreur lors de l\'enregistrement!';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur: ${e.toString()}';
      });
    }
  }

  // Simuler la vérification si le nom d'utilisateur existe
  Future<bool> _mockUsernameExists(String username) async {
    await Future.delayed(const Duration(seconds: 1)); // Simuler un délai réseau
    return false; // Remplacez par votre logique réelle
  }

  // Simuler la vérification si l'email existe
  Future<bool> _mockEmailExists(String email) async {
    await Future.delayed(const Duration(seconds: 1)); // Simuler un délai réseau
    return false; // Remplacez par votre logique réelle
  }

  // Simuler l'enregistrement de l'utilisateur
  Future<bool> _mockRegisterUser(User user) async {
    await Future.delayed(const Duration(seconds: 2)); // Simuler un délai réseau
    return true; // Retourne true si l'enregistrement est réussi
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Icon(
                  IconlyBold.user3,
                  size: 70,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Join Agriplant',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Create an account to get access to the best agricultural products',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Message d'erreur
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),

              const SizedBox(height: 10),

              // Contenu du formulaire
              // ...

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
