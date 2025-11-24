import 'package:atlas_dashboard/bloc/auth_bloc.dart';
import 'package:atlas_dashboard/bloc/dashboard_bloc.dart';
import 'package:atlas_dashboard/models/telemetry_models.dart';
import 'package:atlas_dashboard/models/user_models.dart';
import 'package:atlas_dashboard/widgets/shared/error_dialog.dart';
import 'package:atlas_dashboard/widgets/shared/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ClientManagementPage extends StatelessWidget {
  const ClientManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is Authenticated) {
              return BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, dashboardState) {
                  if (dashboardState is DashboardLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (dashboardState is DashboardError) {
                    return Center(child: Text(dashboardState.message));
                  }
                  if (dashboardState is DashboardLoaded) {
                    if (dashboardState.data.clients.isEmpty) {
                      return const Center(child: Text('No client data found.'));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: dashboardState.data.clients.length,
                      itemBuilder: (context, index) {
                        final client = dashboardState.data.clients.values.elementAt(index);
                        final clientUser = authState.allUsers.firstWhere(
                              (user) => user.clientId == client.clientId,
                          orElse: () => const UserModel(uid: '', email: 'N/A', role: Role.client),
                        );
                        return _ClientDetailsCard(client: client, loggedInUser: authState.user, clientUser: clientUser);
                      },
                    );
                  }
                  return const Center(child: Text('No data available.'));
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ));
  }
}

class _ClientDetailsCard extends StatelessWidget {
  final ClientData client;
  final UserModel loggedInUser;
  final UserModel clientUser;

  const _ClientDetailsCard({required this.client, required this.loggedInUser, required this.clientUser});

  void _copyToClipboard(BuildContext context, String text, String entity) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$entity copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Row(
          children: [
            Text(client.clientId, style: theme.textTheme.titleLarge),
            IconButton(
              icon: const Icon(Icons.copy, size: 18), 
              onPressed: () => _copyToClipboard(context, client.clientId, 'Client ID'),
            ),
          ],
        ),
        subtitle: Text(clientUser.email, style: theme.textTheme.bodyMedium),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(client.isEnabled ? 'Enabled' : 'Disabled', style: theme.textTheme.bodyMedium),
            const SizedBox(width: 8),
            Switch(
              value: client.isEnabled,
              onChanged: (loggedInUser.role == Role.admin || loggedInUser.role == Role.moderator)
                  ? (value) => context.read<DashboardBloc>().add(ToggleClientStatus(client.clientId, value))
                  : null,
            ),
          ],
        ),
        children: [
          const Divider(),
          if (client.devices.isEmpty) const ListTile(title: Text('No devices connected.')),
          ...client.devices.values.map((device) {
            final latestSnapshot = device.latestSnapshot;
            final latestUpdate = latestSnapshot != null
                ? DateFormat('MMM d, hh:mm a').format(latestSnapshot.collectedAt.toLocal())
                : 'Never';

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(device.deviceModel, style: theme.textTheme.titleMedium),
                      ),
                      if (loggedInUser.role == Role.admin)
                        IconButton(
                          icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                          tooltip: 'Delete All Data For This Device',
                          onPressed: () => _confirmDeleteDevice(context, client.clientId, device.deviceId),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('ID: ${device.deviceId}', style: theme.textTheme.bodySmall),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 14), 
                        onPressed: () => _copyToClipboard(context, device.deviceId, 'Device ID'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Latest Update: $latestUpdate', style: theme.textTheme.bodySmall),
                  Text('Snapshots: ${device.snapshots.length}', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 8),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _confirmDeleteDevice(BuildContext context, String clientId, String deviceId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete all data for device \'$deviceId\'? This action is permanent.'),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(dialogContext).pop()),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              context.read<DashboardBloc>().add(DeleteDeviceData(clientId: clientId, deviceId: deviceId));
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      ),
    );
  }
}
