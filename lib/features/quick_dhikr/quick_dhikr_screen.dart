import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/l10n_extension.dart';
import '../../models/dhikr.dart';
import '../../providers/dhikr_provider.dart';
import '../../router/app_router.dart';

class QuickDhikrScreen extends ConsumerWidget {
  const QuickDhikrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultDhikrs = ref.watch(defaultDhikrsProvider);
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.quickDhikr)),
      body: defaultDhikrs.isEmpty
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
              itemCount: defaultDhikrs.length,
              itemBuilder: (context, index) {
                final dhikr = defaultDhikrs[index];
                return _DhikrListTile(dhikr: dhikr);
              },
            ),
    );
  }
}

class _DhikrListTile extends StatelessWidget {
  final Dhikr dhikr;

  const _DhikrListTile({required this.dhikr});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push(AppRoutes.counter, extra: dhikr.id),
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
                        if (dhikr.translation != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            dhikr.translation!,
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
                    label: Text('${context.l10n.targetCount}: ${dhikr.targetCount}'),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  const Spacer(),
                  if (dhikr.isCompleted)
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
                      child: Text(dhikr.isInProgress ? context.l10n.continue_ : context.l10n.start),
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
