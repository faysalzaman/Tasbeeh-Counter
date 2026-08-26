import 'package:material_ui/material_ui.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../core/localization/l10n_extension.dart';

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
    final l10n = context.l10n;
    final isCompleted = currentCount >= targetCount && targetCount > 0;
    final clampedProgress = progress.clamp(0.0, 1.0);

    return CircularPercentIndicator(
      radius: 120,
      lineWidth: 12,
      percent: clampedProgress,
      animation: true,
      animationDuration: 200,
      animateFromLastPercent: true,
      curve: Curves.easeOutCubic,
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: isCompleted
          ? theme.colorScheme.secondary
          : theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Text(
              '$currentCount',
              key: ValueKey<int>(currentCount),
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 56,
                color: isCompleted
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            '/ $targetCount',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isCompleted ? l10n.completed : '$remainingCount ${l10n.remaining}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isCompleted
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
