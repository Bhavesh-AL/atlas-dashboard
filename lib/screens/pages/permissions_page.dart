import 'package:atlas_dashboard/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:atlas_dashboard/models/telemetry_models.dart';
import 'package:atlas_dashboard/widgets/shared/searchable_datatable.dart';

class PermissionsPage extends StatelessWidget {
  final TelemetrySnapshot snapshot;
  const PermissionsPage({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final permissions = snapshot.permissionInfo;

    final grantedRows = permissions.grantedPermissions
        .map((app) => DataRow(cells: [DataCell(Text(app))]))
        .toList();

    final deniedRows = permissions.deniedPermissions
        .map((app) => DataRow(cells: [DataCell(Text(app))]))
        .toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            indicatorColor: Colors.greenAccent,
            labelColor: Colors.greenAccent,
            tabs: [
              Tab(text: 'Granted (${permissions.grantedPermissions.length})'),
              Tab(text: 'Denied (${permissions.deniedPermissions.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                SearchableDataTable(
                  columns: const [DataColumn(label: Text('Permission Name'))],
                  allRows: grantedRows,
                ),
                SearchableDataTable(
                  columns: const [DataColumn(label: Text('Permission Name'))],
                  allRows: deniedRows,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}