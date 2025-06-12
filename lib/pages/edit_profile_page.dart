import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();

  String? _selectedGender;
  String? _userType;
  File? _profileImage;
  String? _profileImageUrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data();
        _usernameController.text = data?['username'] ?? '';
        _emailController.text = data?['email'] ?? '';
        _firstNameController.text = data?['firstName'] ?? '';
        _lastNameController.text = data?['lastName'] ?? '';
        _phoneController.text = data?['phoneNumber'] ?? '';
        _cityController.text = data?['city'] ?? '';
        _selectedGender = data?['gender'];
        _userType = data?['userType'];
        _profileImageUrl = data?['profileImage'];
        setState(() {});
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    String? imageUrl = _profileImageUrl;

    if (_profileImage != null && user != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg');
      await ref.putFile(_profileImage!);
      imageUrl = await ref.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'username': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'city': _cityController.text.trim(),
      'gender': _selectedGender,
      'userType': _userType,
      'profileImage': imageUrl,
    });

    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil mis à jour')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le profil')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : (_profileImageUrl != null
                                    ? NetworkImage(_profileImageUrl!)
                                    : const AssetImage(
                                        'assets/profile.jpg')) as ImageProvider,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt),
                              onPressed: _pickImage,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _usernameController,
                      decoration:
                          const InputDecoration(labelText: 'Nom d’utilisateur'),
                      validator: (value) =>
                          value!.isEmpty ? 'Champ requis' : null,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) =>
                          value!.isEmpty ? 'Champ requis' : null,
                    ),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: 'Prénom'),
                    ),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Nom'),
                    ),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Téléphone'),
                    ),
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: 'Ville'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(labelText: 'Genre'),
                      items: const [
                        DropdownMenuItem(value: 'Homme', child: Text('Homme')),
                        DropdownMenuItem(value: 'Femme', child: Text('Femme')),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedGender = value),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _userType,
                      decoration: const InputDecoration(
                          labelText: 'Type d’utilisateur'),
                      items: const [
                        DropdownMenuItem(
                            value: 'farmer', child: Text('Agriculteur')),
                        DropdownMenuItem(
                            value: 'customer', child: Text('Client')),
                      ],
                      onChanged: (value) => setState(() => _userType = value),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Enregistrer les modifications'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
