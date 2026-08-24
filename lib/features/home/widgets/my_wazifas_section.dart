import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/l10n_extension.dart';
import '../../../models/dhikr.dart';
import '../../../providers/dhikr_provider.dart';
import '../../../router/app_router.dart';

class MyWazifaCard extends ConsumerWidget {
  final Dhikr dhikr;

  const MyWazifaCard({super.key, required this.dhikr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final progress = ref.watch(progressByIdProvider(dhikr.id));
    final targetCount = dhikr.totalTargetCount;
    final currentCount = progress?.currentCount ?? 0;
    final isCompleted = progress?.isCompleted ?? false;
    final reminderEnabled = progress?.reminderEnabled ?? false;
    final repeatEnabled = progress?.repeatEnabled ?? false;
    final progressPct = targetCount > 0
        ? (currentCount / targetCount).clamp(0.0, 1.0)
        : 0.0;

    final activeColor = isCompleted
        ? theme.colorScheme.tertiary
        : theme.colorScheme.primary;
    final activeContainerColor = isCompleted
        ? theme.colorScheme.tertiaryContainer
        : theme.colorScheme.primaryContainer;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? theme.colorScheme.tertiary.withValues(alpha: 0.3)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push(AppRoutes.counter, extra: dhikr.id),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Details & Progress Indicator Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dhikr.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (dhikr.arabicText != null &&
                              dhikr.arabicText!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              dhikr.arabicText!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: 'Amiri',
                                fontWeight: FontWeight.bold,
                                color: activeColor,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Percent / Completion Badge
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: activeContainerColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: theme.colorScheme.onTertiaryContainer,
                                size: 26,
                              )
                            : Text(
                                '${(progressPct * 100).toInt()}%',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Linear Animated Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    tween: Tween<double>(begin: 0.0, end: progressPct),
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 8,
                        backgroundColor: theme.colorScheme.surfaceContainerHigh,
                        valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Bottom Status Details & Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$currentCount / $targetCount',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (reminderEnabled)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(
                              Icons.alarm_on_rounded,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        if (repeatEnabled)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(
                              Icons.repeat_rounded,
                              size: 16,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? activeContainerColor
                                : theme.colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isCompleted ? l10n.completed : l10n.continue_,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isCompleted
                                  ? theme.colorScheme.onTertiaryContainer
                                  : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
