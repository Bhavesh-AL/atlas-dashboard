import 'package:atlas_dashboard/app_theme.dart';
import 'package:atlas_dashboard/models/telemetry_models.dart';
import 'package:flutter/material.dart';
import '../shared/glass_card.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// FIX: Added StatLine for the details column
import '../shared/stat_line.dart';

class OverviewLocationCard extends StatelessWidget {
  final LocationInfo location;
  const OverviewLocationCard({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: Colors.greenAccent,
      shadowColor: Colors.greenAccent,
      // FIX: Use a Row for the 2-column layout
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Column 1: Map ---
          Expanded(
            flex: 2, // Map takes 2/3 of the space
            child: SizedBox(
              height: 250, // Fixed height
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12), // Rounded corners
                child: _buildMap(context, location),
              ),
            ),
          ),
          const SizedBox(width: 16), // Gutter
          // --- Column 2: Details ---
          Expanded(
            flex: 1, // Details take 1/3 of the space
            child: _buildDetails(context, location),
          ),
        ],
      ),
    );
  }

  // FIX: New helper for the details column
  Widget _buildDetails(BuildContext context, LocationInfo location) {
    if (!location.hasData) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, color: Colors.white54, size: 40),
            const SizedBox(height: 8),
            Text(
              "Location Not Granted",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white54),
            ),
            Text(
              location.reason,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white38),
            ),
          ],
        ),
      );
    }

    // Use StatLine for a clean look
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            "Coordinates",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)
        ),
        const Divider(height: 16, color: Colors.white24),
        StatLine(
            title: "Latitude",
            value: location.latitude.toStringAsFixed(6),
            valueColor: Colors.white
        ),
        StatLine(
            title: "Longitude",
            value: location.longitude.toStringAsFixed(6),
            valueColor: Colors.white
        ),
        StatLine(
            title: "Altitude",
            value: "${location.altitude.toStringAsFixed(2)} m",
            valueColor: Colors.white70
        ),
        StatLine(
            title: "Accuracy",
            value: "${location.accuracy.toStringAsFixed(2)} m",
            valueColor: Colors.white70
        ),
      ],
    );
  }

  // This helper builds the map itself
  Widget _buildMap(BuildContext context, LocationInfo location) {
    if (!location.hasData) {
      // Show a placeholder if no data, details column will show the error
      return Container(color: Colors.white10);
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(location.latitude, location.longitude),
        initialZoom: 16.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: const ['a', 'b', 'c'],
          // Dark Map:
          // urlTemplate: "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png",
          // subdomains: const ['a', 'b', 'c', 'd'],
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: LatLng(location.latitude, location.longitude),
              child: const Icon(Icons.location_pin, color: AppTheme.neonPink, size: 40),
            ),
          ],
        ),
      ],
    );
  }
}