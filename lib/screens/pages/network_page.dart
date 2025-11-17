import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:atlas_dashboard/app_theme.dart';
import 'package:atlas_dashboard/models/telemetry_models.dart';
import 'package:atlas_dashboard/widgets/shared/info_header.dart';
import 'package:atlas_dashboard/widgets/shared/glass_card.dart';
import 'package:atlas_dashboard/widgets/shared/stat_line.dart';
import 'package:atlas_dashboard/widgets/shared/history_charts.dart';

class NetworkPage extends StatelessWidget {
  final DeviceData device; // V1: Using your correct DeviceData model
  const NetworkPage({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    // V1: Safely get the latest snapshot
    final snapshot = device.latestSnapshot;

    // V1: Handle case where there is no data yet
    if (snapshot == null) {
      return const Center(
        child: Text(
          "No network data available.",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    // V1: Get data from the snapshot.
    // Your V1 models use non-nullable types with defaults, so we can access directly.
    final wifi = snapshot.wifi;
    final network = snapshot.networkUsage;

    // --- Prepare history data for RSSI ---
    // V1: This logic is correct for your models
    final historicalData = device.snapshots.values.toList().reversed.take(20).toList();
    final rssiSpots = historicalData.asMap().entries.map((entry) {
      double rssi = entry.value.wifi.rssiDbm.toDouble();
      if (rssi == 0) rssi = -100; // Handle 0 (often invalid) as missing
      return FlSpot(entry.key.toDouble(), rssi);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const InfoHeader(title: "Wi-Fi Connection"),
        GlassCard(
          child: Column(
            children: [
              StatLine(
                title: 'Enabled',
                value: wifi.enabled ? 'On' : 'Off',
                valueColor: wifi.enabled ? Colors.greenAccent : Colors.white70,
              ),
              StatLine(
                title: 'SSID',
                value: wifi.ssid.replaceAll('"', ''),
                valueColor: AppTheme.neonBlue,
              ),
              StatLine(
                title: 'BSSID',
                value: wifi.bssid,
                valueColor: Colors.white70,
              ),
              StatLine(
                title: 'IP Address',
                value: wifi.ipAddress,
                valueColor: Colors.white70,
              ),
              StatLine(
                title: 'Link Speed',
                value: '${wifi.linkSpeedMbps} Mbps',
                valueColor: AppTheme.neonBlue,
              ),
              StatLine(
                title: 'Signal (RSSI)',
                value: '${wifi.rssiDbm} dBm',
                valueColor: wifi.rssiDbm > -60 ? Colors.greenAccent : (wifi.rssiDbm > -80 ? Colors.orangeAccent : AppTheme.neonPink),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const InfoHeader(title: "Data Usage (Total)"),
        GlassCard(
          borderColor: AppTheme.neonPink,
          shadowColor: AppTheme.neonPink,
          child: Column(
            children: [
              StatLine(
                title: 'Total Downloaded (Rx)',
                value: network.totalRxHuman,
                valueColor: AppTheme.neonBlue,
              ),
              StatLine(
                title: 'Total Uploaded (Tx)',
                value: network.totalTxHuman,
                valueColor: AppTheme.neonPink,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const InfoHeader(title: "Wi-Fi Signal Strength History"),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FIX: Added padding
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                child: Text("RSSI (dBm) - Last 20 Snapshots", style: Theme.of(context).textTheme.titleMedium),
              ),
              // FIX: Added spacing
              const SizedBox(height: 8),
              HistoryLineChart(
                spotLists: [rssiSpots],
                lineColors: [AppTheme.neonBlue],
                minY: -100,
                maxY: -20,
                yAxisLabel: 'dBm',
                xAxisLabel: 'Last 20 Snapshots', // FIX: Added x-axis label
              ),
            ],
          ),
        ),
      ],
    );
  }
}