import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/l10n_extension.dart';
import '../../models/dhikr.dart';
import '../../models/dhikr_schedule.dart';
import '../../providers/dhikr_provider.dart';
import '../../router/app_router.dart';

class DhikrSelectionScreen extends ConsumerWidget {
  const DhikrSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestedDhikrs = ref.watch(suggestedDhikrsProvider);
    final customDhikrs = ref.watch(customDhikrsProvider);
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.selectDhikr),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.defaultAzkaar),
              Tab(text: l10n.myWazifas),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Default Azkaar Tab
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: suggestedDhikrs.length,
              itemBuilder: (context, index) {
                final dhikr = suggestedDhikrs[index];
                return DhikrListTile(dhikr: dhikr);
              },
            ),

            // My Wazifas Tab
            customDhikrs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          size: 64,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noCustomWazifas,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.noCustomWazifasSubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => context.push(AppRoutes.createWazifa),
                          icon: const Icon(Icons.add),
                          label: Text(l10n.createWazifa),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: customDhikrs.length,
                    itemBuilder: (context, index) {
                      final dhikr = customDhikrs[index];
                      return DhikrListTile(
                        dhikr: dhikr,
                        showEdit: true,
                        showDelete: true,
                      );
                    },
                  ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push(AppRoutes.createWazifa),
          child: const Icon(Icons.add),
        ),
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
          color: isRelevant
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
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

class DhikrListTile extends ConsumerWidget {
  final Dhikr dhikr;
  final bool showEdit;
  final bool showDelete;

  const DhikrListTile({
    super.key,
    required this.dhikr,
    this.showEdit = false,
    this.showDelete = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final progress = ref.watch(progressByIdProvider(dhikr.id));
    final targetCount = dhikr.totalTargetCount;
    final currentCount = progress?.currentCount ?? 0;
    final isInProgress = currentCount > 0 && currentCount < targetCount;
    final isCompleted = progress?.isCompleted ?? false;
    final repeatEnabled = progress?.repeatEnabled ?? false;
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
                        ...[
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
                  if (isInProgress)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$currentCount/$targetCount',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text('${l10n.targetCount}: $targetCount'),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  Chip(
                    label: Text(dhikr.category.label),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  if (repeatEnabled)
                    Chip(
                      label: Text(l10n.repeatMode),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  if (scheduleEnum != null)
                    _ScheduleChip(schedule: scheduleEnum),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (showEdit)
                      IconButton(
                        onPressed: () => context.push(
                          AppRoutes.createWazifa,
                          extra: dhikr.id,
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: l10n.edit,
                      ),
                    if (showDelete)
                      IconButton(
                        onPressed: () => _showDeleteDialog(context, ref),
                        icon: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: theme.colorScheme.error,
                        ),
                        tooltip: l10n.delete,
                      ),
                    if (!showEdit && !showDelete)
                      if (isCompleted)
                        Chip(
                          avatar: Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                            size: 18,
                          ),
                          label: Text(l10n.completed),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          backgroundColor: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                        )
                      else
                        FilledButton(
                          onPressed: () =>
                              context.push(AppRoutes.counter, extra: dhikr.id),
                          child: Text(
                            isInProgress ? l10n.continue_ : l10n.start,
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteWazifaTitle),
        content: Text(
          l10n.deleteWazifaMessage.toString().replaceAll('{name}', dhikr.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(dhikrListNotifierProvider.notifier)
                  .deleteDhikr(dhikr.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
