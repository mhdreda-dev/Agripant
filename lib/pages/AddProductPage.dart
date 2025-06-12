import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:image_picker/image_picker.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController();
  final _harvestDateController = TextEditingController();

  String? _selectedCategory;
  String? _selectedUnit;
  bool _isOrganic = false;
  bool _isDeliveryAvailable = false;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final List<File> _productImages = [];

  final List<String> _categories = [
    'Fruits',
    'Légumes',
    'Céréales',
    'Produits laitiers',
    'Huiles',
    'Miel',
    'Épices',
    'Fruits secs',
    'Viande',
    'Volaille',
    'Œufs',
    'Autre',
  ];

  final List<String> _units = [
    'Kg',
    'g',
    'L',
    'ml',
    'Unité',
    'Boîte',
    'Sac',
    'Bouquet',
  ];

  Future<void> _pickProductImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _productImages.add(File(pickedFile.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _productImages.removeAt(index);
    });
  }

  Future<List<String>> _uploadImages(List<File> images, String uid) async {
    List<String> urls = [];
    for (var image in images) {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref =
          FirebaseStorage.instance.ref().child('produits/$uid/$fileName.jpg');
      await ref.putFile(image);
      final url = await ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Utilisateur non connecté");

      final imageUrls = await _uploadImages(_productImages, user.uid);

      await FirebaseFirestore.instance.collection('produits').add({
        'uid': user.uid,
        'name': _productNameController.text.trim(),
        'category': _selectedCategory,
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'quantity': double.parse(_quantityController.text.trim()),
        'unit': _selectedUnit,
        'isOrganic': _isOrganic,
        'isDeliveryAvailable': _isDeliveryAvailable,
        'location': _locationController.text.trim(),
        'harvestDate': _harvestDateController.text.trim(),
        'images': imageUrls,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produit ajouté avec succès")),
        );

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Produit ajouté'),
            content: const Text('Voulez-vous ajouter un autre produit ?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetForm();
                },
                child: const Text('Oui'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Non'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _productNameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _quantityController.clear();
    _locationController.clear();
    _harvestDateController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedUnit = null;
      _isOrganic = false;
      _isDeliveryAvailable = false;
      _productImages.clear();
    });
  }

  Future<void> _selectHarvestDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _harvestDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    _harvestDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter un produit")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildProductImageSection(),
            const SizedBox(height: 24),
            _buildTextField(
                "Nom du produit", _productNameController, IconlyLight.document),
            const SizedBox(height: 12),
            _buildDropdown("Catégorie", _categories, _selectedCategory,
                (val) => setState(() => _selectedCategory = val)),
            const SizedBox(height: 12),
            _buildTextField(
                "Description", _descriptionController, IconlyLight.paper,
                lines: 3),
            const SizedBox(height: 12),
            _buildRowFields(),
            const SizedBox(height: 12),
            _buildDropdown("Unité", _units, _selectedUnit,
                (val) => setState(() => _selectedUnit = val)),
            const SizedBox(height: 12),
            _buildTextField(
                "Date de récolte", _harvestDateController, IconlyLight.calendar,
                readOnly: true, onTap: _selectHarvestDate),
            const SizedBox(height: 12),
            _buildTextField("Lieu de production", _locationController,
                IconlyLight.location),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text("Produit biologique"),
              value: _isOrganic,
              onChanged: (val) => setState(() => _isOrganic = val),
            ),
            SwitchListTile(
              title: const Text("Livraison disponible"),
              value: _isDeliveryAvailable,
              onChanged: (val) => setState(() => _isDeliveryAvailable = val),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveProduct,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save),
              label:
                  Text(_isLoading ? "Ajout en cours..." : "Ajouter le produit"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Images du produit",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              InkWell(
                onTap: _pickProductImage,
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add_a_photo, size: 30),
                ),
              ),
              for (int i = 0; i < _productImages.length; i++)
                Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(_productImages[i]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeImage(i),
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.close, size: 16, color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {int lines = 1, bool readOnly = false, VoidCallback? onTap}) {
    return TextFormField(
      controller: controller,
      maxLines: lines,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Champ requis' : null,
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? selected,
      void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selected,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.list),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      validator: (value) => value == null ? 'Champ requis' : null,
    );
  }

  Widget _buildRowFields() {
    return Row(
      children: [
        Expanded(
            child: _buildTextField(
                "Prix (DH)", _priceController, IconlyLight.wallet)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildTextField(
                "Quantité", _quantityController, IconlyLight.bag)),
      ],
    );
  }
}
