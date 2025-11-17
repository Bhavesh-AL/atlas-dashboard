import 'package:atlas_dashboard/app_theme.dart';
import 'package:atlas_dashboard/models/telemetry_models.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../shared/glass_card.dart';

class QuickStatusCard extends StatelessWidget {
  final TelemetrySnapshot snapshot;
  const QuickStatusCard({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final battery = snapshot.batteryInfo;
    final volumes = snapshot.audio.volumes;

    final musicMax = volumes['music_max_level'] as int? ?? 15;
    final musicLevel = volumes['music_level'] as int? ?? 0;
    final musicPercent = (musicMax == 0) ? 0.0 : (musicLevel / musicMax);

    final ringMax = volumes['ring_max_level'] as int? ?? 15;
    final ringLevel = volumes['ring_level'] as int? ?? 0;
    final ringPercent = (ringMax == 0) ? 0.0 : (ringLevel / ringMax);


    return GlassCard(
      padding: const EdgeInsets.all(12), // Denser padding
      child: Column(
        children: [
          // Battery
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                const Icon(Icons.battery_full, color: AppTheme.neonPink, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: LinearPercentIndicator(
                    percent: (battery.capacityPercent / 100.0).clamp(0.0, 1.0),
                    lineHeight: 25.0, // FIX: Was 20.0
                    center: Text(
                      "${battery.capacityPercent}% (${battery.health})",
                      // FIX: Added style
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    progressColor: AppTheme.neonPink,
                    backgroundColor: Colors.white12,
                    barRadius: const Radius.circular(12), // FIX: Was 10
                  ),
                ),
              ],
            ),
          ),
          // Volumes
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                const Icon(Icons.volume_up, color: AppTheme.neonBlue, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: LinearPercentIndicator(
                    percent: musicPercent.clamp(0.0, 1.0),
                    lineHeight: 18.0, // FIX: Was 12.0
                    center: const Text(
                      "Music",
                      // FIX: Added style
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    progressColor: AppTheme.neonBlue,
                    backgroundColor: Colors.white12,
                    barRadius: const Radius.circular(9), // FIX: Was 6
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LinearPercentIndicator(
                    percent: ringPercent.clamp(0.0, 1.0),
                    lineHeight: 18.0, // FIX: Was 12.0
                    center: const Text(
                      "Ring",
                      // FIX: Added style
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    progressColor: AppTheme.neonBlue,
                    backgroundColor: Colors.white12,
                    barRadius: const Radius.circular(9), // FIX: Was 6
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 16),
          // Toggles
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.8,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: [
              _StatusIcon(
                icon: Icons.security,
                label: "Rooted",
                enabled: snapshot.securityInfo.rootDetection.isRooted,
                isWarning: true,
              ),
              _StatusIcon(
                icon: Icons.usb,
                label: "USB Debug",
                enabled: snapshot.systemSettings.usbDebuggingEnabled,
                isWarning: true,
              ),
              _StatusIcon(
                icon: Icons.vpn_lock,
                label: "VPN Active",
                enabled: snapshot.vpnInfo.isVpnActive,
              ),
              _StatusIcon(
                icon: Icons.airplanemode_active,
                label: "Airplane Mode",
                enabled: snapshot.systemSettings.airplaneModeEnabled,
              ),
              _StatusIcon(
                icon: Icons.battery_saver,
                label: "Battery Saver",
                enabled: snapshot.systemSettings.batterySaverEnabled,
              ),
              _StatusIcon(
                icon: Icons.dark_mode,
                label: "Dark Mode",
                enabled: snapshot.systemSettings.darkModeEnabled,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final bool isWarning;

  const _StatusIcon({
    required this.icon,
    required this.label,
    required this.enabled,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? (isWarning ? AppTheme.neonPink : AppTheme.neonBlue)
        : Colors.white38;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color, fontSize: 10),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}