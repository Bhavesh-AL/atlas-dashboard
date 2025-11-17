import 'package:flutter/material.dart';
import 'package:atlas_dashboard/app_theme.dart';
import 'package:atlas_dashboard/models/telemetry_models.dart';
import 'package:atlas_dashboard/widgets/shared/glass_card.dart';
import 'package:atlas_dashboard/widgets/shared/info_header.dart';
import 'package:atlas_dashboard/widgets/shared/stat_line.dart';

// This is now a Tabbed page
class SensorsPage extends StatelessWidget {
  final DeviceData device;
  const SensorsPage({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final snapshot = device.latestSnapshot;
    if (snapshot == null) {
      return const Center(child: Text("No sensor data."));
    }

    // --- FIX: Implement Tabbed Layout ---
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // This is the Tab Bar
          GlassCard(
            margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
            padding: const EdgeInsets.all(8),
            child: const TabBar(
              tabs: [
                Tab(text: 'Live Readings'),
                Tab(text: 'All Sensors (Hardware)'),
              ],
              indicatorColor: AppTheme.neonBlue,
              labelColor: AppTheme.neonBlue,
              unselectedLabelColor: Colors.white54,
            ),
          ),
          // This is the Tab Content
          Expanded(
            child: TabBarView(
              children: [
                // Tab 1: Live Readings (Your original UI, but with bug fixes)
                _buildLiveReadings(context, snapshot),
                // Tab 2: Full Sensor List (The missing section)
                _buildSensorList(context, snapshot),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 1: Live Readings ---
  Widget _buildLiveReadings(BuildContext context, TelemetrySnapshot snapshot) {
    final readings = snapshot.sensors.currentReadings;

    // FIX: Use safeMapCast AND lowercase keys
    // The keys in your JSON are lowercase (e.g., 'accelerometer')
    // and they need to be cast safely.
    final accelerometer = safeMapCast(readings['accelerometer']);
    final gyroscope = safeMapCast(readings['gyroscope']);
    final magnetometer = safeMapCast(readings['magnetometer']);
    final light = safeMapCast(readings['light']);
    final proximity = safeMapCast(readings['proximity']);
    final pressure = safeMapCast(readings['pressure']);

    // Helper to get 'values' array, as data is nested
    List<dynamic> getValues(Map<String, dynamic> map, {int numValues = 3}) {
      final values = map['values'] as List<dynamic>? ?? [];
      // Pad with 0.0 if the list is empty or incomplete
      while (values.length < numValues) {
        values.add(0.0);
      }
      return values;
    }

    final accelValues = getValues(accelerometer);
    final gyroValues = getValues(gyroscope);
    final magValues = getValues(magnetometer);
    // Environmental sensors usually have only one value
    final lightValue = getValues(light, numValues: 1).first;
    final proximityValue = getValues(proximity, numValues: 1).first;
    final pressureValue = getValues(pressure, numValues: 1).first;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const InfoHeader(title: "Motion Sensors"),
        GlassCard(
          child: Column(
            children: [
              StatLine(title: "Accel X", value: "${(accelValues[0] as num).toDouble().toStringAsFixed(2)} m/s²", valueColor: AppTheme.neonPink),
              StatLine(title: "Accel Y", value: "${(accelValues[1] as num).toDouble().toStringAsFixed(2)} m/s²", valueColor: AppTheme.neonBlue),
              StatLine(title: "Accel Z", value: "${(accelValues[2] as num).toDouble().toStringAsFixed(2)} m/s²", valueColor: Colors.greenAccent),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            children: [
              StatLine(title: "Gyro X", value: "${(gyroValues[0] as num).toDouble().toStringAsFixed(2)} rad/s", valueColor: AppTheme.neonPink),
              StatLine(title: "Gyro Y", value: "${(gyroValues[1] as num).toDouble().toStringAsFixed(2)} rad/s", valueColor: AppTheme.neonBlue),
              StatLine(title: "Gyro Z", value: "${(gyroValues[2] as num).toDouble().toStringAsFixed(2)} rad/s", valueColor: Colors.greenAccent),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            children: [
              StatLine(title: "Mag X", value: "${(magValues[0] as num).toDouble().toStringAsFixed(2)} μT", valueColor: AppTheme.neonPink),
              StatLine(title: "Mag Y", value: "${(magValues[1] as num).toDouble().toStringAsFixed(2)} μT", valueColor: AppTheme.neonBlue),
              StatLine(title: "Mag Z", value: "${(magValues[2] as num).toDouble().toStringAsFixed(2)} μT", valueColor: Colors.greenAccent),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const InfoHeader(title: "Environmental Sensors"),
        GlassCard(
          child: Column(
            children: [
              StatLine(title: "Light", value: "${(lightValue as num).toDouble().toStringAsFixed(0)} lx", valueColor: Colors.orangeAccent),
              StatLine(title: "Proximity", value: "${(proximityValue as num).toDouble().toStringAsFixed(0)} cm", valueColor: AppTheme.neonBlue),
              StatLine(title: "Pressure", value: "${(pressureValue as num).toDouble().toStringAsFixed(1)} hPa", valueColor: Colors.greenAccent),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 2: Full Sensor List ---
  Widget _buildSensorList(BuildContext context, TelemetrySnapshot snapshot) {
    final List<Sensor> sensorList = snapshot.sensors.sensorList;

    if (sensorList.isEmpty) {
      return const Center(child: Text("No sensor hardware list found.", style: TextStyle(color: Colors.white54)));
    }

    // Wrap the list in a GlassCard for consistent UI
    return GlassCard(
      margin: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: sensorList.length,
        itemBuilder: (context, index) {
          final sensor = sensorList[index];
          return ListTile(
            visualDensity: VisualDensity.compact,
            leading: const Icon(Icons.sensors, color: AppTheme.neonBlue, size: 20),
            title: Text(sensor.name, style: const TextStyle(fontSize: 14)),
            subtitle: Text(
              "${sensor.vendor} | Power: ${sensor.power.toString()}mA",
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            trailing: Text(
              "Type: ${sensor.type}",
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          );
        },
      ),
    );
  }
}