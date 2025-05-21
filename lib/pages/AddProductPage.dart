import 'dart:io';

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
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _harvestDateController = TextEditingController();

  String? _selectedCategory;
  String? _selectedUnit;
  bool _isOrganic = false;
  bool _isDeliveryAvailable = false;
  bool _isLoading = false;

  // For product images
  final ImagePicker _picker = ImagePicker();
  List<File> _productImages = [];

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
    try {
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  Future<void> _selectHarvestDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _harvestDateController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _productImages.removeAt(index);
    });
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      if (_productImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Veuillez ajouter au moins une image du produit')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Simulation d'envoi des données à la base de données
        await Future.delayed(const Duration(seconds: 1));

        final product = {
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
          'imagesCount': _productImages.length,
        };

        // Ici, tu ajouterais le code pour envoyer les données à ta base de données
        // et uploader les images

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produit ajouté avec succès'),
              backgroundColor: Colors.green,
            ),
          );

          // Afficher une boîte de dialogue demandant si l'utilisateur veut ajouter un autre produit
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Produit ajouté'),
                content: const Text('Voulez-vous ajouter un autre produit?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // Fermer la boîte de dialogue
                      _resetForm(); // Réinitialiser le formulaire
                    },
                    child: const Text('Oui'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // Fermer la boîte de dialogue
                      Navigator.pop(context); // Retourner à la page précédente
                    },
                    child: const Text('Non'),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un produit'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductImageSection(colorScheme),
                const SizedBox(height: 24),
                _buildProductBasicInfo(),
                const SizedBox(height: 24),
                _buildProductDetails(),
                const SizedBox(height: 24),
                _buildProductOptions(),
                const SizedBox(height: 32),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImageSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photos du produit',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            children: [
              // Add image button
              InkWell(
                onTap: _pickProductImage,
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.primary, width: 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(IconlyLight.plus, color: colorScheme.primary),
                      const SizedBox(height: 8),
                      Text(
                        'Ajouter',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Display selected images
              for (var i = 0; i < _productImages.length; i++)
                Stack(
                  children: [
                    Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.file(
                          _productImages[i],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 13,
                      child: InkWell(
                        onTap: () => _removeImage(i),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (_productImages.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Ajoutez au moins une photo de votre produit',
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informations de base',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _productNameController,
          decoration: InputDecoration(
            labelText: 'Nom du produit',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(IconlyLight.document),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Veuillez entrer un nom pour votre produit';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          items: _categories.map((category) {
            return DropdownMenuItem(value: category, child: Text(category));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
          decoration: InputDecoration(
            labelText: 'Catégorie',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(IconlyLight.category),
          ),
          validator: (value) {
            if (value == null) {
              return 'Veuillez sélectionner une catégorie';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(IconlyLight.paper),
            alignLabelWithHint: true,
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Détails du produit',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Prix',
                  suffixText: 'DH',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(IconlyLight.wallet),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Requis';
                  }
                  try {
                    double price = double.parse(value);
                    if (price <= 0) {
                      return 'Prix invalide';
                    }
                  } catch (e) {
                    return 'Nombre invalide';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantité',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(IconlyLight.bag2),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Requis';
                  }
                  try {
                    double quantity = double.parse(value);
                    if (quantity <= 0) {
                      return 'Quantité invalide';
                    }
                  } catch (e) {
                    return 'Nombre invalide';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedUnit,
                items: _units.map((unit) {
                  return DropdownMenuItem(value: unit, child: Text(unit));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUnit = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Unité',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(IconlyLight.chart),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Sélectionnez une unité';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _harvestDateController,
                readOnly: true,
                onTap: _selectHarvestDate,
                decoration: InputDecoration(
                  labelText: 'Date de récolte',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(IconlyLight.calendar),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _locationController,
          decoration: InputDecoration(
            labelText: 'Lieu de production',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(IconlyLight.location),
          ),
        ),
      ],
    );
  }

  Widget _buildProductOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Options supplémentaires',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Produit biologique'),
          subtitle: const Text(
              'Ce produit est cultivé sans pesticides ou produits chimiques'),
          value: _isOrganic,
          onChanged: (bool value) {
            setState(() {
              _isOrganic = value;
            });
          },
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('Livraison disponible'),
          subtitle: const Text(
              'Vous proposez un service de livraison pour ce produit'),
          value: _isDeliveryAvailable,
          onChanged: (bool value) {
            setState(() {
              _isDeliveryAvailable = value;
            });
          },
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProduct,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Ajouter le produit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
