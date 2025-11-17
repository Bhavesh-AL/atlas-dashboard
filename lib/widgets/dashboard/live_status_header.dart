import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:atlas_dashboard/app_theme.dart';
import 'package:atlas_dashboard/bloc/dashboard_bloc.dart';

class LiveStatusHeader extends StatelessWidget {
  final DashboardLoaded state;
  const LiveStatusHeader({super.key, required this.state});

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
                  _buildDropdown( // FIX: This is now a custom-styled DropdownButton
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
                  _buildDropdown( // FIX: This is now a custom-styled DropdownButton
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
                  // FIX: This now shows "Xm Ys ago"
                  _LivePulse(lastSyncTime: state.latestSnapshot!.collectedAt),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // FIX: Replaced DropdownMenu with a styled DropdownButton
  Widget _buildDropdown(
      BuildContext context,
      String? selectedValue,
      List<String> items,
      ValueChanged<String?> onSelected,
      String hintText,
      ) {

    final bool isDisabled = items.isEmpty;
    String? displayValue = selectedValue;

    // Ensure selectedValue is in the list, otherwise DropdownButton will error
    if (selectedValue != null && !items.contains(selectedValue)) {
      displayValue = null;
    }

    return Container(
      width: 200,
      height: 40, // Give it a fixed height
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: AppTheme.glassColor.withOpacity(0.2), // Glassy BG
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.white24, width: 0.5), // Subtle border
      ),
      // FIX: Wrap in a Theme widget to control the menu's background color
      child: Theme(
        data: Theme.of(context).copyWith(
          // This forces the dropdown menu background to be dark
          canvasColor: Colors.grey[900], // A solid dark color
        ),
        child: DropdownButtonHideUnderline( // Remove the default ugly underline
          child: DropdownButton<String>(
            value: displayValue,
            onChanged: isDisabled ? null : onSelected, // Disable if no items
            isExpanded: true, // To fill the container

            // This is a fallback, but canvasColor is the main fix
            dropdownColor: Colors.grey[900], // A solid dark color

            // Style the selected item's text
            style: const TextStyle(color: Colors.white, fontSize: 14),

            // Style the icon
            icon: Icon(Icons.arrow_drop_down, color: isDisabled ? Colors.grey : Colors.white),

            // Hint for when no value is selected (or items are empty)
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
    // Refresh time if the snapshot updates
    if (widget.lastSyncTime != oldWidget.lastSyncTime) {
      _updateTime();
    }
  }

  // FIX: Changed from HH:MM:SS to "Xm Ys ago"
  void _updateTime() {
    if (!mounted) return;
    final now = DateTime.now().toUtc();
    final diff = now.difference(widget.lastSyncTime.toUtc());
    setState(() {
      _timeAgo = _formatDuration(diff);
    });
  }

  // FIX: Added this helper function
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
            // FIX: This now shows "Xm Ys ago"
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