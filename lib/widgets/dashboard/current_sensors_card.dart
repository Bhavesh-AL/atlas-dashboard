import 'package:atlas_dashboard/app_theme.dart';
import 'package:atlas_dashboard/models/telemetry_models.dart';
import 'package:flutter/material.dart';

import '../shared/glass_card.dart';
import '../shared/info_header.dart';
import '../shared/sensor_gauge.dart';



class CurrentSensorsCard extends StatelessWidget {
  final SensorInfo sensorInfo;
  final double cpuTempC; // FIX: Added CPU temp

  const CurrentSensorsCard({
    super.key,
    required this.sensorInfo,
    required this.cpuTempC, // FIX: Added CPU temp
  });

  @override
  Widget build(BuildContext context) {
    final readings = sensorInfo.currentReadings;

    // FIX: Use safeMapCast to prevent the TypeError.
    final accelerometer = safeMapCast(readings['accelerometer']);
    final gyroscope = safeMapCast(readings['gyroscope']);
    final light = safeMapCast(readings['light']);
    final proximity = safeMapCast(readings['proximity']);

    // Helper to safely get values
    List<double> getValues(Map<String, dynamic> sensorData, int expectedLength) {
      final values = (sensorData['values'] as List<dynamic>? ?? []);
      List<double> result = [];
      for (var v in values) {
        if (v is num) {
          result.add(v.toDouble());
        }
      }
      // Ensure list has correct length
      while (result.length < expectedLength) {
        result.add(0.0);
      }
      return result;
    }

    // These will now receive correctly typed maps
    final accelValues = getValues(accelerometer, 3);
    final gyroValues = getValues(gyroscope, 3);
    final lightValue = getValues(light, 1).first;
    final proximityValue = getValues(proximity, 1).first;

    return GlassCard(
      child: Column(
        children: [
          const InfoHeader(title: "Live Sensor Data"),
          if (readings.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("No current sensor readings available.", style: TextStyle(color: Colors.white54)),
            ),

          if (readings.isNotEmpty)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SensorGauge(
                      label: "Accel X",
                      value: accelValues[0],
                      unit: "m/s²",
                      color: AppTheme.neonPink,
                    ),
                    SensorGauge(
                      label: "Accel Y",
                      value: accelValues[1],
                      unit: "m/s²",
                      color: AppTheme.neonBlue,
                    ),
                    SensorGauge(
                      label: "Accel Z",
                      value: accelValues[2],
                      unit: "m/s²",
                      color: Colors.greenAccent,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SensorGauge(
                      label: "Gyro X",
                      value: gyroValues[0],
                      unit: "rad/s",
                      minValue: -5,
                      maxValue: 5,
                      color: AppTheme.neonPink,
                    ),
                    SensorGauge(
                      label: "Gyro Y",
                      value: gyroValues[1],
                      unit: "rad/s",
                      minValue: -5,
                      maxValue: 5,
                      color: AppTheme.neonBlue,
                    ),
                    SensorGauge(
                      label: "Gyro Z",
                      value: gyroValues[2],
                      unit: "rad/s",
                      minValue: -5,
                      maxValue: 5,
                      color: Colors.greenAccent,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // FIX: Changed from Row to GridView to fit 3 items
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2, // Taller items
                  children: [
                    SensorSimpleValue(
                      label: "Light",
                      value: "${lightValue.toStringAsFixed(0)} lx",
                      icon: Icons.lightbulb_outline,
                      color: Colors.orangeAccent,
                    ),
                    SensorSimpleValue(
                      label: "Proximity",
                      value: "${proximityValue.toStringAsFixed(0)} cm",
                      icon: Icons.personal_video_outlined,
                      color: AppTheme.neonBlue,
                    ),
                    // FIX: Added CPU Temp widget
                    SensorSimpleValue(
                      label: "CPU Temp",
                      value: "${cpuTempC.toStringAsFixed(1)} °C",
                      icon: Icons.thermostat,
                      color: AppTheme.neonPink,
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}