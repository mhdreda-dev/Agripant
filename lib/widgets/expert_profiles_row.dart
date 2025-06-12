import 'package:flutter/material.dart';

import '../models/expert.dart';
import 'expert_profile_avatar.dart';

Widget buildExpertProfilesRow(List<Expert> experts) {
  final displayExperts = experts.take(4).toList();

  return SizedBox(
    height: 150, // Increase the height to prevent overflow
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: displayExperts.length,
      itemBuilder: (context, index) {
        final expert = displayExperts[index];
        return Container(
          width: 110,
          margin: const EdgeInsets.only(right: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Prevents unnecessary expansion
            children: [
              ExpertProfileAvatar(
                expert: expert,
                size: 70,
                showVerifiedBadge: true,
              ),
              const SizedBox(height: 8),
              Text(
                expert.name.split(' ')[0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                expert.speciality,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    size: 14,
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
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}
