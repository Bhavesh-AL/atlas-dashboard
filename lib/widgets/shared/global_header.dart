import 'dart:ui';
import 'package:atlas_dashboard/app_theme.dart';
import 'package:atlas_dashboard/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GlobalHeader extends StatelessWidget {
  const GlobalHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.glassColor.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(color: AppTheme.neonBlue.withOpacity(0.2), width: 1.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ATLAS Dashboard', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
              if (authState is Authenticated) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${authState.user.email} (${authState.user.role.name})',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      tooltip: 'Logout',
                      onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
