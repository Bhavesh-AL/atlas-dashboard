import 'package:atlas_dashboard/app_theme.dart';
import 'package:atlas_dashboard/bloc/auth_bloc.dart';
import 'package:atlas_dashboard/models/user_models.dart';
import 'package:atlas_dashboard/widgets/shared/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _clientIdController = TextEditingController();
  Role _selectedRole = Role.client;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is UserCreationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User created successfully!')),
          );
          // Since this screen is part of the IndexedStack, we can't pop.
          // Instead, we should ideally switch the index of the parent ManagementDashboardScreen.
          // For now, we just clear the fields.
          _emailController.clear();
          _passwordController.clear();
          _clientIdController.clear();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Create New User', style: theme.textTheme.headlineSmall),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (value) =>
                              (value?.isEmpty ?? true) ? 'Please enter an email' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (value) =>
                              (value?.isEmpty ?? true) ? 'Please enter a password' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<Role>(
                          value: _selectedRole,
                          items: Role.values
                              .map((role) => DropdownMenuItem(value: role, child: Text(role.name)))
                              .toList(),
                          onChanged: (value) => setState(() => _selectedRole = value!),
                          decoration: const InputDecoration(labelText: 'Role'),
                        ),
                        const SizedBox(height: 16),
                        if (_selectedRole == Role.client)
                          TextFormField(
                            controller: _clientIdController,
                            decoration: const InputDecoration(labelText: 'Client ID'),
                            validator: (value) =>
                                (_selectedRole == Role.client && (value?.isEmpty ?? true))
                                    ? 'Please enter a client ID'
                                    : null,
                          ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: AppTheme.getElevatedButtonStyle(theme),
                            icon: const Icon(Icons.person_add),
                            label: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Text('Create User'),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(
                                      CreateUser(
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text.trim(),
                                        role: _selectedRole,
                                        clientId: _selectedRole == Role.client
                                            ? _clientIdController.text.trim()
                                            : null,
                                      ),
                                    );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
