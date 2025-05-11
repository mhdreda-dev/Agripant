import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import '../models/expert.dart';

class ExpertProfileAvatar extends StatelessWidget {
  final Expert expert;
  final double size;
  final bool showVerifiedBadge;

  const ExpertProfileAvatar({
    Key? key,
    required this.expert,
    this.size = 70,
    this.showVerifiedBadge = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
            border: Border.all(
              color: expert.status == 'Disponible'
                  ? Colors.green
                  : expert.status == 'Occupé'
                      ? Colors.orange
                      : Colors.grey,
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: null != expert.profileImageUrl
                ? Image.asset(
                    expert.profileImageUrl, // Remove the '!' here
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        IconlyBold.profile,
                        size: size * 0.42,
                        color: Colors.grey.shade400,
                      );
                    },
                  )
                : Icon(
                    IconlyBold.profile,
                    size: size * 0.42,
                    color: Colors.grey.shade400,
                  ),
          ),
        ),
        if (showVerifiedBadge && expert.isVerified)
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.verified,
              color: Colors.blue,
              size: 16,
            ),
          ),
      ],
    );
  }
}
