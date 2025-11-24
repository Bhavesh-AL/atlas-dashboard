import 'package:atlas_dashboard/bloc/auth_bloc.dart';
import 'package:atlas_dashboard/models/user_models.dart';
import 'package:atlas_dashboard/screens/management/client_management_page.dart';
import 'package:atlas_dashboard/screens/management/create_user_screen.dart';
import 'package:atlas_dashboard/widgets/shared/global_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManagementDashboardScreen extends StatefulWidget {
  const ManagementDashboardScreen({super.key});

  @override
  State<ManagementDashboardScreen> createState() => _ManagementDashboardScreenState();
}

class _ManagementDashboardScreenState extends State<ManagementDashboardScreen> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    UserModel? user;
    if (authState is Authenticated) {
      user = authState.user;
    }

    final pages = [
      const ClientManagementPage(),
      if (user?.role == Role.admin) const CreateUserScreen(),
    ];

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is UserCreationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User created successfully!')),
          );
          setState(() {
            _pageIndex = 0;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Row(
            children: [
              NavigationRail(
                selectedIndex: _pageIndex,
                onDestinationSelected: (index) => setState(() => _pageIndex = index),
                labelType: NavigationRailLabelType.all,
                destinations: [
                  const NavigationRailDestination(
                    icon: Icon(Icons.people_alt_outlined),
                    selectedIcon: Icon(Icons.people_alt),
                    label: Text('Clients'),
                  ),
                  if (user?.role == Role.admin)
                    const NavigationRailDestination(
                      icon: Icon(Icons.person_add_outlined),
                      selectedIcon: Icon(Icons.person_add),
                      label: Text('Create User'),
                    ),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: Column(
                  children: [
                    const GlobalHeader(),
                    Expanded(
                      child: IndexedStack(
                        index: _pageIndex,
                        children: pages,
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
  }
}
