import 'dart:math';
import 'package:flutter/material.dart';

class SensorGauge extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;
  final double minValue;
  final double maxValue;

  const SensorGauge({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    this.minValue = -10.0,
    this.maxValue = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // The custom gauge
        SizedBox(
          width: 80,
          height: 80,
          child: CustomPaint(
            painter: _GaugePainter(
              value: value,
              minValue: minValue,
              maxValue: maxValue,
              color: color,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    unit,
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // The label
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final double minValue;
  final double maxValue;
  final Color color;

  _GaugePainter({
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 8;
    const startAngle = 3 * pi / 4;
    const sweepAngle = 3 * pi / 2;

    final backgroundPaint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final valuePaint = Paint()
      ..color = color
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    // Calculate value sweep
    double valueFraction = (value - minValue) / (maxValue - minValue);
    valueFraction = valueFraction.clamp(0.0, 1.0);
    final double valueSweep = valueFraction * sweepAngle;

    // Draw value arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      valueSweep,
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repaint whenever value changes
  }
}

// A simpler widget for single-value sensors like Proximity or Light
class SensorSimpleValue extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const SensorSimpleValue({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}