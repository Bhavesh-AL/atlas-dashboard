import 'dart:async';
import 'package:flutter/material.dart';
import 'package:atlas_dashboard/app_theme.dart';
import 'package:atlas_dashboard/models/telemetry_models.dart';

class DeviceSummaryHeader extends StatefulWidget {
  final BuildInfo buildInfo;
  final DateTime lastUpdate;

  const DeviceSummaryHeader({
    super.key,
    required this.buildInfo,
    required this.lastUpdate,
  });

  @override
  State<DeviceSummaryHeader> createState() => _DeviceSummaryHeaderState();
}

class _DeviceSummaryHeaderState extends State<DeviceSummaryHeader> {
  Timer? _timer;
  String _timeAgo = '';

  @override
  void initState() {
    super.initState();
    _updateTimeAgo();
    // Update the "time ago" string every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeAgo();
    });
  }

  @override
  void didUpdateWidget(covariant DeviceSummaryHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastUpdate != oldWidget.lastUpdate) {
      _updateTimeAgo(); // Update immediately on new snapshot
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTimeAgo() {
    final now = DateTime.now().toUtc();
    final difference = now.difference(widget.lastUpdate.toUtc());
    setState(() {
      _timeAgo = _formatDuration(difference);
    });
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) return "just now";

    if (d.inSeconds < 60) {
      return "${d.inSeconds}s ago";
    } else if (d.inMinutes < 60) {
      final s = d.inSeconds % 60;
      return "${d.inMinutes}m ${s}s ago";
    } else {
      final m = d.inMinutes % 60;
      return "${d.inHours}h ${m}m ago";
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.buildInfo.model,
          style: textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "${widget.buildInfo.brand} ${widget.buildInfo.manufacturer}",
          style: textTheme.titleMedium?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.circle, color: Colors.greenAccent, size: 12),
            const SizedBox(width: 8),
            Text(
              "Live",
              style: textTheme.titleMedium?.copyWith(color: Colors.greenAccent),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.schedule, color: Colors.white54, size: 12),
            const SizedBox(width: 4),
            Text(
              _timeAgo, // Display the "time ago" string
              style: textTheme.titleMedium?.copyWith(color: Colors.white54),
            ),
          ],
        ),
      ],
    );
  }
}