import 'package:agriplant/ath/forgot_password_page.dart';
import 'package:agriplant/ath/register_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart' show IconlyLight;

import '../pages/home_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  String _errorMessage = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs';
      });
      return;
    }

    // Afficher le dialogue de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Simuler la logique de connexion (à remplacer par une vraie logique si nécessaire)
      final user = _mockAuthenticate(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      // Toujours fermer le dialogue de chargement
      Navigator.pop(context);

      if (user != null) {
        // Succès - naviguer vers la page d'accueil
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        // Échec - afficher un message d'erreur
        setState(() {
          _errorMessage = 'Nom d\'utilisateur ou mot de passe incorrect';
        });
      }
    } catch (e) {
      // Fermer le dialogue de chargement en cas d'erreur
      Navigator.pop(context);
      setState(() {
        _errorMessage = 'Erreur de connexion: ${e.toString()}';
      });
    }
  }

  // Méthode pour simuler l'authentification
  dynamic _mockAuthenticate(String username, String password) {
    // Remplacez cette logique par une vraie intégration avec une API ou une base de données
    if (username == 'test' && password == 'password') {
      return {'username': username};
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  40, // account for SafeArea padding
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Image.asset('assets/onboarding.png'),
                ),
                const SizedBox(height: 30),
                Text('Welcome to Agriplant',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 30),
                  child: Text(
                    "Get your agriculture products from the comfort of your home. You're just a few clicks away from your favorite products.",
                    textAlign: TextAlign.center,
                  ),
                ),
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
                // Username input field
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'Enter your username',
                    prefixIcon: const Icon(IconlyLight.profile),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Password input field
                TextField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(IconlyLight.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscureText ? IconlyLight.show : IconlyLight.hide),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Navigation vers la page de mot de passe oublié
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => const ForgotPasswordPage()),
                      );
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 24),
                // Login button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _login,
                    icon: const Icon(IconlyLight.login),
                    label: const Text("Login"),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Google login button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: () {
                      // Google login functionality
                      Navigator.of(context).pushReplacement(CupertinoPageRoute(
                          builder: (context) => const HomePage()));
                    },
                    icon: const Icon(IconlyLight.login),
                    label: const Text("Continue with Google"),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Register option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        // Navigation vers la page d'inscription
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => const RegisterPage()),
                        );
                      },
                      child: const Text('Register'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
