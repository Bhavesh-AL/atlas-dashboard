import 'package:atlas_dashboard/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:atlas_dashboard/models/telemetry_models.dart';
import 'package:atlas_dashboard/widgets/shared/searchable_datatable.dart';

class AppsPage extends StatelessWidget {
  final TelemetrySnapshot snapshot;
  const AppsPage({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final packages = snapshot.installedPackages;

    final userAppRows = packages.userApplications
        .map((app) => DataRow(cells: [DataCell(Text(app))]))
        .toList();

    final systemAppRows = packages.systemApplications
        .map((app) => DataRow(cells: [DataCell(Text(app))]))
        .toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            indicatorColor: AppTheme.neonBlue,
            labelColor: AppTheme.neonBlue,
            tabs: [
              Tab(text: 'User Apps (${packages.userAppCount})'),
              Tab(text: 'System Apps (${packages.systemAppCount})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                SearchableDataTable(
                  columns: const [DataColumn(label: Text('Package Name'))],
                  allRows: userAppRows,
                ),
                SearchableDataTable(
                  columns: const [DataColumn(label: Text('Package Name'))],
                  allRows: systemAppRows,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}