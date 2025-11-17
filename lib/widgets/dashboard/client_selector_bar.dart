import 'package:atlas_dashboard/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/dashboard_bloc.dart';
import '../shared/neon_card.dart';

class ClientSelectorBar extends StatelessWidget {
  final DashboardLoaded state;
  const ClientSelectorBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderColor: AppTheme.neonPink,
      shadowColor: AppTheme.neonPink,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "LIVE DATA //",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.neonPink,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              _buildDropdown(
                context,
                'Client',
                state.selectedClientId,
                state.data.clients.keys.toList(),
                    (newId) {
                  if (newId != null) {
                    context.read<DashboardBloc>().add(SelectClient(newId));
                  }
                },
              ),
              const SizedBox(width: 16),
              _buildDropdown(
                context,
                'Device',
                state.selectedDeviceId,
                state.data.clients[state.selectedClientId]?.devices.keys.toList() ?? [],
                    (newId) {
                  if (newId != null) {
                    context.read<DashboardBloc>().add(SelectDevice(newId));
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
      BuildContext context,
      String title,
      String? selectedValue,
      List<String> items,
      ValueChanged<String?> onChanged,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodySmall),
        Container(
          constraints: const BoxConstraints(minWidth: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              dropdownColor: Theme.of(context).cardColor,
              style: Theme.of(context).textTheme.bodyMedium,
              items: items
                  .map((String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ))
                  .toList(),
              onChanged: items.isNotEmpty ? onChanged : null,
              hint: Text('Select $title', style: const TextStyle(color: Colors.white54)),
              icon: const Icon(Icons.arrow_drop_down, color: AppTheme.neonBlue),
            ),
          ),
        ),
      ],
    );
  }
}