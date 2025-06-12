import 'dart:io';

import 'package:agriplant/services/auth_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:image_picker/image_picker.dart';

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
  final AuthService _authService = AuthService();

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

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

    String? profileImageUrl;

    try {
      if (_profileImage != null) {
        final userId = DateTime.now().millisecondsSinceEpoch.toString();
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('$userId.jpg');
        await ref.putFile(_profileImage!);
        profileImageUrl = await ref.getDownloadURL();
      }

      final success = await _authService.register({
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
        'username': _usernameController.text.trim(),
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phoneNumber': _phoneNumberController.text.trim(),
        'city': _cityController.text.trim(),
        'userType': 'customer',
        'profileImage': profileImageUrl,
      });

      setState(() => _isLoading = false);

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingPage()),
        );
      } else {
        setState(() {
          _errorMessage = 'L\'inscription a échoué. Veuillez réessayer.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur: \${e.toString()}';
      });
    }
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
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? Icon(Icons.person, size: 45, color: Colors.white)
                          : null,
                      backgroundColor: Colors.grey.shade400,
                    ),
                    IconButton(
                      icon: Icon(Icons.edit,
                          color: Theme.of(context).primaryColor),
                      onPressed: _pickImage,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
              TextField(
                controller: _emailController,
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        hintText: 'Enter your first name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        hintText: 'Enter your last name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  prefixIcon: const Icon(IconlyLight.call),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'City',
                  hintText: 'Enter your city',
                  prefixIcon: const Icon(IconlyLight.location),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(IconlyLight.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscurePassword ? IconlyLight.show : IconlyLight.hide),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Confirm your password',
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
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeToTerms = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      'I agree to the Terms and Conditions and Privacy Policy',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _register,
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
                      : const Icon(IconlyLight.addUser),
                  label: Text(
                      _isLoading ? "Creating Account..." : "Create Account"),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
