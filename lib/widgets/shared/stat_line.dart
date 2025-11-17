import 'package:flutter/material.dart';

class StatLine extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;
  final bool isLarge;

  const StatLine({
    super.key,
    required this.title,
    required this.value,
    this.valueColor,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: isLarge
                  ? Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70)
                  : Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: isLarge
                ? Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: valueColor ?? Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w700,
              shadows: [if (valueColor != null) Shadow(color: valueColor!, blurRadius: 8)],
            )
                : Theme.of(context).textTheme.titleMedium?.copyWith(
                color: valueColor ?? Theme.of(context).colorScheme.secondary
            ),
          ),
        ],
      ),
    );
  }
}