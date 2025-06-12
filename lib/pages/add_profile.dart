import 'package:agriplant/pages/BuyerDashboardPage.dart';
import 'package:agriplant/pages/ExpertDashboardPage.dart';
import 'package:agriplant/pages/FarmerDashboardPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum ProfileType { expert, agriculture, acheteur }

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final TextEditingController _customDescriptionController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  ProfileType _selectedProfileType = ProfileType.expert;
  String? _selectedOption;
  bool _isLoading = false;
  bool _isCheckingProfile = true;
  bool _isProfileLocked = false;

  // Configuration des profils avec une structure plus maintenable
  static const Map<ProfileType, ProfileConfig> _profileConfigs = {
    ProfileType.expert: ProfileConfig(
      title: 'Expert',
      description:
          'Les experts accompagnent les agriculteurs dans leurs pratiques et apportent des conseils techniques.',
      icon: Icons.psychology,
      color: Color(0xFF2196F3),
      options: [
        'Agronomie',
        'Protection des plantes',
        'AgriTech',
        'Irrigation',
        'Sol et fertilisation'
      ],
    ),
    ProfileType.agriculture: ProfileConfig(
      title: 'Agriculteur',
      description:
          'Les agriculteurs produisent et vendent des produits agricoles de qualité.',
      icon: Icons.agriculture,
      color: Color(0xFF4CAF50),
      options: [
        'Bio',
        'Conventionnelle',
        'Permaculture',
        'Hydroponique',
        'Élevage'
      ],
    ),
    ProfileType.acheteur: ProfileConfig(
      title: 'Acheteur',
      description:
          'Les acheteurs recherchent des produits agricoles pour les consommer ou les revendre.',
      icon: Icons.shopping_cart,
      color: Color(0xFFFF9800),
      options: [
        'Restaurants',
        'Supermarchés',
        'Exportateurs',
        'Grossistes',
        'Coopératives'
      ],
    ),
  };

  @override
  void initState() {
    super.initState();
    _checkExistingProfile();
  }

  @override
  void dispose() {
    _customDescriptionController.dispose();
    super.dispose();
  }

  // Vérifier si le profil existe déjà et rediriger si nécessaire
  Future<void> _checkExistingProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isCheckingProfile = false;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final isProfileComplete = data['isProfileComplete'] as bool? ?? false;

        if (isProfileComplete) {
          // Profil déjà configuré, rediriger vers le dashboard approprié
          final profileType = data['profileType'] as String?;
          if (profileType != null && mounted) {
            _navigateToDashboardByType(profileType);
            return;
          }
        } else {
          // Profil partiellement configuré, charger les données existantes
          _loadExistingProfileData(data);
        }
      }
    } catch (e) {
      print('Erreur lors de la vérification du profil: $e');
    }

    if (mounted) {
      setState(() {
        _isCheckingProfile = false;
      });
    }
  }

  // Charger les données de profil existantes
  void _loadExistingProfileData(Map<String, dynamic> data) {
    final profileType = data['profileType'] as String?;
    final profileOption = data['profileOption'] as String?;
    final description = data['description'] as String?;

    if (profileType != null) {
      // Convertir le string en ProfileType
      ProfileType? type;
      switch (profileType.toLowerCase()) {
        case 'expert':
          type = ProfileType.expert;
          break;
        case 'agriculteur':
          type = ProfileType.agriculture;
          break;
        case 'acheteur':
          type = ProfileType.acheteur;
          break;
      }

      if (type != null) {
        setState(() {
          _selectedProfileType = type!;
          _selectedOption = profileOption;
          _customDescriptionController.text = description ?? '';
          _isProfileLocked = true; // Verrouiller le profil déjà choisi
        });
      }
    }
  }

  // Navigation vers le dashboard en fonction du type de profil
  void _navigateToDashboardByType(String profileType) {
    Widget dashboard;
    switch (profileType.toLowerCase()) {
      case 'expert':
        dashboard = const ExpertDashboardPage();
        break;
      case 'agriculteur':
        dashboard = const FarmerDashboardPage();
        break;
      case 'acheteur':
        dashboard = const BuyerDashboardPage();
        break;
      default:
        return; // Type de profil non reconnu
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => dashboard),
    );
  }

  // Réinitialiser le profil (fonction d'administration)
  Future<void> _resetProfile() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser le profil'),
        content: const Text(
          'Êtes-vous sûr de vouloir réinitialiser votre profil ? '
          'Cette action supprimera toutes vos données de profil actuelles.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          setState(() {
            _isLoading = true;
          });

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'profileType': FieldValue.delete(),
            'profileOption': FieldValue.delete(),
            'description': FieldValue.delete(),
            'isProfileComplete': false,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          setState(() {
            _selectedProfileType = ProfileType.expert;
            _selectedOption = null;
            _customDescriptionController.clear();
            _isProfileLocked = false;
          });

          _showSuccessSnackBar('Profil réinitialisé avec succès');
        } catch (e) {
          _showErrorSnackBar('Erreur lors de la réinitialisation: $e');
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showOptions() {
    final config = _profileConfigs[_selectedProfileType]!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sélectionnez votre spécialité',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...config.options
                .map((option) => _buildOptionTile(option, config.color)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(String option, Color color) {
    final isSelected = _selectedOption == option;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isSelected ? Icons.check_circle : Icons.circle_outlined,
          color: isSelected ? color : Colors.grey,
        ),
        title: Text(
          option,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : null,
          ),
        ),
        onTap: () {
          setState(() {
            _selectedOption = option;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _navigateToDashboard() {
    if (!mounted) return;

    Widget dashboard;
    switch (_selectedProfileType) {
      case ProfileType.expert:
        dashboard = const ExpertDashboardPage();
        break;
      case ProfileType.agriculture:
        dashboard = const FarmerDashboardPage();
        break;
      case ProfileType.acheteur:
        dashboard = const BuyerDashboardPage();
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => dashboard),
    );
  }

  Future<void> _confirmProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedOption == null) {
      _showErrorSnackBar("Veuillez sélectionner une spécialité");
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorSnackBar("Utilisateur non connecté");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final config = _profileConfigs[_selectedProfileType]!;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'profileType': config.title,
        'profileOption': _selectedOption,
        'description': _customDescriptionController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isProfileComplete': true,
      });

      if (mounted) {
        _showSuccessSnackBar("Profil enregistré avec succès");
        await Future.delayed(const Duration(milliseconds: 500));
        _navigateToDashboard();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar("Erreur lors de l'enregistrement: ${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Afficher un indicateur de chargement pendant la vérification du profil
    if (_isCheckingProfile) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Configuration du Profil"),
          centerTitle: true,
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Vérification du profil...'),
            ],
          ),
        ),
      );
    }

    final config = _profileConfigs[_selectedProfileType]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuration du Profil"),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Bouton de réinitialisation (visible seulement si le profil est verrouillé)
          if (_isProfileLocked)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetProfile,
              tooltip: 'Réinitialiser le profil',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              if (_isProfileLocked) _buildProfileLockedNotice(),
              if (_isProfileLocked) const SizedBox(height: 16),
              _buildProfileSelector(),
              const SizedBox(height: 16),
              _buildProfileDescription(config),
              const SizedBox(height: 24),
              _buildSpecialitySelector(config),
              const SizedBox(height: 24),
              _buildDescriptionField(),
              const SizedBox(height: 32),
              _buildConfirmButton(config),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileLockedNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profil partiellement configuré',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                Text(
                  'Votre type de profil a été sauvegardé. Complétez la configuration ou réinitialisez depuis le bouton en haut à droite.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.account_circle,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              _isProfileLocked
                  ? 'Complétez votre profil'
                  : 'Configurez votre profil',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              _isProfileLocked
                  ? 'Finalisez la configuration de votre profil'
                  : 'Choisissez le type de profil qui vous correspond',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type de profil',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...ProfileType.values.map((type) {
          final config = _profileConfigs[type]!;
          final isSelected = _selectedProfileType == type;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: isSelected ? 4 : 1,
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: config.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(config.icon, color: config.color),
              ),
              title: Text(
                config.title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check_circle, color: config.color)
                  : const Icon(Icons.circle_outlined, color: Colors.grey),
              onTap: _isProfileLocked
                  ? null // Désactiver la sélection si le profil est verrouillé
                  : () {
                      setState(() {
                        _selectedProfileType = type;
                        _selectedOption = null;
                        _customDescriptionController.clear();
                      });
                    },
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildProfileDescription(ProfileConfig config) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: config.color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              config.description,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialitySelector(ProfileConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spécialité',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _showOptions,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _selectedOption == null
                  ? Colors.grey[50]
                  : config.color.withOpacity(0.05),
              border: Border.all(
                color:
                    _selectedOption == null ? Colors.grey[300]! : config.color,
                width: _selectedOption == null ? 1 : 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  _selectedOption == null ? Icons.category : Icons.check_circle,
                  color: _selectedOption == null ? Colors.grey : config.color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedOption ?? "Sélectionner une spécialité",
                    style: TextStyle(
                      color: _selectedOption != null
                          ? Colors.black
                          : Colors.grey[600],
                      fontWeight: _selectedOption != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: _selectedOption == null ? Colors.grey : config.color,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description personnalisée (facultatif)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _customDescriptionController,
          maxLines: 3,
          maxLength: 500,
          decoration: InputDecoration(
            hintText:
                "Décrivez votre expérience, vos compétences ou vos besoins...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value != null && value.length > 500) {
              return "La description ne peut pas dépasser 500 caractères";
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildConfirmButton(ProfileConfig config) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _confirmProfile,
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.check_circle),
      label: Text(
        _isLoading ? "Enregistrement..." : "Valider mon profil",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: config.color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    );
  }
}

// Classe pour une meilleure organisation des configurations de profil
class ProfileConfig {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> options;

  const ProfileConfig({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.options,
  });
}
