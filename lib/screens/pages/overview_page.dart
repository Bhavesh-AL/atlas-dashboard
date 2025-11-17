import 'package:atlas_dashboard/app_theme.dart';
import 'package:atlas_dashboard/models/telemetry_models.dart';
import 'package:atlas_dashboard/widgets/dashboard/current_sensors_card.dart';
import 'package:atlas_dashboard/widgets/dashboard/device_info_card.dart';
import 'package:atlas_dashboard/widgets/dashboard/overview_location_card.dart';
import 'package:atlas_dashboard/widgets/dashboard/quick_status_card.dart';
import 'package:atlas_dashboard/widgets/shared/glass_card.dart';
import 'package:atlas_dashboard/widgets/shared/history_charts.dart';
import 'package:atlas_dashboard/widgets/shared/info_header.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';

class OverviewPage extends StatelessWidget {
  final DeviceData device;

  const OverviewPage({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final snapshot = device.latestSnapshot;
    if (snapshot == null) {
      return const Center(
        child: Text(
          "No data available for this device.",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    // Prepare chart data
    final historicalData =
        device.snapshots.values.toList().reversed.take(20).toList();
    final cpuSpots = _getSpots(historicalData, (s) => s.cpuTempC);
    final memSpots = _getSpots(
        historicalData,
        (s) => (s.memory.totalMem > 0)
            ? (1.0 - (s.memory.availMem / s.memory.totalMem)) * 100
            : 0.0);
    final batterySpots = _getSpots(
        historicalData, (s) => s.batteryInfo.capacityPercent.toDouble());
    final networkRxSpots = _getNetworkDeltaSpots(
        historicalData, (s) => s.networkUsage.totalRxBytes);
    final networkTxSpots = _getNetworkDeltaSpots(
        historicalData, (s) => s.networkUsage.totalTxBytes);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Top row: Device Info + Quick Status
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: DeviceInfoCard(
                buildInfo: snapshot.build,
                appInfo: snapshot.appInfo,
                lastUpdate: snapshot.collectedAt,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: QuickStatusCard(snapshot: snapshot),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Second Row: Gauges + Current Sensors
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: GlassCard(
                child: Column(
                  children: [
                    const InfoHeader(title: "Live Gauges"),
                    const SizedBox(height: 8),
                    _buildGauge(context, "RAM Used", snapshot.memory.availMem,
                        snapshot.memory.totalMem, AppTheme.neonBlue),
                    _buildGauge(
                        context,
                        "App Storage",
                        snapshot.appStorage.appDataBytes,
                        snapshot.appStorage.appTotalBytes,
                        Colors.orangeAccent),
                    _buildGauge(
                        context,
                        "Device Storage",
                        snapshot.storage.availableBytes,
                        snapshot.storage.totalBytes,
                        AppTheme.neonPink,
                        invert: true),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: CurrentSensorsCard(
                sensorInfo: snapshot.sensors,
                cpuTempC: snapshot.cpuTempC,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Third Row: Location Map
        const InfoHeader(title: "Current Location"),
        OverviewLocationCard(location: snapshot.location),

        const SizedBox(height: 16),

        // Fourth Row: History
        const InfoHeader(title: "Performance History"),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                // Added padding
                child: Text("CPU Temperature",
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(height: 8),
              // FIX: Added space between title and chart
              HistoryLineChart(
                spotLists: [cpuSpots],
                lineColors: [AppTheme.neonPink],
                yAxisLabel: '°C',
                xAxisLabel: 'Last 20 Snapshots',
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.only(left: 8.0), // Added padding
                child: Text("Memory Usage",
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(height: 8),
              // FIX: Added space between title and chart
              HistoryLineChart(
                spotLists: [memSpots],
                lineColors: [AppTheme.neonBlue],
                maxY: 100,
                minY: 0,
                yAxisLabel: '%',
                xAxisLabel: 'Last 20 Snapshots',
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.only(left: 8.0), // Added padding
                child: Text("Battery Level",
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(height: 8),
              // FIX: Added space between title and chart
              HistoryLineChart(
                spotLists: [batterySpots],
                lineColors: [Colors.greenAccent],
                maxY: 100,
                minY: 0,
                yAxisLabel: '%',
                xAxisLabel: 'Last 20 Snapshots',
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.only(left: 8.0), // Added padding
                child: Text("Network Usage (Bytes per Interval)",
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(height: 8),
              // FIX: Added space between title and chart
              HistoryLineChart(
                spotLists: [networkRxSpots, networkTxSpots],
                lineColors: [AppTheme.neonBlue, AppTheme.neonPink],
                legendTitles: ['Downloaded', 'Uploaded'],
                yAxisLabel: 'Bytes',
                xAxisLabel: 'Last 20 Snapshots',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGauge(
      BuildContext context, String title, int current, int max, Color color,
      {bool invert = false}) {
    double percent = (max == 0) ? 0.0 : (current / max);
    if (invert) percent = 1.0 - percent;

    String currentHuman = (current / 1073741824).toStringAsFixed(2);
    if (max < 1073741824) {
      currentHuman = (current / 1048576).toStringAsFixed(1);
    }

    String centerText;
    if (invert) {
      final usedPercent = (percent * 100).toStringAsFixed(1);
      final freeHuman = (current / 1073741824).toStringAsFixed(2);
      centerText = "$usedPercent% Used ($freeHuman GB Free)";
    } else {
      final usedPercent = (percent * 100).toStringAsFixed(1);
      centerText = "$usedPercent% Used";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            percent: percent.isNaN ? 0.0 : percent.clamp(0.0, 1.0),
            lineHeight: 25.0,
            center: Text(centerText,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                )),
            progressColor: color,
            backgroundColor: Colors.white12,
            barRadius: const Radius.circular(12),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getSpots(
      List<TelemetrySnapshot> data, double Function(TelemetrySnapshot) getY) {
    if (data.isEmpty) return [];
    return data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), getY(entry.value));
    }).toList();
  }

  List<FlSpot> _getNetworkDeltaSpots(
      List<TelemetrySnapshot> data, int Function(TelemetrySnapshot) getValue) {
    List<FlSpot> spots = [];
    if (data.isEmpty) return spots;

    spots.add(const FlSpot(0, 0));
    for (int i = 1; i < data.length; i++) {
      final delta = getValue(data[i]) - getValue(data[i - 1]);
      spots.add(FlSpot(i.toDouble(), delta < 0 ? 0.0 : delta.toDouble()));
    }
    return spots;
  }
}
