import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import '../models/expert.dart';
import '../widgets/expert_profile_avatar.dart';

class ExpertDetailScreen extends StatefulWidget {
  final Expert expert;

  const ExpertDetailScreen({
    Key? key,
    required this.expert,
  }) : super(key: key);

  @override
  _ExpertDetailScreenState createState() => _ExpertDetailScreenState();
}

class _ExpertDetailScreenState extends State<ExpertDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'expert'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.bookmark),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Expert ajouté aux favoris')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile header with background color
                  Container(
                    width: double.infinity,
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Expert profile avatar
                        ExpertProfileAvatar(
                          expert: widget.expert,
                          size: 100,
                        ),
                        const SizedBox(height: 16),

                        // Expert name with verified badge
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.expert.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            if (widget.expert.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified,
                                  color: Colors.blue, size: 20),
                            ],
                          ],
                        ),

                        // Speciality
                        Text(
                          widget.expert.speciality,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Status indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.expert.status == 'Disponible'
                                ? Colors.green.shade100
                                : widget.expert.status == 'Occupé'
                                    ? Colors.orange.shade100
                                    : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.expert.status,
                            style: TextStyle(
                              color: widget.expert.status == 'Disponible'
                                  ? Colors.green.shade800
                                  : widget.expert.status == 'Occupé'
                                      ? Colors.orange.shade800
                                      : Colors.red.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stats row
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _buildStatCard(
                          context,
                          Icons.star,
                          '${widget.expert.rating}',
                          'Note',
                          iconColor: Colors.amber,
                        ),
                        _buildStatCard(
                          context,
                          IconlyLight.chat,
                          '${widget.expert.reviews}',
                          'Avis',
                        ),
                        _buildStatCard(
                          context,
                          IconlyLight.timeCircle,
                          '${widget.expert.yearsExperience} ans',
                          'Expérience',
                        ),
                      ],
                    ),
                  ),

                  Divider(color: Colors.grey.shade300),

                  // Hourly rate
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(context, 'Tarif horaire'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                IconlyBold.wallet,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${widget.expert.hourlyRate} MAD/heure',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(color: Colors.grey.shade300),

                  // Bio section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(context, 'À propos'),
                        const SizedBox(height: 12),
                        Text(
                          widget.expert.bio,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),

                  // Padding at the bottom to ensure space for the bottom button
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        }),
      ),
      // Fixed consultation button at the bottom
      bottomSheet: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: widget.expert.status == 'Disponible'
              ? () {
                  // Show consultation booking dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Demande de consultation envoyée')),
                  );
                }
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(IconlyLight.calendar),
              const SizedBox(width: 8),
              Text(
                widget.expert.status == 'Disponible'
                    ? 'Réserver une consultation'
                    : 'Expert non disponible',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(color: Colors.grey.shade300),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      BuildContext context, IconData icon, String value, String label,
      {Color? iconColor}) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(
                icon,
                color: iconColor ?? Theme.of(context).primaryColor,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
