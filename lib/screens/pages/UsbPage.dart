import 'package:atlas_dashboard/app_theme.dart';
import 'package:atlas_dashboard/models/telemetry_models.dart';
import 'package:atlas_dashboard/widgets/shared/glass_card.dart';
import 'package:atlas_dashboard/widgets/shared/info_header.dart';
import 'package:flutter/material.dart';

class UsbPage extends StatelessWidget {
  final DeviceData device;
  const UsbPage({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    // --- Get Current Devices ---
    final latestSnapshot = device.latestSnapshot;
    List<UsbDevice> currentDevices = [];
    String? currentError;

    if (latestSnapshot != null) {
      if (latestSnapshot.usb.hasData) {
        currentDevices = latestSnapshot.usb.devices;
      } else {
        // Store the error for the "Current" card
        currentError = latestSnapshot.usb.reason;
      }
    }

    // --- Get Historical Devices ---
    final Set<UsbDevice> allDevices = {};
    String? historicalError;

    // Iterate through all snapshots to find unique devices
    for (final snapshot in device.snapshots.values) {
      if (snapshot.usb.hasData) {
        allDevices.addAll(snapshot.usb.devices);
      } else {
        // Store the most recent error, if any
        historicalError = snapshot.usb.reason;
      }
    }

    final uniqueDevices = allDevices.toList();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // --- Card 1: Currently Connected ---
        const InfoHeader(title: "Currently Connected Devices"),
        GlassCard(
          child: _buildDeviceList(
            context,
            currentDevices,
            currentError,
            "No USB devices currently connected.",
          ),
        ),

        const SizedBox(height: 16),

        // --- Card 2: History ---
        const InfoHeader(title: "USB Device History"),
        GlassCard(
          borderColor: AppTheme.neonPink,
          shadowColor: AppTheme.neonPink,
          child: _buildDeviceList(
            context,
            uniqueDevices,
            historicalError,
            "No USB device history found.",
          ),
        ),
      ],
    );
  }

  // Generic helper to build a list of devices or show an error/empty message
  Widget _buildDeviceList(BuildContext context, List<UsbDevice> devices, String? error, String emptyMessage) {
    // Check for errors (e.g., permission)
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Could not retrieve USB data: $error",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ),
      );
    }

    // Check for empty device list
    if (devices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            emptyMessage,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    // Build the list
    return Column(
      children: devices.map((device) {
        return ListTile(
          leading: const Icon(Icons.usb, color: AppTheme.neonBlue),
          title: Text(device.productName),
          subtitle: Text(device.manufacturerName),
          trailing: Text(
            "VID: ${device.vendorId} | PID: ${device.productId}",
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        );
      }).toList(),
    );
  }
}