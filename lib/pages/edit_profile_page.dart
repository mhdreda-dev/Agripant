import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:image_picker/image_picker.dart';

import '../screens/experts_list_screen.dart';
import 'FarmerDashboardPage.dart';

// Enum to define user types
enum UserType {
  none, // Added a case for an empty or default user type
  expert,
  farmer,
  buyer,
}

class EditProfilePage extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String? initialPhone;
  final String? initialAddress;
  final UserType userType; // Added user type parameter
  final String? profileImagePath; // Added for profile image

  // Common additional fields
  final String? city;
  final String? region;

  // Additional fields for each user type
  // Expert fields
  final String? expertSpeciality;
  final int? expertYearsExperience;
  final bool? expertProjectParticipation;
  final bool? expertProvidesTraining;
  final String? expertWorkRegion;

  // Farmer fields
  final String? farmerProductTypes;
  final double? farmerLandSize;
  final bool? farmerUsesModernTech;
  final String? farmerSupplySource;
  final String? farmerSalesChannel;
  final String? farmerRegion;

  // Buyer fields
  final String? buyerPreferredProducts;
  final String? buyerPurchaseFrequency;
  final String? buyerPreferredProductType;
  final String? buyerPurchaseCriteria;
  final String? buyerPurchaseChannel;
  final String? buyerLocation;

  const EditProfilePage({
    super.key,
    required this.initialName,
    required this.initialEmail,
    this.initialPhone,
    this.initialAddress,
    required this.userType,
    this.profileImagePath,
    this.city,
    this.region,
    // Expert fields
    this.expertSpeciality,
    this.expertYearsExperience,
    this.expertProjectParticipation,
    this.expertProvidesTraining,
    this.expertWorkRegion,
    // Farmer fields
    this.farmerProductTypes,
    this.farmerLandSize,
    this.farmerUsesModernTech,
    this.farmerSupplySource,
    this.farmerSalesChannel,
    this.farmerRegion,
    // Buyer fields
    this.buyerPreferredProducts,
    this.buyerPurchaseFrequency,
    this.buyerPreferredProductType,
    this.buyerPurchaseCriteria,
    this.buyerPurchaseChannel,
    this.buyerLocation,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Common fields controllers
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _regionController;

  // Expert specific controllers
  late final TextEditingController _specialityController;
  late final TextEditingController _yearsExperienceController;
  late bool _projectParticipation;
  late bool _providesTraining;
  late final TextEditingController _workRegionController;

  // Farmer specific controllers
  late final TextEditingController _productTypesController;
  late final TextEditingController _landSizeController;
  late bool _usesModernTech;
  late final TextEditingController _supplySourceController;
  late final TextEditingController _salesChannelController;
  late final TextEditingController _farmerRegionController;

  // Buyer specific controllers
  late final TextEditingController _preferredProductsController;
  late final TextEditingController _purchaseFrequencyController;
  late final TextEditingController _preferredProductTypeController;
  late final TextEditingController _purchaseCriteriaController;
  late final TextEditingController _purchaseChannelController;
  late final TextEditingController _buyerLocationController;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Image picker and profile image
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  // Current user type
  late UserType _currentUserType;

  @override
  void initState() {
    super.initState();
    // Initialize current user type
    _currentUserType = widget.userType;

    // Initialize common controllers
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _phoneController = TextEditingController(text: widget.initialPhone ?? '');
    _addressController =
        TextEditingController(text: widget.initialAddress ?? '');
    _cityController = TextEditingController(text: widget.city ?? '');
    _regionController = TextEditingController(text: widget.region ?? '');

    // Initialize expert controllers
    _specialityController =
        TextEditingController(text: widget.expertSpeciality ?? '');
    _yearsExperienceController = TextEditingController(
        text: widget.expertYearsExperience?.toString() ?? '');
    _projectParticipation = widget.expertProjectParticipation ?? false;
    _providesTraining = widget.expertProvidesTraining ?? false;
    _workRegionController =
        TextEditingController(text: widget.expertWorkRegion ?? '');

    // Initialize farmer controllers
    _productTypesController =
        TextEditingController(text: widget.farmerProductTypes ?? '');
    _landSizeController =
        TextEditingController(text: widget.farmerLandSize?.toString() ?? '');
    _usesModernTech = widget.farmerUsesModernTech ?? false;
    _supplySourceController =
        TextEditingController(text: widget.farmerSupplySource ?? '');
    _salesChannelController =
        TextEditingController(text: widget.farmerSalesChannel ?? '');
    _farmerRegionController =
        TextEditingController(text: widget.farmerRegion ?? '');

    // Initialize buyer controllers
    _preferredProductsController =
        TextEditingController(text: widget.buyerPreferredProducts ?? '');
    _purchaseFrequencyController =
        TextEditingController(text: widget.buyerPurchaseFrequency ?? '');
    _preferredProductTypeController =
        TextEditingController(text: widget.buyerPreferredProductType ?? '');
    _purchaseCriteriaController =
        TextEditingController(text: widget.buyerPurchaseCriteria ?? '');
    _purchaseChannelController =
        TextEditingController(text: widget.buyerPurchaseChannel ?? '');
    _buyerLocationController =
        TextEditingController(text: widget.buyerLocation ?? '');
  }

  @override
  void dispose() {
    // Dispose common controllers
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _regionController.dispose();

    // Dispose expert controllers
    _specialityController.dispose();
    _yearsExperienceController.dispose();
    _workRegionController.dispose();

    // Dispose farmer controllers
    _productTypesController.dispose();
    _landSizeController.dispose();
    _supplySourceController.dispose();
    _salesChannelController.dispose();
    _farmerRegionController.dispose();

    // Dispose buyer controllers
    _preferredProductsController.dispose();
    _purchaseFrequencyController.dispose();
    _preferredProductTypeController.dispose();
    _purchaseCriteriaController.dispose();
    _purchaseChannelController.dispose();
    _buyerLocationController.dispose();

    super.dispose();
  }

  // Method to pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  // Method to show image source selection dialog
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choisir une source',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageSourceOption(
                      icon: Icons.photo_library,
                      label: 'Galerie',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                    _buildImageSourceOption(
                      icon: Icons.camera_alt,
                      label: 'Caméra',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_profileImage != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _profileImage = null;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Supprimer la photo',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulation d'un délai réseau pour l'enregistrement des données
      await Future.delayed(const Duration(seconds: 1));

      // Create result map with common fields
      final result = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'region': _regionController.text,
        'userType': _currentUserType.toString(),
        'profileImagePath': _profileImage?.path,
      };

      // Add user type specific fields to result
      switch (_currentUserType) {
        case UserType.none:
          // No specific fields for 'none'
          break;
        case UserType.expert:
          result['speciality'] = _specialityController.text;
          result['yearsExperience'] = _yearsExperienceController.text;
          result['projectParticipation'] =
              _projectParticipation.toString(); // corrected
          result['providesTraining'] =
              _providesTraining.toString(); // corrected
          result['workRegion'] = _workRegionController.text;
          break;
        case UserType.farmer:
          result['productTypes'] = _productTypesController.text;
          result['landSize'] = _landSizeController.text;
          result['usesModernTech'] = _usesModernTech.toString(); // corrected
          result['supplySource'] = _supplySourceController.text;
          result['salesChannel'] = _salesChannelController.text;
          result['farmerRegion'] = _farmerRegionController.text;
          break;
        case UserType.buyer:
          result['preferredProducts'] = _preferredProductsController.text;
          result['purchaseFrequency'] = _purchaseFrequencyController.text;
          result['preferredProductType'] = _preferredProductTypeController.text;
          result['purchaseCriteria'] = _purchaseCriteriaController.text;
          result['purchaseChannel'] = _purchaseChannelController.text;
          result['buyerLocation'] = _buyerLocationController.text;
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate based on user type
        if (_currentUserType == UserType.farmer) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const FarmerDashboardPage()),
          );
        } else if (_currentUserType == UserType.expert) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ExpertsListScreen()),
          );
        } else {
          Navigator.pop(context, result);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Get appropriate title based on user type
    String titleText;
    switch (_currentUserType) {
      case UserType.none:
        titleText = 'Profil vide';
        break;
      case UserType.expert:
        titleText = 'Profil Expert';
        break;
      case UserType.farmer:
        titleText = 'Profil Agriculteur';
        break;
      case UserType.buyer:
        titleText = 'Profil Acheteur';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier mon $titleText'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfileImageSection(colorScheme),
                const SizedBox(height: 30),
                _buildUserTypeSelector(),
                const SizedBox(height: 20),
                _buildCommonInfoFields(),
                const SizedBox(height: 20),
                _buildUserSpecificFields(),
                const SizedBox(height: 40),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection(ColorScheme colorScheme) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Hero(
          tag: 'profile-avatar',
          child: CircleAvatar(
            radius: 70,
            backgroundColor: colorScheme.primary,
            child: CircleAvatar(
              radius: 68,
              backgroundImage: _getProfileImage(),
            ),
          ),
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: colorScheme.surface,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: colorScheme.primary,
            child: IconButton(
              icon:
                  const Icon(IconlyBold.camera, color: Colors.white, size: 20),
              onPressed: _showImageSourceDialog,
            ),
          ),
        ),
      ],
    );
  }

  ImageProvider _getProfileImage() {
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    } else if (widget.profileImagePath != null) {
      return FileImage(File(widget.profileImagePath!));
    } else {
      return const AssetImage('assets/profile.jpg');
    }
  }

  Widget _buildUserTypeSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Type de compte',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<UserType>(
            value: _currentUserType,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            items: [
              DropdownMenuItem(
                value: UserType.none,
                child: _buildUserTypeMenuItem(
                  icon: IconlyBold.profile,
                  label: 'Profil vide',
                  color: Colors.grey,
                ),
              ),
              DropdownMenuItem(
                value: UserType.expert,
                child: _buildUserTypeMenuItem(
                  icon: IconlyBold.star,
                  label: 'Expert en agriculture',
                  color: Colors.blue,
                ),
              ),
              DropdownMenuItem(
                value: UserType.farmer,
                child: _buildUserTypeMenuItem(
                  icon: IconlyBold.work,
                  label: 'Agriculteur',
                  color: Colors.green,
                ),
              ),
              DropdownMenuItem(
                value: UserType.buyer,
                child: _buildUserTypeMenuItem(
                  icon: IconlyBold.buy,
                  label: 'Acheteur',
                  color: Colors.orange,
                ),
              ),
            ],
            onChanged: (UserType? newValue) {
              if (newValue != null && newValue != _currentUserType) {
                setState(() {
                  _currentUserType = newValue;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeMenuItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildUserTypeDescription() {
    String description;
    switch (_currentUserType) {
      case UserType.none:
        description = '';
        break;
      case UserType.expert:
        description = 'Expert dans le domaine agricole';
        break;
      case UserType.farmer:
        description = 'Professionnel de l\'agriculture et de la production';
        break;
      case UserType.buyer:
        description = 'Acheteur de produits agricoles';
        break;
    }

    if (description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(
        '**$description**',
        style: const TextStyle(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCommonInfoFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            'Informations personnelles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildUserTypeDescription(),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nameController,
          labelText: 'Nom complet',
          hintText: 'Entrez votre nom complet',
          icon: IconlyBold.profile,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre nom';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _emailController,
          labelText: 'Email',
          hintText: 'Entrez votre adresse email',
          icon: IconlyBold.message,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Veuillez entrer un email valide';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _phoneController,
          labelText: 'Téléphone',
          hintText: 'Entrez votre numéro de téléphone',
          icon: IconlyBold.call,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _addressController,
          labelText: 'Adresse',
          hintText: 'Entrez votre adresse complète',
          icon: IconlyBold.location,
          maxLines: 2,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _cityController,
          labelText: 'Ville',
          hintText: 'Entrez votre ville',
          icon: IconlyBold.home,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _regionController,
          labelText: 'Région',
          hintText: 'Entrez votre région',
          icon: IconlyBold.paper,
        ),
      ],
    );
  }

  Widget _buildUserSpecificFields() {
    switch (_currentUserType) {
      case UserType.expert:
        return _buildExpertFields();
      case UserType.farmer:
        return _buildFarmerFields();
      case UserType.buyer:
        return _buildBuyerFields();
      case UserType.none:
      default:
        return const SizedBox.shrink(); // Ne rien afficher
    }
  }

  Widget _buildExpertFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, top: 16.0, bottom: 16.0),
          child: Text(
            'Informations professionnelles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildTextField(
          controller: _specialityController,
          labelText: 'Domaine de spécialité',
          hintText: 'Ex: maladies des plantes, analyse du sol, irrigation...',
          icon: IconlyBold.star,
          validator: (value) {
            if (_currentUserType == UserType.expert &&
                (value == null || value.isEmpty)) {
              return 'Veuillez spécifier votre domaine de spécialité';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _yearsExperienceController,
          labelText: 'Années d\'expérience',
          hintText: 'Nombre d\'années d\'expérience dans ce domaine',
          icon: IconlyBold.timeCircle,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (_currentUserType == UserType.expert &&
                (value == null || value.isEmpty)) {
              return 'Veuillez indiquer vos années d\'expérience';
            }
            if (value != null && value.isNotEmpty) {
              try {
                int years = int.parse(value);
                if (years < 0 || years > 100) {
                  return 'Veuillez entrer un nombre valide (0-100)';
                }
              } catch (e) {
                return 'Veuillez entrer un nombre valide';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildSwitchField(
          title: 'Participation à des projets',
          subtitle:
              'Participez-vous à des projets avec des coopératives ou des institutions agricoles?',
          value: _projectParticipation,
          onChanged: (value) {
            setState(() {
              _projectParticipation = value;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildSwitchField(
          title: 'Formation et conseil',
          subtitle:
              'Proposez-vous des formations ou des conseils aux agriculteurs?',
          value: _providesTraining,
          onChanged: (value) {
            setState(() {
              _providesTraining = value;
            });
          },
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _workRegionController,
          labelText: 'Région principale de travail',
          hintText:
              'Dans quelle région ou ville travaillez-vous principalement?',
          icon: IconlyBold.work,
        ),
      ],
    );
  }

  Widget _buildFarmerFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, top: 16.0, bottom: 16.0),
          child: Text(
            'Informations agricoles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildTextField(
          controller: _productTypesController,
          labelText: 'Produits cultivés',
          hintText: 'Ex: olives, dattes, légumes...',
          icon: IconlyBold.category,
          validator: (value) {
            if (_currentUserType == UserType.farmer &&
                (value == null || value.isEmpty)) {
              return 'Veuillez spécifier vos produits';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _landSizeController,
          labelText: 'Superficie du terrain (hectares)',
          hintText: 'Superficie de votre terrain en hectares',
          icon: IconlyBold.document,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (_currentUserType == UserType.farmer &&
                (value == null || value.isEmpty)) {
              return 'Veuillez indiquer la superficie';
            }
            if (value != null && value.isNotEmpty) {
              try {
                double size = double.parse(value);
                if (size < 0) {
                  return 'La superficie ne peut pas être négative';
                }
              } catch (e) {
                return 'Veuillez entrer un nombre valide';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildSwitchField(
          title: 'Technologies modernes',
          subtitle:
              'Utilisez-vous des technologies modernes (irrigation goutte à goutte, applications, capteurs...)?',
          value: _usesModernTech,
          onChanged: (value) {
            setState(() {
              _usesModernTech = value;
            });
          },
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _supplySourceController,
          labelText: 'Sources d\'approvisionnement',
          hintText:
              'D\'où obtenez-vous vos semences, engrais ou autres matériaux?',
          icon: IconlyBold.bag,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _salesChannelController,
          labelText: 'Canaux de vente',
          hintText:
              'Comment vendez-vous vos produits (marché, direct aux consommateurs...)?',
          icon: IconlyBold.buy,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _farmerRegionController,
          labelText: 'Région agricole',
          hintText: 'Dans quelle ville ou région se trouve votre exploitation?',
          icon: IconlyBold.location,
        ),
      ],
    );
  }

  Widget _buildSwitchField({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildBuyerFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, top: 16.0, bottom: 16.0),
          child: Text(
            'Préférences d\'achat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildTextField(
          controller: _preferredProductsController,
          labelText: 'Produits préférés',
          hintText: 'Ex: légumes, fruits, huile, lait...',
          icon: IconlyBold.category,
          validator: (value) {
            if (_currentUserType == UserType.buyer &&
                (value == null || value.isEmpty)) {
              return 'Veuillez spécifier vos produits préférés';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _purchaseFrequencyController,
          labelText: 'Fréquence d\'achat',
          hintText: 'Ex: quotidiennement, hebdomadairement, mensuellement',
          icon: IconlyBold.timeCircle,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _preferredProductTypeController,
          labelText: 'Type de produits préférés',
          hintText: 'Préférez-vous des produits locaux ou industriels?',
          icon: IconlyBold.star,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _purchaseCriteriaController,
          labelText: 'Critères d\'achat importants',
          hintText: 'Ex: prix, qualité, livraison...',
          icon: IconlyBold.filter,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _purchaseChannelController,
          labelText: 'Canal d\'achat',
          hintText: 'Achetez-vous via une plateforme en ligne ou en magasin?',
          icon: IconlyBold.bag,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _buyerLocationController,
          labelText: 'Localisation',
          hintText: 'Dans quelle ville vous trouvez-vous?',
          icon: IconlyBold.location,
        ),
        // Complétion de la méthode _buildBuyerFields()
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: Icon(icon, size: 20),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
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
                'Enregistrer les modifications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
