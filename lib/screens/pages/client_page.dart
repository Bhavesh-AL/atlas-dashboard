import 'package:atlas_dashboard/models/telemetry_models.dart';
import 'package:atlas_dashboard/screens/pages/client_provided_page.dart';
import 'package:flutter/material.dart';

class ClientPage extends StatelessWidget {
  final TelemetrySnapshot snapshot;
  const ClientPage({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return ClientProvidedPage(clientProvidedData: snapshot.clientProvided);
  }
}
