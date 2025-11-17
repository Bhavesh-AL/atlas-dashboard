import 'package:atlas_dashboard/widgets/shared/glass_card.dart';
import 'package:atlas_dashboard/widgets/shared/history_charts.dart';
import 'package:atlas_dashboard/widgets/shared/stat_line.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:atlas_dashboard/app_theme.dart';
import 'package:atlas_dashboard/models/telemetry_models.dart';


// Note: To enable the map, add 'flutter_map' to your pubspec.yaml
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationCard extends StatelessWidget {
  final DeviceData device;
  const LocationCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final snapshot = device.latestSnapshot; // V1: Remove '!' for safety

    // V1: Handle case where there is no data yet
    if (snapshot == null) {
      return GlassCard(
        borderColor: Colors.greenAccent,
        shadowColor: Colors.greenAccent,
        child: const SizedBox(
          height: 300, // Match the card height
          child: Center(
            child: Text(
              "No location data available.",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ),
      );
    }

    final location = snapshot.location;

    // History for location accuracy
    final historicalData = device.snapshots.values.toList().reversed.take(20).toList();
    final accuracySpots = historicalData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.location.accuracy);
    }).toList();

    return DefaultTabController(
      length: 3,
      child: GlassCard(
        borderColor: Colors.greenAccent,
        shadowColor: Colors.greenAccent,
        child: Column(
          children: [
            const TabBar(
              indicatorColor: Colors.greenAccent,
              labelColor: Colors.greenAccent,
              tabs: [
                Tab(text: 'Details'),
                Tab(text: 'History'),
                Tab(text: 'Map'),
              ],
            ),
            SizedBox(
              height: 250, // UPDATE: Made taller
              child: TabBarView(
                // UPDATE: Removed the line that blocked map interaction
                // physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Tab 1: Details
                  _buildDetails(context, location),

                  // Tab 2: History (now uses taller chart)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: HistoryLineChart(
                      spotLists: [accuracySpots],
                      lineColors: [Colors.greenAccent],
                      yAxisLabel: 'm',
                    ),
                  ),

                  // Tab 3: Map (REAL IMPLEMENTATION)
                  _buildMap(context, location),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context, LocationInfo location) {
    if (!location.hasData) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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

  Widget _buildMap(BuildContext context, LocationInfo location) {
    if (!location.hasData) {
      return const Center(child: Text("No location to show on map.", style: TextStyle(color: Colors.white54)));
    }

    // --- REAL MAP IMPLEMENTATION ---
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(location.latitude, location.longitude),
          initialZoom: 15.0,
          interactionOptions: const InteractionOptions(
            // Re-enabled all flags except rotate
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
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
      ),
    );
  }
}