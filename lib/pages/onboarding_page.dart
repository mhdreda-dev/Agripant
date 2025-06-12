// onboarding_page.dart
import 'package:agriplant/ath/forgot_password_page.dart';
import 'package:agriplant/ath/register_page.dart';
import 'package:agriplant/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import '../pages/home_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final AuthService _authService = AuthService();

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe';
    }
    return null;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final user = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (user != null) {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        setState(() {
          _errorMessage = 'Email ou mot de passe incorrect';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildErrorMessage() {
    if (_errorMessage.isEmpty) return const SizedBox.shrink();
    return Container(
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
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            validator: _validateEmail,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              prefixIcon: const Icon(IconlyLight.message),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            validator: _validatePassword,
            obscureText: _obscureText,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: const Icon(IconlyLight.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? IconlyLight.show : IconlyLight.hide,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isLoading ? null : _login,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(IconlyLight.login),
            label: Text(_isLoading ? "Connection..." : "Login"),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 40,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Image.asset('assets/onboarding.png'),
                ),
                const SizedBox(height: 30),
                Text(
                  'Welcome to Agriplant',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 30),
                  child: Text(
                    "Get your agriculture products from the comfort of your home. You're just a few clicks away from your favorite products.",
                    textAlign: TextAlign.center,
                  ),
                ),
                _buildErrorMessage(),
                _buildLoginForm(),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 24),
                _buildButtons(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
