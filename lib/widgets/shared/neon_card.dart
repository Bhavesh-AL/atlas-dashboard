import 'package:flutter/material.dart';
import 'package:atlas_dashboard/app_theme.dart'; // <-- CORRECTED IMPORT

class NeonCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color borderColor;
  final Color shadowColor;

  const NeonCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.borderColor = AppTheme.neonBlue,
    this.shadowColor = AppTheme.neonBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}