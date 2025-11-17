import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:atlas_dashboard/app_theme.dart';

class GlassNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const GlassNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: NavigationRail(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          labelType: NavigationRailLabelType.all,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: Text('Overview'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.developer_board_outlined),
              selectedIcon: Icon(Icons.developer_board),
              label: Text('System'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.wifi_outlined),
              selectedIcon: Icon(Icons.wifi),
              label: Text('Network'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.bluetooth_connected_outlined),
              selectedIcon: Icon(Icons.bluetooth_connected),
              label: Text('Connect'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.camera_alt_outlined),
              selectedIcon: Icon(Icons.camera_alt),
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
              icon: Icon(Icons.video_camera_back_outlined),
              selectedIcon: Icon(Icons.video_camera_back),
              label: Text('Codecs'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.policy_outlined),
              selectedIcon: Icon(Icons.policy),
              label: Text('Perms'),
            ),
            // --- NEW USB ---
            NavigationRailDestination(
              icon: Icon(Icons.usb_outlined),
              selectedIcon: Icon(Icons.usb),
              label: Text('USB'),
            ),
            // --- END NEW ---
          ],
        ),
      ),
    );
  }
}