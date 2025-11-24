import 'package:atlas_dashboard/app_theme.dart';
import 'package:flutter/material.dart';

class GlassNavigationRail extends StatelessWidget {
  final int? selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const GlassNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.selected,
      destinations: <NavigationRailDestination>[
        _buildDestination(icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard, label: 'Overview', isSelected: selectedIndex == 0),
        _buildDestination(icon: Icons.computer_outlined, selectedIcon: Icons.computer, label: 'System', isSelected: selectedIndex == 1),
        _buildDestination(icon: Icons.network_check_outlined, selectedIcon: Icons.network_check, label: 'Network', isSelected: selectedIndex == 2),
        _buildDestination(icon: Icons.wifi_tethering_outlined, selectedIcon: Icons.wifi_tethering, label: 'Connectivity', isSelected: selectedIndex == 3),
        _buildDestination(icon: Icons.memory_outlined, selectedIcon: Icons.memory, label: 'Hardware', isSelected: selectedIndex == 4),
        _buildDestination(icon: Icons.location_on_outlined, selectedIcon: Icons.location_on, label: 'Location', isSelected: selectedIndex == 5),
        _buildDestination(icon: Icons.apps_outlined, selectedIcon: Icons.apps, label: 'Apps', isSelected: selectedIndex == 6),
        _buildDestination(icon: Icons.sensors_outlined, selectedIcon: Icons.sensors, label: 'Sensors', isSelected: selectedIndex == 7),
        _buildDestination(icon: Icons.movie_filter_outlined, selectedIcon: Icons.movie_filter, label: 'Codecs', isSelected: selectedIndex == 8),
        _buildDestination(icon: Icons.security_outlined, selectedIcon: Icons.security, label: 'Permissions', isSelected: selectedIndex == 9),
        _buildDestination(icon: Icons.usb_outlined, selectedIcon: Icons.usb, label: 'USB', isSelected: selectedIndex == 10),
        _buildDestination(icon: Icons.tune_outlined, selectedIcon: Icons.tune, label: 'Custom', isSelected: selectedIndex == 11),
      ],
    );
  }

  NavigationRailDestination _buildDestination({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isSelected,
  }) {
    return NavigationRailDestination(
      icon: _Indicator(icon: icon, isSelected: false),
      selectedIcon: _Indicator(icon: selectedIcon, isSelected: true),
      label: Text(label),
    );
  }
}

class _Indicator extends StatelessWidget {
  final IconData icon;
  final bool isSelected;

  const _Indicator({required this.icon, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: isSelected
          ? BoxDecoration(
              color: AppTheme.neonBlue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Icon(icon),
    );
  }
}
