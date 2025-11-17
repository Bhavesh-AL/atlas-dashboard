import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:atlas_dashboard/app_theme.dart';
import 'package:atlas_dashboard/models/telemetry_models.dart';
import 'package:atlas_dashboard/widgets/shared/info_header.dart';
import 'package:atlas_dashboard/widgets/shared/glass_card.dart';
import 'package:atlas_dashboard/widgets/shared/stat_line.dart';
import 'package:atlas_dashboard/widgets/shared/history_charts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPage extends StatelessWidget {
  final DeviceData device;
  const LocationPage({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final snapshot = device.latestSnapshot;

    if (snapshot == null) {
      return const Center(
        child: Text(
          "No location data available.",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    final location = snapshot.location;

    // --- Prepare Graph Data ---
    final historicalData = device.snapshots.values.toList().reversed.take(20).toList();
    final accuracySpots = historicalData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.location.accuracy);
    }).toList();
    final altitudeSpots = historicalData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.location.altitude);
    }).toList();

    // --- Prepare Map Data ---
    // Get all historical points that have valid data
    final locationHistoryPoints = device.snapshots.values
        .where((s) => s.location.hasData)
        .map((s) => LatLng(s.location.latitude, s.location.longitude))
        .toList();

    // Get the current location as a LatLng
    final currentLocation = location.hasData
        ? LatLng(location.latitude, location.longitude)
        : null;

    // Create bounds to frame the map, or use current location
    LatLngBounds? mapBounds;
    if (locationHistoryPoints.isNotEmpty) {
      mapBounds = LatLngBounds.fromPoints(locationHistoryPoints);
      // Add a little padding to the bounds
      mapBounds.extend(LatLng(mapBounds.north + 0.01, mapBounds.east + 0.01));
      mapBounds.extend(LatLng(mapBounds.south - 0.01, mapBounds.west - 0.01));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const InfoHeader(title: "Current Location Details"),
        GlassCard(
          borderColor: Colors.greenAccent,
          shadowColor: Colors.greenAccent,
          child: _buildDetails(context, location),
        ),

        // --- FIX: Added Big Map with History ---
        const SizedBox(height: 16),
        const InfoHeader(title: "Location History Map"),
        GlassCard(
          padding: EdgeInsets.zero, // Map fills the card
          child: SizedBox(
            height: 400, // "Big" height as requested
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: _buildHistoryMap(context, currentLocation, locationHistoryPoints, mapBounds),
            ),
          ),
        ),
        // --- End of Map ---

        const SizedBox(height: 16),
        const InfoHeader(title: "Location History (Last 20 Snapshots)"),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FIX: Added padding and spacing
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                child: Text("Altitude (m)", style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(height: 8),
              HistoryLineChart(
                spotLists: [altitudeSpots],
                lineColors: [AppTheme.neonBlue],
                yAxisLabel: 'm',
                xAxisLabel: 'Last 20 Snapshots',
              ),
              const SizedBox(height: 32), // FIX: Increased spacing
              // FIX: Added padding and spacing
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text("Accuracy (m)", style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(height: 8),
              HistoryLineChart(
                spotLists: [accuracySpots],
                lineColors: [Colors.greenAccent],
                yAxisLabel: 'm',
                xAxisLabel: 'Last 20 Snapshots',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetails(BuildContext context, LocationInfo location) {
    if (!location.hasData) {
      return Center(
        child: Padding( // Added padding
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Text(
            "Location Permission Not Granted (${location.reason})",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white54),
          ),
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StatLine(title: "Latitude", value: location.latitude.toStringAsFixed(6), valueColor: Colors.white),
        StatLine(title: "Longitude", value: location.longitude.toStringAsFixed(6), valueColor: Colors.white),
        StatLine(title: "Altitude", value: "${location.altitude.toStringAsFixed(2)} m", valueColor: Colors.white70),
        StatLine(title: "Accuracy", value: "${location.accuracy.toStringAsFixed(2)} m", valueColor: Colors.white70),
      ],
    );
  }

  // FIX: New widget to build the history map
  Widget _buildHistoryMap(BuildContext context, LatLng? currentLocation, List<LatLng> historyPoints, LatLngBounds? bounds) {
    // Determine map center
    LatLng initialCenter;
    if (bounds != null) {
      initialCenter = bounds.center;
    } else if (currentLocation != null) {
      initialCenter = currentLocation;
    } else {
      initialCenter = const LatLng(51.509364, -0.128928); // Default to London
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: 12.0,
        initialCameraFit: bounds != null
            ? CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(24.0),
        )
            : null, // Will use initialCenter/Zoom if bounds are null

        // Enable all interactions
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: const ['a', 'b', 'c'],
          // Dark Map Option:
          // urlTemplate: "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png",
          // subdomains: const ['a', 'b', 'c', 'd'],
        ),
        // Draw the historical path
        if (historyPoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: historyPoints,
                color: AppTheme.neonBlue.withOpacity(0.8),
                strokeWidth: 4.0,
              ),
            ],
          ),
        // Draw a marker for the current location
        if (currentLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: currentLocation,
                child: const Icon(Icons.location_pin, color: AppTheme.neonPink, size: 40),
              ),
            ],
          ),
      ],
    );
  }
}