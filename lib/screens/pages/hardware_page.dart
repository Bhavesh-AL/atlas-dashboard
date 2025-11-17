import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:atlas_dashboard/app_theme.dart';
import 'package:atlas_dashboard/models/telemetry_models.dart';
import 'package:atlas_dashboard/widgets/shared/info_header.dart';
import 'package:atlas_dashboard/widgets/shared/glass_card.dart';
import 'package:atlas_dashboard/widgets/shared/stat_line.dart';



class HardwarePage extends StatelessWidget {
  final TelemetrySnapshot snapshot;
  const HardwarePage({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    // V1: Handle case where there is no data yet
    // Note: This page is called differently, so we check snapshot directly.
    // If this page were ever loaded from a tab with a null-able device,
    // we would check device.latestSnapshot instead.

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const InfoHeader(title: "Display"),
        GlassCard(
          child: Column(
            children: [
              StatLine(
                title: 'Resolution',
                value: '${snapshot.display.width} x ${snapshot.display.height}',
                valueColor: Colors.white70,
              ),
              StatLine(
                title: 'Refresh Rate',
                value: '${snapshot.display.refreshRate.toStringAsFixed(0)} Hz',
                valueColor: AppTheme.neonBlue,
              ),
              StatLine(
                title: 'Density',
                value: '${snapshot.display.dpi} DPI',
                valueColor: Colors.white70,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        const InfoHeader(title: "Audio"),
        GlassCard(
          borderColor: AppTheme.neonPink,
          shadowColor: AppTheme.neonPink,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatLine(
                title: 'Ringer Mode',
                value: snapshot.audio.ringerMode,
                valueColor: AppTheme.neonPink,
              ),
              const Divider(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text("Volumes", style: Theme.of(context).textTheme.titleMedium),
              ),
              ...snapshot.audio.volumes.entries.map((entry) {
                final maxLevelKey = '${entry.key.replaceAll('_level', '')}_max_level';
                final maxLevel = snapshot.audio.volumes[maxLevelKey] as int? ?? 15;
                final currentLevel = entry.value as int? ?? 0;
                final percent = (maxLevel == 0) ? 0.0 : (currentLevel / maxLevel).clamp(0.0, 1.0);

                // Only show entries that are volume levels
                if (!entry.key.contains('_level')) return const SizedBox.shrink();

                return Padding(
                  // FIX: Added more vertical padding
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.key.replaceAll('_level', '').toUpperCase(), style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 4), // Added space
                      LinearPercentIndicator(
                        percent: percent,
                        lineHeight: 22.0, // FIX: Was 14.0
                        center: Text(
                          "${(percent * 100).toStringAsFixed(0)}%",
                          // FIX: Added style
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        progressColor: AppTheme.neonBlue,
                        backgroundColor: Colors.white12,
                        barRadius: const Radius.circular(11), // FIX: Was 7
                      ),
                    ],
                  ),
                );
              }),
              const Divider(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text("Audio Devices", style: Theme.of(context).textTheme.titleMedium),
              ),
              // FIX: Use a Column of ListTiles for better alignment
              Column(
                children: snapshot.audio.devices.map((device) => ListTile(
                  visualDensity: VisualDensity.compact,
                  title: Text(device['product_name'] ?? 'Unknown Device'),
                  subtitle: Text(device['type'] ?? 'N/A'),
                  trailing: Icon(
                    device['is_sink'] == true ? Icons.volume_up : Icons.mic,
                    color: AppTheme.neonBlue,
                  ),
                )).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        const InfoHeader(title: "Cameras"),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!snapshot.camera.hasData)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                        snapshot.camera.reason,
                        style: const TextStyle(color: Colors.white54)
                    ),
                  ),
                ),
              // FIX: Use a Column of ListTiles
              if (snapshot.camera.hasData)
                Column(
                  children: snapshot.camera.cameras.map((camera) => ListTile(
                    leading: Icon(
                      camera['facing'] == 'FRONT' ? Icons.camera_front : Icons.camera_rear,
                      color: AppTheme.neonBlue,
                    ),
                    title: Text("Camera ${camera['id']} (${camera['facing']})"),
                    subtitle: Text("${camera['megapixels']} MP (${camera['resolution']})"),
                  )).toList(),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        const InfoHeader(title: "Vibrator"),
        GlassCard(
          borderColor: AppTheme.neonPink,
          shadowColor: AppTheme.neonPink,
          child: Column(
            children: [
              StatLine(
                title: 'Hardware Supported',
                value: snapshot.vibrator.hardwareSupported ? 'Yes' : 'No',
                valueColor: Colors.white70,
              ),
              StatLine(
                title: 'Amplitude Control',
                value: snapshot.vibrator.hasAmplitudeControl ? 'Yes' : 'No',
                valueColor: Colors.white70,
              ),
            ],
          ),
        ),
      ],
    );
  }
}