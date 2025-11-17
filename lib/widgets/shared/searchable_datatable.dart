import 'package:flutter/material.dart';
import 'package:atlas_dashboard/app_theme.dart';

class SearchableDataTable extends StatefulWidget {
  final List<DataRow> allRows;
  final List<DataColumn> columns;

  const SearchableDataTable({
    super.key,
    required this.allRows,
    required this.columns,
  });

  @override
  State<SearchableDataTable> createState() => _SearchableDataTableState();
}

class _SearchableDataTableState extends State<SearchableDataTable> {
  String _filter = '';
  List<DataRow> _filteredRows = [];

  @override
  void initState() {
    super.initState();
    _filteredRows = widget.allRows;
  }

  @override
  void didUpdateWidget(SearchableDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allRows != widget.allRows) {
      _filterRows();
    }
  }

  void _filterRows() {
    if (_filter.isEmpty) {
      setState(() {
        _filteredRows = widget.allRows;
      });
      return;
    }

    final lowerCaseFilter = _filter.toLowerCase();
    setState(() {
      _filteredRows = widget.allRows.where((row) {
        return row.cells.any((cell) {
          final cellValue = (cell.child as Text).data;
          return cellValue?.toLowerCase().contains(lowerCaseFilter) ?? false;
        });
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Search (${widget.allRows.length} items)...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.neonBlue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.neonBlue),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.neonBlue.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.neonPink, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onChanged: (value) {
              _filter = value;
              _filterRows();
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                columns: widget.columns,
                rows: _filteredRows,
                headingRowColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
                dataRowMinHeight: 40,
                dataRowMaxHeight: 40,
                dataTextStyle: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}