import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/l10n_extension.dart';
import '../../models/dhikr.dart';
import '../../models/dhikr_schedule.dart';
import '../../providers/dhikr_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/custom_scaffold.dart';
import 'package:iconsax/iconsax.dart';

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
      child: CustomScaffold(
        backgroundColor: theme.colorScheme.surface,
        titleWidget: Text(
          l10n.selectDhikr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        padding: EdgeInsets.zero,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: theme.colorScheme.onPrimary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: [
                Tab(text: l10n.defaultAzkaar),
                Tab(text: l10n.myWazifas),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // Default Azkaar Tab
            ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: suggestedDhikrs.length,
              itemBuilder: (context, index) {
                final dhikr = suggestedDhikrs[index];
                return DhikrListTile(dhikr: dhikr);
              },
            ),

            // My Wazifas Tab
            customDhikrs.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer
                                  .withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Iconsax.archive_add,
                              size: 56,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.noCustomWazifas,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.noCustomWazifasSubtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          AppButton.primary(
                            icon: Iconsax.add,
                            label: l10n.createWazifa,
                            onPressed: () => context.push(AppRoutes.createWazifa),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
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
        floatingActionButton: AppFab(
          icon: Iconsax.add,
          label: l10n.createWazifa,
          onPressed: () => context.push(AppRoutes.createWazifa),
        ),
      ),
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

    final progressRatio = targetCount > 0
        ? (currentCount / targetCount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => context.push(AppRoutes.dhikrDetail, extra: dhikr.id),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
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
                            ),
                          ),
                          if (dhikr.translation.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              dhikr.translation,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isInProgress) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                value: progressRatio,
                                strokeWidth: 2.5,
                                color: theme.colorScheme.primary,
                                backgroundColor: theme.colorScheme.primary
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$currentCount/$targetCount',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                // Arabic Text Container (if available)
                if (dhikr.arabicText != null &&
                    dhikr.arabicText!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      dhikr.arabicText!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'Amiri',
                        fontWeight: FontWeight.bold,
                        height: 1.6,
                      ),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Metadata Badges
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _MetaBadge(
                      label: '${l10n.targetCount}: $targetCount',
                      icon: Iconsax.flag,
                    ),
                    _MetaBadge(
                      label: dhikr.category.label,
                      icon: Iconsax.category,
                    ),
                    if (repeatEnabled)
                      _MetaBadge(
                        label: l10n.repeatMode,
                        icon: Iconsax.repeat,
                        color: theme.colorScheme.secondary,
                      ),
                    if (scheduleEnum != null)
                      _ScheduleBadge(schedule: scheduleEnum),
                  ],
                ),

                const SizedBox(height: 8),

                // Bottom Action Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (showEdit)
                      AppIconButton.outlined(
                        icon: Iconsax.edit,
                        borderColor: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                        onPressed: () => context.push(
                          AppRoutes.createWazifa,
                          extra: dhikr.id,
                        ),
                        tooltip: l10n.edit,
                      ),
                    if (showDelete) ...[
                      const SizedBox(width: 8),
                      AppIconButton.outlined(
                        icon: Iconsax.trash,
                        borderColor: theme.colorScheme.error.withValues(
                          alpha: 0.3,
                        ),
                        color: theme.colorScheme.error,
                        onPressed: () => _showDeleteDialog(context, ref),
                        tooltip: l10n.delete,
                      ),
                    ],
                    if (!showEdit && !showDelete) ...[
                      if (isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Iconsax.tick_circle,
                                color: theme.colorScheme.primary,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l10n.completed,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        AppButton.primary(
                          icon: Iconsax.finger_scan,
                          label: isInProgress ? l10n.continue_ : l10n.start,
                          height: 40,
                          onPressed: () =>
                              context.push(AppRoutes.counter, extra: dhikr.id),
                        ),
                    ],
                  ],
                ),
              ],
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.deleteWazifaTitle),
        content: Text(
          l10n.deleteWazifaMessage.toString().replaceAll('{name}', dhikr.name),
        ),
        actions: [
          AppButton.text(
            label: l10n.cancel,
            onPressed: () => Navigator.pop(context),
          ),
          AppButton.danger(
            label: l10n.delete,
            onPressed: () {
              ref
                  .read(dhikrListNotifierProvider.notifier)
                  .deleteDhikr(dhikr.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;

  const _MetaBadge({required this.label, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = color ?? theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleBadge extends StatelessWidget {
  final DhikrSchedule? schedule;

  const _ScheduleBadge({this.schedule});

  @override
  Widget build(BuildContext context) {
    if (schedule == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isRelevant = ScheduleHelper.shouldShowNow(schedule);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isRelevant
            ? theme.colorScheme.primary.withValues(alpha: 0.12)
            : theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
        border: isRelevant
            ? Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Iconsax.clock,
            size: 12,
            color: isRelevant
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            schedule!.label,
            style: TextStyle(
              fontSize: 11,
              color: isRelevant
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: isRelevant ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
