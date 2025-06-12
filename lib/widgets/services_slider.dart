import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../pages/FarmerDashboardPage.dart';

enum ProfileType {
  expert,
  agriculture,
  acheteur,
}

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  // Profil sélectionné (un seul)
  Map<String, dynamic>? _selectedProfile;

  // Profil actuellement en cours de sélection
  ProfileType _selectedProfileType = ProfileType.expert;
  String? _selectedOption;

  // Options disponibles pour chaque type de profil
  final Map<ProfileType, List<String>> _profileOptions = {
    ProfileType.expert: [
      'Agronomie',
      'Irrigation et gestion de l\'eau',
      'Élevage et production animale',
      'Machinisme agricole',
      'Agroéconomie',
      'Agroécologie',
      'Protection des plantes',
      'Gestion des sols',
      'Industrie agroalimentaire',
      'Transformation des produits agricoles',
      'Développement rural',
      'Agriculture biologique',
      'AgriTech (technologie agricole)',
      'Gestion des ressources naturelles',
      'Climat et agriculture durable',
      'Commercialisation et chaîne de valeur',
      'Sécurité alimentaire',
      'Systèmes de culture',
      'Politiques agricoles',
      'Entrepreneuriat agricole',
    ],
    ProfileType.agriculture: [
      'Bio',
      'Conventionnelle',
      'Permaculture',
      'Hydroponie',
      'Agroforesterie',
      'Agriculture intensive',
      'Agriculture extensive',
      'Agriculture raisonnée',
      'Agriculture verticale',
      'Agriculture urbaine',
    ],
    ProfileType.acheteur: [
      'Particuliers',
      'Magasins Bio',
      'Restaurants',
      'Supermarchés',
      'Coopératives',
      'Exportateurs',
      'Transformateurs',
      'Grossistes',
      'Distributeurs',
      'Institutions publiques',
    ],
  };

  // Couleurs et icônes pour chaque type de profil
  final Map<ProfileType, Color> _profileColors = {
    ProfileType.expert: Colors.blue,
    ProfileType.agriculture: Colors.green,
    ProfileType.acheteur: Colors.orange,
  };

  final Map<ProfileType, IconData> _profileIcons = {
    ProfileType.expert: Icons.person,
    ProfileType.agriculture: Icons.eco,
    ProfileType.acheteur: Icons.shopping_cart,
  };

  // Titres pour chaque type de profil
  final Map<ProfileType, String> _profileTitles = {
    ProfileType.expert: 'Expert',
    ProfileType.agriculture: 'Agriculture',
    ProfileType.acheteur: 'Acheteur',
  };

  void _showOptions() {
    final options = _profileOptions[_selectedProfileType] ?? [];
    final title =
        "Choisir un ${_profileTitles[_selectedProfileType]?.toLowerCase()}";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: options.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(options[index]),
                    onTap: () {
                      setState(() {
                        _selectedOption = options[index];
                      });
                      Navigator.pop(context);
                    },
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmProfile() {
    if (_selectedOption != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmer le profil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Type: ${_profileTitles[_selectedProfileType]}'),
              const SizedBox(height: 8),
              Text('Spécialité: $_selectedOption'),
              const SizedBox(height: 16),
              Text(
                'Voulez-vous confirmer ce profil ?',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                setState(() {
                  _selectedProfile = {
                    'type': _selectedProfileType,
                    'option': _selectedOption,
                    'date': DateTime.now(),
                  };
                });

                Navigator.pop(context); // ferme la pop-up

                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .update({
                    'profileType': _profileTitles[_selectedProfileType],
                    'profileOption': _selectedOption,
                    'profileUpdatedAt': FieldValue.serverTimestamp(),
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Profil confirmé avec succès')),
                  );

                  if (_selectedProfileType == ProfileType.agriculture &&
                      mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FarmerDashboardPage(),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Erreur : ${e.toString()}")),
                  );
                }
              },
              child: const Text('Confirmer'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une spécialité')),
      );
    }
  }

  void _resetProfile() {
    setState(() {
      _selectedProfile = null;
      _selectedOption = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mon Profil",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          if (_selectedProfile != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetProfile,
              tooltip: 'Changer de profil',
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _selectedProfile == null
              ? _buildProfileSelection()
              : _buildSelectedProfile(),
        ),
      ),
    );
  }

  Widget _buildProfileSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Choisissez votre profil",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          "Sélectionnez un type de profil et une spécialité",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 32),

        // Sélecteur de type de profil
        _buildProfileTypeSelector(),

        const SizedBox(height: 24),

        // Bouton de sélection d'option
        _buildOptionSelector(),

        const SizedBox(height: 32),

        // Bouton pour confirmer le profil
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _confirmProfile,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: _profileColors[_selectedProfileType],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Confirmer mon Profil",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedProfile() {
    final type = _selectedProfile!['type'] as ProfileType;
    final option = _selectedProfile!['option'] as String;
    final date = _selectedProfile!['date'] as DateTime;

    final color = _profileColors[type] ?? Colors.grey;
    final icon = _profileIcons[type] ?? Icons.circle;
    final title = _profileTitles[type] ?? 'Inconnu';

    return Column(
      children: [
        const SizedBox(height: 40),

        // Icône du profil
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 64,
            color: color,
          ),
        ),

        const SizedBox(height: 24),

        // Titre du profil
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),

        const SizedBox(height: 16),

        // Spécialité
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text(
                "Spécialité",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                option,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Date de création
        Text(
          "Profil créé le ${_formatDate(date)}",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),

        const Spacer(),

        // Bouton pour changer de profil
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _resetProfile,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: color),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Changer de Profil",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildProfileTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: ProfileType.values.map((type) {
          final isSelected = _selectedProfileType == type;
          final color = _profileColors[type] ?? Colors.grey;
          final icon = _profileIcons[type] ?? Icons.circle;
          final title = _profileTitles[type] ?? 'Inconnu';

          return InkWell(
            onTap: () {
              setState(() {
                _selectedProfileType = type;
                _selectedOption = null; // Réinitialiser l'option sélectionnée
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
                border: isSelected
                    ? Border(left: BorderSide(color: color, width: 4))
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                      color: isSelected ? color : Colors.black,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected) Icon(Icons.check_circle, color: color)
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOptionSelector() {
    final color = _profileColors[_selectedProfileType] ?? Colors.grey;
    final icon = _profileIcons[_selectedProfileType] ?? Icons.circle;
    final title = _profileTitles[_selectedProfileType] ?? 'Inconnu';

    return InkWell(
      onTap: _showOptions,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _selectedOption != null
              ? color.withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedOption != null ? color : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedOption ?? "Sélectionner une spécialité",
                    style: TextStyle(
                      color: _selectedOption != null
                          ? Colors.black87
                          : Colors.grey[600],
                      fontWeight: _selectedOption != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year} à "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }
}
