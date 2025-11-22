import 'package:flutter/material.dart';
import 'package:atlas_dashboard/widgets/shared/glass_card.dart';
import 'package:atlas_dashboard/widgets/shared/stat_line.dart';

class ClientProvidedPage extends StatelessWidget {
  final Map<String, dynamic> clientProvidedData;

  const ClientProvidedPage({super.key, required this.clientProvidedData});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: clientProvidedData.entries.map((entry) {
                return StatLine(
                  title: entry.key,
                  value: entry.value.toString(),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
