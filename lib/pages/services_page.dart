import 'package:flutter/material.dart';

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
  // Options disponibles pour chaque catégorie
  final List<Map<String, dynamic>> _createdProfiles = [];

  // Profil actuellement sélectionné
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

  void _createProfile() {
    if (_selectedOption != null) {
      setState(() {
        _createdProfiles.add({
          'type': _selectedProfileType,
          'option': _selectedOption,
          'date': DateTime.now(),
        });

        // Réinitialiser la sélection
        _selectedOption = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil créé avec succès')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une option')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sélectionner un Profil",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Choisissez un type de profil",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                    ),
                    const SizedBox(height: 24),

                    // Sélecteur de type de profil
                    _buildProfileTypeSelector(),

                    const SizedBox(height: 32),

                    // Bouton de sélection d'option
                    _buildOptionSelector(),

                    const SizedBox(height: 32),

                    // Bouton pour créer le profil
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: _profileColors[_selectedProfileType],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Créer le Profil",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (_createdProfiles.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32.0),
                          child: Text(
                            "Aucun profil créé pour le moment.",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Liste des profils créés
              if (_createdProfiles.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final profile = _createdProfiles[index];
                      return _buildProfileCard(profile);
                    },
                    childCount: _createdProfiles.length,
                  ),
                ),
            ],
          ),
        ),
      ),
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
                    _selectedOption ?? "Sélectionner un ${title.toLowerCase()}",
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

  Widget _buildProfileCard(Map<String, dynamic> profile) {
    final type = profile['type'] as ProfileType;
    final option = profile['option'] as String;
    final date = profile['date'] as DateTime;

    final color = _profileColors[type] ?? Colors.grey;
    final icon = _profileIcons[type] ?? Icons.circle;
    final title = _profileTitles[type] ?? 'Inconnu';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: color,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _createdProfiles.remove(profile);
                    });
                  },
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              option,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Créé le : ${_formatDate(date)}",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Format simple jj/mm/aaaa hh:mm
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year} à "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }
}
