import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import '../services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isEmailSent = false;
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String _errorMessage = '';
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  // Dans une vraie application, ce code devrait être généré et envoyé par email
  // Pour l'exemple, nous utiliserons un code statique
  final String _verificationCode = '123456';
  String _userEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // Méthode pour envoyer le code de vérification
  Future<void> _sendVerificationCode() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez entrer votre adresse email';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Vérifier si l'email existe dans la base de données
      bool emailExists =
          await _authService.emailExists(_emailController.text.trim());

      setState(() {
        _isLoading = false;
      });

      if (emailExists) {
        // Stocker l'email de l'utilisateur pour la réinitialisation du mot de passe
        _userEmail = _emailController.text.trim();

        // Dans une vraie application, on enverrait un email avec un code
        // Pour l'exemple, nous passons simplement à l'écran suivant
        setState(() {
          _isEmailSent = true;
        });

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code de vérification envoyé à votre email'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Aucun compte associé à cet email';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur: ${e.toString()}';
      });
    }
  }

  // Méthode pour réinitialiser le mot de passe
  Future<void> _resetPassword() async {
    // Vérifier si le code est correct
    if (_otpController.text != _verificationCode) {
      setState(() {
        _errorMessage = 'Code de vérification incorrect';
      });
      return;
    }

    // Vérifier si les mots de passe correspondent
    if (_newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez entrer un nouveau mot de passe';
      });
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Les mots de passe ne correspondent pas';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Réinitialiser le mot de passe dans la base de données
      bool success = await _authService.resetPassword(
          _userEmail, _newPasswordController.text.trim());

      setState(() {
        _isLoading = false;
      });

      if (success) {
        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mot de passe réinitialisé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );

        // Retourner à la page de connexion
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
        setState(() {
          _errorMessage = 'Erreur lors de la réinitialisation du mot de passe';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        centerTitle: true,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Icon(
                IconlyBold.unlock,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 20),
              Text(
                !_isEmailSent
                    ? 'Reset Your Password'
                    : 'Enter Verification Code',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                !_isEmailSent
                    ? 'Enter your email address and we\'ll send you instructions to reset your password.'
                    : 'Enter the verification code sent to your email and create a new password.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

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

              if (!_isEmailSent) ...[
                // Email input
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter your email',
                    prefixIcon: const Icon(IconlyLight.message),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _sendVerificationCode,
                    icon: _isLoading
                        ? Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(2.0),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(IconlyLight.send),
                    label: Text(_isLoading ? "Sending..." : "Send Reset Link"),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ] else ...[
                // OTP input
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Verification Code',
                    hintText: 'Enter 6-digit code',
                    prefixIcon: const Icon(IconlyLight.shieldDone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // New password
                TextField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    hintText: 'Enter new password',
                    prefixIcon: const Icon(IconlyLight.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureNewPassword
                          ? IconlyLight.show
                          : IconlyLight.hide),
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm password
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Confirm new password',
                    prefixIcon: const Icon(IconlyLight.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword
                          ? IconlyLight.show
                          : IconlyLight.hide),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _resetPassword,
                    icon: _isLoading
                        ? Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(2.0),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(IconlyLight.tickSquare),
                    label:
                        Text(_isLoading ? "Processing..." : "Reset Password"),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
