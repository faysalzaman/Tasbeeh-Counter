import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/dhikr.dart';
import '../../../router/app_router.dart';

class QuickDhikrButtons extends StatelessWidget {
  final List<Dhikr> dhikrs;

  const QuickDhikrButtons({super.key, required this.dhikrs});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        itemCount: dhikrs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final dhikr = dhikrs[index];
          return _DhikrCard(dhikr: dhikr);
        },
      ),
    );
  }
}

class _DhikrCard extends StatelessWidget {
  final Dhikr dhikr;

  const _DhikrCard({required this.dhikr});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 140,
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(AppRoutes.counter, extra: dhikr.id),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fingerprint,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  dhikr.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${dhikr.targetCount}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
