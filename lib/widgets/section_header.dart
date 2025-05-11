import 'package:flutter/material.dart';

Widget buildSectionHeader(
  BuildContext context,
  String title,
  String actionText, {
  VoidCallback? onViewAllPressed,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      TextButton(
        onPressed: onViewAllPressed ?? () {},
        child: Text(
          actionText,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}
