import 'package:atlas_dashboard/app_theme.dart';
import 'package:atlas_dashboard/models/telemetry_models.dart';
import 'package:atlas_dashboard/widgets/shared/glass_card.dart';
import 'package:atlas_dashboard/widgets/shared/history_charts.dart';
import 'package:atlas_dashboard/widgets/shared/info_header.dart';
import 'package:atlas_dashboard/widgets/shared/stat_line.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';



class SystemPage extends StatelessWidget {
  final DeviceData device;
  const SystemPage({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final snapshot = device.latestSnapshot; // V1: Remove '!' for safety

    // V1: Handle case where there is no data yet
    if (snapshot == null) {
      return const Center(
        child: Text(
          "No system data available.",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    final historicalData = device.snapshots.values.toList().reversed.take(20).toList();
    final pssSpots = historicalData.asMap().entries.map((entry) {
      final pssKb = entry.value.appsMemory.totalPssKb;
      return FlSpot(entry.key.toDouble(), pssKb / 1024.0); // Convert to MB
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const InfoHeader(title: "CPU & GPU"),
        GlassCard(
          child: Column(
            children: [
              StatLine(
                title: 'CPU Cores',
                value: '${snapshot.cpuInfo.coreCount} Cores',
                valueColor: AppTheme.neonBlue,
              ),
              StatLine(
                title: 'Current CPU Temp',
                value: '${snapshot.cpuTempC.toStringAsFixed(1)}°C',
                valueColor: AppTheme.neonPink,
              ),
              StatLine(
                title: 'GPU Renderer',
                value: snapshot.gpuInfo.eglRenderer,
                valueColor: Colors.white70,
              ),
              StatLine(
                title: 'GPU Vendor',
                value: snapshot.gpuInfo.eglVendor,
                valueColor: Colors.white70,
              ),
              const Divider(height: 20),

              // FIX: Replaced the ugly GridView with a clean 2-column layout
              _buildCpuCoreList(snapshot.cpuInfo.cores),

            ],
          ),
        ),

        const SizedBox(height: 16),
        const InfoHeader(title: "Memory & Storage"),
        _buildStorageCard(context, snapshot.appStorage, snapshot.storage),
        const SizedBox(height: 16),
        _buildAppMemoryCard(context, snapshot.appsMemory, pssSpots),

        const SizedBox(height: 16),
        const InfoHeader(title: "System Settings"),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              _buildSettingToggle(context, 'Airplane Mode', snapshot.systemSettings.airplaneModeEnabled),
              _buildSettingToggle(context, 'Auto Rotate', snapshot.systemSettings.autoRotateEnabled),
              _buildSettingToggle(context, 'Battery Saver', snapshot.systemSettings.batterySaverEnabled),
              _buildSettingToggle(context, 'Dark Mode', snapshot.systemSettings.darkModeEnabled),
            ],
          ),
        ),
      ],
    );
  }

  // FIX: Added this new helper widget to build the core list
  Widget _buildCpuCoreList(List<Map<String, dynamic>> cores) {
    if (cores.isEmpty) {
      return const Text("CPU core data not available.", style: TextStyle(color: Colors.white54));
    }

    List<Widget> rows = [];
    // Iterate 2 at a time to build rows
    for (int i = 0; i < cores.length; i += 2) {
      // Core 1 (e.g., Core 0)
      final core1 = cores[i];
      final core1Widget = StatLine(
        title: 'Core $i',
        value: core1['cur_freq_human'] as String? ?? 'N/A',
        valueColor: AppTheme.neonBlue.withOpacity(0.8),
      );

      // Core 2 (e.g., Core 1)
      Widget core2Widget;
      if (i + 1 < cores.length) {
        final core2 = cores[i+1];
        core2Widget = StatLine(
          title: 'Core ${i+1}',
          value: core2['cur_freq_human'] as String? ?? 'N/A',
          valueColor: AppTheme.neonBlue.withOpacity(0.8),
        );
      } else {
        core2Widget = Container(); // Empty space if odd number of cores
      }

      // Add the row
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Expanded(child: core1Widget),
              const SizedBox(width: 16), // Gutter between columns
              Expanded(child: core2Widget),
            ],
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildStorageCard(BuildContext context, AppStorage appStorage, DeviceStorageInfo deviceStorage) {
    final appDataPercent = (appStorage.appTotalBytes > 0) ? (appStorage.appDataBytes / appStorage.appTotalBytes) : 0.0;
    final deviceDataPercent = deviceStorage.percentUsed;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("App Storage (com.al.atlas.client)", style: Theme.of(context).textTheme.titleMedium),
          _buildGauge(context, "Data", appDataPercent, Colors.orangeAccent),
          StatLine(title: "App Data", value: "${(appStorage.appDataBytes / 1048576).toStringAsFixed(2)} MB", valueColor: Colors.white70),
          StatLine(title: "App Cache", value: "${(appStorage.appCacheBytes / 1024).toStringAsFixed(2)} KB", valueColor: Colors.white70),
          StatLine(title: "App Total", value: "${(appStorage.appTotalBytes / 1048576).toStringAsFixed(2)} MB", valueColor: Colors.white70),

          const Divider(height: 20),

          Text("Device Storage (${deviceStorage.path})", style: Theme.of(context).textTheme.titleMedium),
          _buildGauge(context, "Used", deviceDataPercent, AppTheme.neonPink),
          StatLine(title: "Available", value: "${(deviceStorage.availableBytes / 1073741824).toStringAsFixed(2)} GB", valueColor: Colors.white70),
          StatLine(title: "Total", value: "${(deviceStorage.totalBytes / 1073741824).toStringAsFixed(2)} GB", valueColor: Colors.white70),
        ],
      ),
    );
  }

  Widget _buildAppMemoryCard(BuildContext context, AppsMemoryInfo memInfo, List<FlSpot> pssSpots) {
    final process = memInfo.processes.firstOrNull ?? {};
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Application Process Memory", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          StatLine(title: "Process Name", value: process['processName'] ?? 'N/A', valueColor: Colors.white70),
          StatLine(title: "Total PSS", value: "${process['totalPssKb'] ?? 0} KB", valueColor: AppTheme.neonBlue),
          StatLine(title: "Native PSS", value: "${process['nativePssKb'] ?? 0} KB", valueColor: Colors.white70),
          StatLine(title: "Dalvik PSS", value: "${process['dalvikPssKb'] ?? 0} KB", valueColor: Colors.white70),
          StatLine(title: "Other PSS", value: "${process['otherPssKb'] ?? 0} KB", valueColor: Colors.white70),
          const Divider(height: 20),

          Text("App Memory History (PSS in MB)", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8), // FIX: Added space

          HistoryLineChart(
            spotLists: [pssSpots], // FIX: Corrected parameter
            lineColors: [AppTheme.neonBlue], // FIX: Corrected parameter
            yAxisLabel: 'MB',
            xAxisLabel: 'Last 20 Snapshots', // FIX: Added label
          ),
        ],
      ),
    );
  }

  // FIX: Updated to be thicker and cleaner
  Widget _buildGauge(BuildContext context, String title, double percent, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: LinearPercentIndicator(
        percent: percent.isNaN ? 0.0 : percent.clamp(0.0, 1.0),
        lineHeight: 25.0, // FIX: Was 18.0
        center: Text(
            "${(percent * 100).toStringAsFixed(1)}% $title",
            style: const TextStyle( // FIX: Added style
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            )
        ),
        backgroundColor: Colors.white12,
        progressColor: color,
        barRadius: const Radius.circular(12), // FIX: Was 8
      ),
    );
  }

  // FIX: Replaced Row with ListTile for a cleaner look
  Widget _buildSettingToggle(BuildContext context, String title, bool value) {
    return ListTile(
      visualDensity: VisualDensity.compact, // Makes it tighter
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      trailing: Switch(
        value: value,
        onChanged: null,
        activeColor: AppTheme.neonPink,
        inactiveThumbColor: Colors.grey[700],
        inactiveTrackColor: Colors.grey[850],
      ),
    );
  }
}