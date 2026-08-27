import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import '../../../models/dhikr.dart';
import '../../../router/app_router.dart';
import 'package:iconsax/iconsax.dart';

class QuickDhikrButtons extends StatelessWidget {
  final List<Dhikr> dhikrs;

  const QuickDhikrButtons({super.key, required this.dhikrs});

  @override
  Widget build(BuildContext context) {
    if (dhikrs.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 160,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
      width: 136,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.push(AppRoutes.counter, extra: dhikr.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.finger_scan,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dhikr.name,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  if (dhikr.arabicText != null &&
                      dhikr.arabicText!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      dhikr.arabicText!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'Amiri',
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${dhikr.totalTargetCount}x',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
