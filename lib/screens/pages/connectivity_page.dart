import 'package:flutter/material.dart';
import 'package:atlas_dashboard/app_theme.dart';
import 'package:atlas_dashboard/models/telemetry_models.dart';
import 'package:atlas_dashboard/widgets/shared/info_header.dart';
import 'package:atlas_dashboard/widgets/shared/glass_card.dart';
import 'package:atlas_dashboard/widgets/shared/stat_line.dart';

class ConnectivityPage extends StatelessWidget {
  final TelemetrySnapshot snapshot;
  const ConnectivityPage({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const InfoHeader(title: "Bluetooth"),
        GlassCard(
          borderColor: AppTheme.neonBlue,
          shadowColor: AppTheme.neonBlue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatLine(
                title: 'Supported',
                value: snapshot.bluetooth.supported ? 'Yes' : 'No',
                valueColor: snapshot.bluetooth.supported ? Colors.greenAccent : Colors.redAccent,
              ),
              StatLine(
                title: 'Enabled',
                value: snapshot.bluetooth.enabled ? 'On' : 'Off',
                valueColor: snapshot.bluetooth.enabled ? AppTheme.neonBlue : Colors.white70,
              ),
              const Divider(height: 20),
              Text(
                  "Bonded Devices (${snapshot.bluetooth.bondedDevices.length})",
                  style: Theme.of(context).textTheme.titleMedium
              ),
              if (snapshot.bluetooth.bondedDevices.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("No bonded devices found.", style: TextStyle(color: Colors.white54)),
                )
              else
                ...snapshot.bluetooth.bondedDevices.map((device) => Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Text("• ${device['name'] ?? 'Unknown'} (${device['address']})"),
                )),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const InfoHeader(title: "Cellular & SIM"),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatLine(
                title: 'Carrier',
                value: snapshot.cellularSignals.carrier.isEmpty
                    ? 'N/A'
                    : snapshot.cellularSignals.carrier,
                valueColor: Colors.white70,
              ),
              StatLine(
                title: 'SIM Operator',
                value: snapshot.sim.simOperatorName.isEmpty
                    ? 'N/A'
                    : snapshot.sim.simOperatorName,
                valueColor: Colors.white70,
              ),
              StatLine(
                title: 'SIM Country',
                value: snapshot.sim.simCountryIso.isEmpty
                    ? 'N/A'
                    : snapshot.sim.simCountryIso,
                valueColor: Colors.white70,
              ),
              const Divider(height: 20),
              Text(
                  "Detected Cells (${snapshot.cellularSignals.cells.length})",
                  style: Theme.of(context).textTheme.titleMedium
              ),
              if (snapshot.cellularSignals.cells.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("No cell info available.", style: TextStyle(color: Colors.white54)),
                )
              else
                ...snapshot.cellularSignals.cells.map((cell) => StatLine(
                  title: cell['type'] ?? 'Cell',
                  value: "${cell['dbm'] ?? '?'} dBm",
                  valueColor: (cell['dbm'] as int? ?? -120) > -90 ? Colors.greenAccent : AppTheme.neonPink,
                )),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const InfoHeader(title: "Other Radios"),
        GlassCard(
          borderColor: AppTheme.neonPink,
          shadowColor: AppTheme.neonPink,
          child: Column(
            children: [
              StatLine(
                title: 'NFC Supported',
                value: snapshot.nfc.hardwareSupported ? 'Yes' : 'No',
                valueColor: Colors.white70,
              ),
              StatLine(
                title: 'NFC Enabled',
                value: snapshot.nfc.isEnabled ? 'On' : 'Off',
                valueColor: snapshot.nfc.isEnabled ? AppTheme.neonBlue : Colors.white70,
              ),
              const Divider(height: 16),
              StatLine(
                title: 'VPN Active',
                value: snapshot.vpnInfo.isVpnActive ? 'Yes' : 'No',
                valueColor: snapshot.vpnInfo.isVpnActive ? AppTheme.neonPink : Colors.white70,
              ),
            ],
          ),
        ),
      ],
    );
  }
}