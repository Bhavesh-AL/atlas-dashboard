import 'package:atlas_dashboard/models/telemetry_models.dart';
import 'package:atlas_dashboard/widgets/shared/glass_card.dart';
import 'package:atlas_dashboard/widgets/shared/info_header.dart';
import 'package:atlas_dashboard/widgets/shared/stat_line.dart';
import 'package:flutter/material.dart';

class AtlasMetadataCard extends StatelessWidget {
  final AtlasMetadata atlasMetadata;

  const AtlasMetadataCard({super.key, required this.atlasMetadata});

  @override
  Widget build(BuildContext context) {
    final isHighAccuracy = atlasMetadata.mode == 'high_accuracy';
    final icon = isHighAccuracy
        ? Icons.gps_fixed_rounded
        : Icons.visibility_off_outlined;
    final tooltip = isHighAccuracy
        ? 'High Accuracy Mode: Detailed data collection'
        : 'Stealth Mode: Minimal data collection';
    
    final labelStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.9));


    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InfoHeader(title: "ATLAS Metadata"),
          const SizedBox(height: 8),
          StatLine(
            title: 'Collected By',
            value: atlasMetadata.collectedBy,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0), // Mimic StatLine padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Collection Mode', style: labelStyle),
                Tooltip(
                  message: tooltip,
                  child: Icon(
                    icon,
                    size: 30,
                    color: isHighAccuracy ? Theme.of(context).colorScheme.primary : Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
