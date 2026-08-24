import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CircularProgressWidget extends StatelessWidget {
  final double progress;
  final int currentCount;
  final int targetCount;
  final int remainingCount;

  const CircularProgressWidget({
    super.key,
    required this.progress,
    required this.currentCount,
    required this.targetCount,
    required this.remainingCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = currentCount >= targetCount && targetCount > 0;

    return CircularPercentIndicator(
      radius: 140,
      lineWidth: 12,
      percent: progress.clamp(0.0, 1.0),
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$currentCount',
            style: theme.textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 72,
              color: isCompleted
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          ),
          Text(
            '/ $targetCount',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          if (!isCompleted)
            Text(
              '$remainingCount remaining',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          if (isCompleted)
            Text(
              'Completed!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
      progressColor: isCompleted
          ? theme.colorScheme.primary
          : theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      circularStrokeCap: CircularStrokeCap.round,
      animation: true,
      animationDuration: 300,
    );
  }
}
