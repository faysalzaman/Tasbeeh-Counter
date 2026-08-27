import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/localization/l10n_extension.dart';
import '../../models/dhikr.dart';
import '../../providers/dhikr_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/custom_scaffold.dart';

class MyWazifasScreen extends ConsumerWidget {
  const MyWazifasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customDhikrs = ref.watch(customDhikrsProvider);
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return CustomScaffold(
      backgroundColor: theme.colorScheme.surface,
      titleWidget: Text(
        l10n.myWazifas,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      padding: EdgeInsets.zero,
      body: customDhikrs.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bookmark_add_outlined,
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
                      icon: Icons.add_rounded,
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
                return _WazifaListTile(dhikr: dhikr);
              },
            ),
      floatingActionButton: AppFab(
        icon: Icons.add_rounded,
        label: l10n.createWazifa,
        onPressed: () => context.push(AppRoutes.createWazifa),
      ),
    );
  }
}

class _WazifaListTile extends ConsumerWidget {
  final Dhikr dhikr;

  const _WazifaListTile({required this.dhikr});

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
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.push(AppRoutes.counter, extra: dhikr.id),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Info & Quick Popup Options
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (dhikr.translation.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              dhikr.translation,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Visual Circular Progress Badge
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(
                                Icons.check_rounded,
                                color: theme.colorScheme.onPrimaryContainer,
                                size: 22,
                              )
                            : Text(
                                '${(progressPct * 100).toInt()}%',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                      ),
                    ),
                    PopupMenuButton<_WazifaAction>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      onSelected: (action) {
                        switch (action) {
                          case _WazifaAction.edit:
                            context.push(
                              AppRoutes.createWazifa,
                              extra: dhikr.id,
                            );
                            break;
                          case _WazifaAction.info:
                            context.push(
                              AppRoutes.dhikrDetail,
                              extra: dhikr.id,
                            );
                            break;
                          case _WazifaAction.delete:
                            _showDeleteDialog(context, ref);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: _WazifaAction.info,
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 18),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: _WazifaAction.edit,
                          child: Row(
                            children: [
                              const Icon(Icons.edit_outlined, size: 18),
                              const SizedBox(width: 8),
                              Text(l10n.edit),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: _WazifaAction.delete,
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.delete,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Arabic Text Container (if available)
                if (dhikr.arabicText != null &&
                    dhikr.arabicText!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      dhikr.arabicText!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'Amiri',
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progressPct,
                    minHeight: 6,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Bottom Status Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$currentCount / $targetCount Recitations',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (reminderEnabled)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(
                              Icons.notifications_active_outlined,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        if (repeatEnabled)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(
                              Icons.repeat_rounded,
                              size: 16,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        Text(
                          isCompleted ? l10n.completed : l10n.continue_,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: theme.colorScheme.primary,
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

enum _WazifaAction { edit, info, delete }
