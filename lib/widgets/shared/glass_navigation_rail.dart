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
      labelType: NavigationRailLabelType.all,
      destinations: const <NavigationRailDestination>[
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Overview'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.computer_outlined),
          selectedIcon: Icon(Icons.computer),
          label: Text('System'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.network_check_outlined),
          selectedIcon: Icon(Icons.network_check),
          label: Text('Network'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.wifi_tethering_outlined),
          selectedIcon: Icon(Icons.wifi_tethering),
          label: Text('Connectivity'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.memory_outlined),
          selectedIcon: Icon(Icons.memory),
          label: Text('Hardware'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.location_on_outlined),
          selectedIcon: Icon(Icons.location_on),
          label: Text('Location'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.apps_outlined),
          selectedIcon: Icon(Icons.apps),
          label: Text('Apps'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.sensors_outlined),
          selectedIcon: Icon(Icons.sensors),
          label: Text('Sensors'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.movie_filter_outlined),
          selectedIcon: Icon(Icons.movie_filter),
          label: Text('Codecs'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.security_outlined),
          selectedIcon: Icon(Icons.security),
          label: Text('Permissions'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.usb_outlined),
          selectedIcon: Icon(Icons.usb),
          label: Text('USB'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: Text('Client'),
        ),
      ],
    );
  }
}
