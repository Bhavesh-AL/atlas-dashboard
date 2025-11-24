import 'dart:ui';
import 'package:atlas_dashboard/app_theme.dart';
import 'package:flutter/material.dart';

void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      final theme = Theme.of(context);
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: AppTheme.cardColor.withOpacity(0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.redAccent.withOpacity(0.7), width: 2),
          ),
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent),
              const SizedBox(width: 12),
              Text('Error', style: theme.textTheme.titleLarge?.copyWith(color: Colors.redAccent)),
            ],
          ),
          content: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
          actions: [
            ElevatedButton(
              style: AppTheme.getElevatedButtonStyle(theme).copyWith(
                backgroundColor: MaterialStateProperty.all(Colors.redAccent),
              ),
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}
