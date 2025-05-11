import 'package:agriplant/data/experts.dart';
import 'package:agriplant/models/expert.dart';
import 'package:agriplant/widgets/expert_filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import '../widgets/expert_profile_avatar.dart' show ExpertProfileAvatar;

class ExpertsListScreen extends StatefulWidget {
  const ExpertsListScreen({Key? key}) : super(key: key);

  @override
  State<ExpertsListScreen> createState() => _ExpertsListScreenState();
}

class _ExpertsListScreenState extends State<ExpertsListScreen> {
  String? selectedSpeciality;
  bool showOnlyAvailable = false;
  bool showOnlyVerified = false;

  List<Expert> filteredExperts() {
    return experts.where((expert) {
      // Filtre par spécialité si une est sélectionnée
      if (selectedSpeciality != null &&
          expert.speciality != selectedSpeciality) {
        return false;
      }

      // Filtre par disponibilité si l'option est activée
      if (showOnlyAvailable && expert.status != 'Disponible') {
        return false;
      }

      // Filtre pour les experts vérifiés si l'option est activée
      if (showOnlyVerified && !expert.isVerified) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Expert> displayedExperts = filteredExperts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nos Experts'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Widget de filtrage par spécialité
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: ExpertFilterWidget(
              onSpecialitySelected: (speciality) {
                setState(() {
                  selectedSpeciality =
                      speciality == selectedSpeciality ? null : speciality;
                });
              },
              selectedSpeciality: selectedSpeciality,
            ),
          ),

          // Options de filtrage supplémentaires
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: FilterChip(
                    label: const Text('Disponibles'),
                    selected: showOnlyAvailable,
                    onSelected: (selected) {
                      setState(() {
                        showOnlyAvailable = selected;
                      });
                    },
                    checkmarkColor: Colors.white,
                    selectedColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(
                      color: showOnlyAvailable ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilterChip(
                    label: const Text('Vérifiés'),
                    selected: showOnlyVerified,
                    onSelected: (selected) {
                      setState(() {
                        showOnlyVerified = selected;
                      });
                    },
                    checkmarkColor: Colors.white,
                    selectedColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(
                      color: showOnlyVerified ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Liste des experts
          Expanded(
            child: displayedExperts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          IconlyBold.search,
                          size: 50,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun expert trouvé',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Essayez de modifier vos filtres',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayedExperts.length,
                    itemBuilder: (context, index) {
                      final expert = displayedExperts[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            // Navigation vers la page détaillée de l'expert
                            // À implémenter
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Photo de profil
                                ExpertProfileAvatar(
                                  expert: expert,
                                  size: 70,
                                ),
                                const SizedBox(width: 16),
                                // Informations sur l'expert
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              expert.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          if (expert.isVerified)
                                            const Icon(
                                              Icons.verified,
                                              color: Colors.blue,
                                              size: 18,
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        expert.speciality,
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: expert.status ==
                                                      'Disponible'
                                                  ? Colors.green.shade100
                                                  : expert.status == 'Occupé'
                                                      ? Colors.orange.shade100
                                                      : Colors.red.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              expert.status,
                                              style: TextStyle(
                                                color: expert.status ==
                                                        'Disponible'
                                                    ? Colors.green.shade800
                                                    : expert.status == 'Occupé'
                                                        ? Colors.orange.shade800
                                                        : Colors.red.shade800,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.star,
                                            size: 16,
                                            color: Colors.amber.shade600,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            expert.rating.toString(),
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            ' (${expert.reviews})',
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${expert.hourlyRate} MAD/heure',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
