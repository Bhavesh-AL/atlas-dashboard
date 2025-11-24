import 'package:atlas_dashboard/bloc/auth_bloc.dart';
import 'package:atlas_dashboard/bloc/dashboard_bloc.dart';
import 'package:atlas_dashboard/dashboard/dashboard_screen.dart';
import 'package:atlas_dashboard/models/user_models.dart';
import 'package:atlas_dashboard/screens/auth/login_screen.dart';
import 'package:atlas_dashboard/screens/management/management_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardWrapper extends StatelessWidget {
  const DashboardWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is Authenticated) {
          if (authState.user.role == Role.admin || authState.user.role == Role.moderator) {
            return const ManagementDashboardScreen();
          } else {
            return BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, dashboardState) {
                if (dashboardState is DashboardLoaded) {
                  final client = dashboardState.data.clients[authState.user.clientId];
                  if (client != null && !client.isEnabled) {
                    return const Center(
                      child: Text('Your account has been disabled. Please contact support.'),
                    );
                  }
                }
                return const DashboardScreen();
              },
            );
          }
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
