import 'dart:async';
import 'package:atlas_dashboard/models/telemetry_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../shared/glass_card.dart';
import '../shared/stat_line.dart';

class DeviceInfoCard extends StatefulWidget {
  final BuildInfo buildInfo;
  final AppInfo appInfo;
  final DateTime lastUpdate;

  const DeviceInfoCard({
    super.key,
    required this.buildInfo,
    required this.appInfo,
    required this.lastUpdate,
  });

  @override
  State<DeviceInfoCard> createState() => _DeviceInfoCardState();
}

class _DeviceInfoCardState extends State<DeviceInfoCard> {
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
  void didUpdateWidget(covariant DeviceInfoCard oldWidget) {
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
    if (!mounted) return;
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
    final installTime = DateFormat('MMM d, yyyy').format(widget.appInfo.firstInstallTime);
    final textTheme = Theme.of(context).textTheme;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FIX: Added Live Status Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.buildInfo.model,
                  style: textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.circle, color: Colors.greenAccent, size: 12),
                  const SizedBox(width: 8),
                  Text(
                    _timeAgo,
                    style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          Text(
            '${widget.buildInfo.brand} // ${widget.buildInfo.manufacturer}',
            style: textTheme.titleMedium,
          ),
          const Divider(height: 24),
          StatLine(
            title: 'Operating System',
            value: 'Android ${widget.buildInfo.release} (SDK ${widget.buildInfo.sdkInt})',
            valueColor: Colors.white70,
          ),
          StatLine(
            title: 'SoC',
            value: '${widget.buildInfo.socManufacturer} ${widget.buildInfo.socModel}',
            valueColor: Colors.white70,
          ),
          const Divider(height: 24),
          StatLine(
            title: 'App Package',
            value: widget.appInfo.packageName,
            valueColor: Colors.white70,
          ),
          StatLine(
            title: 'App Version',
            value: widget.appInfo.versionName,
            valueColor: Colors.white70,
          ),
          StatLine(
            title: 'App Install Date',
            value: installTime,
            valueColor: Colors.white70,
          ),
        ],
      ),
    );
  }
}
