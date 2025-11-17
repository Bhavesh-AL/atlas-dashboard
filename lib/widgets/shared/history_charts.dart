import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math'; // Import for `pow`

class HistoryLineChart extends StatelessWidget {
  final List<List<FlSpot>> spotLists;
  final List<Color> lineColors;
  final List<String> legendTitles;
  final double? minY;
  final double? maxY;
  final String yAxisLabel;
  final String xAxisLabel;

  const HistoryLineChart({
    super.key,
    required this.spotLists,
    required this.lineColors,
    this.legendTitles = const [],
    this.minY,
    this.maxY,
    this.yAxisLabel = '',
    this.xAxisLabel = 'Last 20 Snapshots',
  });

  @override
  Widget build(BuildContext context) {
    if (spotLists.isEmpty || spotLists.first.isEmpty) {
      // FIX: Increased height to match
      return const SizedBox(height: 300, child: Center(child: Text("No historical data.")));
    }

    return SizedBox(
      height: 300, // FIX: Made chart taller (was 250)
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY != null && minY != null && (maxY!-minY!) > 0) ? (maxY! - minY!) / 4 : null,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: Colors.white10,
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles( // No x-axis labels
                    sideTitles: const SideTitles(showTitles: false),
                    axisNameSize: 25,
                    axisNameWidget: Text(
                      xAxisLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameSize: 35,
                    axisNameWidget: Text(
                      yAxisLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      // Remove the interval property, we will handle it in the widget
                      getTitlesWidget: (value, meta) {
                        if (meta.max == meta.min) return Container();

                        // --- THIS IS THE NEW FIX ---
                        // We will force 5 labels (0, 25, 50, 75, 100%)

                        // 1. Calculate the 4 major intervals
                        final double interval = (meta.max - meta.min) / 4.0;

                        // 2. Check if the current value is "close" to one of the 5 ticks
                        // We use a small epsilon (1% of the interval) to handle
                        // floating point inaccuracies.
                        final double epsilon = interval * 0.01;

                        bool isMainTick = false;
                        if (
                        (value - meta.min).abs() < epsilon ||                 // 0% tick
                            (value - (meta.min + interval)).abs() < epsilon ||    // 25% tick
                            (value - (meta.min + 2 * interval)).abs() < epsilon || // 50% tick
                            (value - (meta.min + 3 * interval)).abs() < epsilon || // 75% tick
                            (value - meta.max).abs() < epsilon                   // 100% tick
                        ) {
                          isMainTick = true;
                        }

                        // If it's not one of our 5 main ticks, draw nothing.
                        if (!isMainTick) {
                          return Container();
                        }

                        // 3. Format the label text
                        String text;
                        // Show a decimal if the range is small
                        bool useDecimal = (meta.max - meta.min) < 10;

                        if (useDecimal) {
                          text = value.toStringAsFixed(1);
                        } else {
                          text = value.toInt().toString();
                        }
                        // --- END OF FIX ---

                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            text,
                            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: List.generate(spotLists.length, (index) {
                  return LineChartBarData(
                    spots: spotLists[index],
                    isCurved: true,
                    color: lineColors[index],
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: lineColors[index].withOpacity(0.3)),
                  );
                }),
              ),
            ),
          ),
          if (legendTitles.isNotEmpty)
            _buildLegend(context),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        spacing: 16.0,
        runSpacing: 4.0,
        alignment: WrapAlignment.center,
        children: List.generate(legendTitles.length, (index) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                color: lineColors[index],
              ),
              const SizedBox(width: 4),
              Text(
                legendTitles[index],
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        }),
      ),
    );
  }
}