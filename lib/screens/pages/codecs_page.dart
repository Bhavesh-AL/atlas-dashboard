import 'package:atlas_dashboard/app_theme.dart';
import 'package:atlas_dashboard/models/telemetry_models.dart';
import 'package:atlas_dashboard/widgets/shared/glass_card.dart';
import 'package:flutter/material.dart';

class CodecsPage extends StatelessWidget {
  final TelemetrySnapshot snapshot;
  const CodecsPage({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final codecs = snapshot.mediaCodecs;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            indicatorColor: AppTheme.neonBlue,
            labelColor: AppTheme.neonBlue,
            tabs: [
              Tab(text: 'Decoders (${codecs.decoders.length})'),
              Tab(text: 'Encoders (${codecs.encoders.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildCodecList(context, codecs.decoders, AppTheme.neonBlue),
                _buildCodecList(context, codecs.encoders, AppTheme.neonPink),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodecList(BuildContext context, List<Codec> codecs, Color color) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: codecs.length,
      itemBuilder: (context, index) {
        final codec = codecs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            borderColor: color.withOpacity(0.5),
            shadowColor: color.withOpacity(0.05),
            child: ExpansionTile(
              title: Text(
                codec.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Supports ${codec.supportedTypes.length} types",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              childrenPadding: const EdgeInsets.all(16).copyWith(top: 0),
              children: [
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: codec.supportedTypes.map((type) => Chip(
                    label: Text(type, style: Theme.of(context).textTheme.bodySmall),
                    backgroundColor: AppTheme.cardColor,
                    side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  )).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}