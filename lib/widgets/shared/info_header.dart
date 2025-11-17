import 'package:flutter/material.dart';
import 'package:atlas_dashboard/app_theme.dart';

class InfoHeader extends StatelessWidget {
  final String title;
  const InfoHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.neonPink,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(color: AppTheme.neonPink.withOpacity(0.4), thickness: 1.5, height: 12),
        ],
      ),
    );
  }
}