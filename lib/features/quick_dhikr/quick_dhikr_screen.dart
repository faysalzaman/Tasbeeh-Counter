import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/l10n_extension.dart';
import '../../models/dhikr.dart';
import '../../models/dhikr_schedule.dart';
import '../../providers/dhikr_provider.dart';
import '../../router/app_router.dart';

class QuickDhikrScreen extends ConsumerWidget {
  const QuickDhikrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestedDhikrs = ref.watch(suggestedDhikrsProvider);
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.quickDhikr)),
      body: suggestedDhikrs.isEmpty
          ? Center(
              child: Text(
                l10n.noCustomWazifas,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: suggestedDhikrs.length,
              itemBuilder: (context, index) {
                final dhikr = suggestedDhikrs[index];
                return _DhikrListTile(dhikr: dhikr);
              },
            ),
    );
  }
}

class _ScheduleChip extends StatelessWidget {
  final DhikrSchedule? schedule;

  const _ScheduleChip({this.schedule});

  @override
  Widget build(BuildContext context) {
    if (schedule == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isRelevant = ScheduleHelper.shouldShowNow(schedule);

    return Chip(
      label: Text(
        schedule!.label,
        style: TextStyle(
          fontSize: 11,
          color: isRelevant ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.5),
          fontWeight: isRelevant ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      backgroundColor: isRelevant
          ? theme.colorScheme.primary.withValues(alpha: 0.1)
          : theme.colorScheme.onSurface.withValues(alpha: 0.05),
      side: isRelevant
          ? BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3))
          : BorderSide.none,
    );
  }
}

class _DhikrListTile extends ConsumerWidget {
  final Dhikr dhikr;

  const _DhikrListTile({required this.dhikr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progress = ref.watch(progressByIdProvider(dhikr.id));
    final targetCount = dhikr.totalTargetCount;
    final currentCount = progress?.currentCount ?? 0;
    final isInProgress = currentCount > 0 && currentCount < targetCount;
    final isCompleted = progress?.isCompleted ?? false;
    final scheduleEnum = progress?.scheduleEnum;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push(AppRoutes.dhikrDetail, extra: dhikr.id),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dhikr.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (dhikr.arabicText != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            dhikr.arabicText!,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                        if (dhikr.translation.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            dhikr.translation,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Chip(
                    label: Text('${context.l10n.targetCount}: $targetCount'),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(dhikr.category.label),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  if (scheduleEnum != null) ...[
                    const SizedBox(width: 8),
                    _ScheduleChip(schedule: scheduleEnum),
                  ],
                  const Spacer(),
                  if (isCompleted)
                    Chip(
                      avatar: Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 18),
                      label: Text(context.l10n.completed),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    )
                  else
                    FilledButton(
                      onPressed: () => context.push(AppRoutes.counter, extra: dhikr.id),
                      child: Text(isInProgress ? context.l10n.continue_ : context.l10n.start),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
