import 'package:atlas_dashboard/widgets/shared/info_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:atlas_dashboard/bloc/dashboard_bloc.dart';
import 'package:atlas_dashboard/widgets/shared/glass_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const InfoHeader(title: "Settings"),
        GlassCard(
          child: ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
            title: const Text('Delete All Snapshots'),
            subtitle: const Text('This will permanently delete all data for the currently selected device.'),
            onTap: () async {
              final confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Deletion'),
                  content: const Text(
                      'Are you sure you want to delete all snapshots for this device? This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                context.read<DashboardBloc>().add(DeleteAllSnapshots());
              }
            },
          ),
        ),
      ],
    );
  }
}
