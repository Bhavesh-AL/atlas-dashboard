import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:atlas_dashboard/app_theme.dart';
import 'package:atlas_dashboard/bloc/dashboard_bloc.dart';

class LiveStatusHeader extends StatelessWidget {
  final DashboardLoaded state;
  final VoidCallback onSettingsTap;

  const LiveStatusHeader({
    super.key,
    required this.state,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.glassColor.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(color: AppTheme.neonBlue.withOpacity(0.2), width: 1.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ATLAS Dashboard',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              Row(
                children: [
                  _buildDropdown(
                    context,
                    state.selectedClientId,
                    state.data.clients.keys.toList(),
                    (newId) {
                      if (newId != null) {
                        context.read<DashboardBloc>().add(SelectClient(newId));
                      }
                    },
                    "Select Client",
                  ),
                  const SizedBox(width: 16),
                  _buildDropdown(
                    context,
                    state.selectedDeviceId,
                    state.data.clients[state.selectedClientId]?.devices.keys.toList() ?? [],
                    (newId) {
                      if (newId != null) {
                        context.read<DashboardBloc>().add(SelectDevice(newId));
                      }
                    },
                    "Select Device",
                  ),
                  const SizedBox(width: 24),
                  _LivePulse(lastSyncTime: state.latestSnapshot!.collectedAt),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: onSettingsTap,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context,
    String? selectedValue,
    List<String> items,
    ValueChanged<String?> onSelected,
    String hintText,
  ) {
    final bool isDisabled = items.isEmpty;
    String? displayValue = selectedValue;

    if (selectedValue != null && !items.contains(selectedValue)) {
      displayValue = null;
    }

    return Container(
      width: 200,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: AppTheme.glassColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.grey[900],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: displayValue,
            onChanged: isDisabled ? null : onSelected,
            isExpanded: true,
            dropdownColor: Colors.grey[900],
            style: const TextStyle(color: Colors.white, fontSize: 14),
            icon: Icon(Icons.arrow_drop_down, color: isDisabled ? Colors.grey : Colors.white),
            hint: Text(
              isDisabled ? "No devices" : hintText,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _LivePulse extends StatefulWidget {
  final DateTime lastSyncTime;
  const _LivePulse({required this.lastSyncTime});

  @override
  State<_LivePulse> createState() => _LivePulseState();
}

class _LivePulseState extends State<_LivePulse> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Timer _timer;
  String _timeAgo = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());
  }

  @override
  void didUpdateWidget(covariant _LivePulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastSyncTime != oldWidget.lastSyncTime) {
      _updateTime();
    }
  }

  void _updateTime() {
    if (!mounted) return;
    final now = DateTime.now().toUtc();
    final diff = now.difference(widget.lastSyncTime.toUtc());
    setState(() {
      _timeAgo = _formatDuration(diff);
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
    final syncTimeStr = DateFormat('HH:mm:ss').format(widget.lastSyncTime.toLocal());

    return Row(
      children: [
        FadeTransition(
          opacity: Tween<double>(begin: 0.3, end: 1.0).animate(_controller),
          child: Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Colors.greenAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.greenAccent, blurRadius: 8, spreadRadius: 2),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("LIVE (Synced $syncTimeStr)", style: Theme.of(context).textTheme.bodyMedium),
            Text(_timeAgo, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
          ],
        )
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }
}
