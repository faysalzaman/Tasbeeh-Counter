import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/l10n_extension.dart';
import '../../providers/dhikr_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/custom_scaffold.dart';
import 'widgets/greeting_widget.dart';
import 'package:iconsax/iconsax.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDhikrs = ref.watch(activeDhikrsProvider);
    final defaultDhikrs = ref.watch(defaultDhikrsProvider);
    final customDhikrs = ref.watch(customDhikrsProvider);
    final quickDhikrs = ref.watch(quickDhikrsProvider);
    final relevantNowQuickDhikrs = ref.watch(relevantNowQuickDhikrsProvider);
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return CustomScaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const GreetingWidget(),
                    AppIconButton(
                      icon: Iconsax.setting,
                      onPressed: () => context.push(AppRoutes.settings),
                      tooltip: l10n.settings,
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Category Section Title
                Row(
                  children: [
                    Text(
                      l10n.categories,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      l10n.totalCount(defaultDhikrs.length + customDhikrs.length),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Categories Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.98,
                  children: [
                    _CategoryCard(
                      icon: Iconsax.flash,
                      label: l10n.quickDhikr,
                      count: quickDhikrs.length,
                      badgeCount: relevantNowQuickDhikrs.length,
                      containerColor: theme.colorScheme.primaryContainer,
                      iconColor: theme.colorScheme.onPrimaryContainer,
                      onTap: () => context.push(AppRoutes.quickDhikr),
                    ),
                    _CategoryCard(
                      icon: Iconsax.bookmark,
                      label: l10n.myWazifas,
                      count: customDhikrs.length,
                      containerColor: theme.colorScheme.secondaryContainer,
                      iconColor: theme.colorScheme.onSecondaryContainer,
                      onTap: () => context.push(AppRoutes.myWazifas),
                    ),
                    if (activeDhikrs.isNotEmpty)
                      _CategoryCard(
                        icon: Iconsax.play_circle,
                        label: l10n.continueWazifa,
                        count: activeDhikrs.length,
                        containerColor: theme.colorScheme.tertiaryContainer,
                        iconColor: theme.colorScheme.onTertiaryContainer,
                        onTap: () => context.push(AppRoutes.continueWazifa),
                      ),
                    _CategoryCard(
                      icon: Iconsax.book,
                      label: l10n.allAzkaar,
                      count: defaultDhikrs.length + customDhikrs.length,
                      containerColor: theme.colorScheme.surfaceContainerHigh,
                      iconColor: theme.colorScheme.primary,
                      onTap: () => context.push(AppRoutes.dhikrSelection),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Create New Wazifa Banner
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.4,
                      ),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.push(AppRoutes.createWazifa),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.12,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Iconsax.add,
                                color: theme.colorScheme.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.createWazifa,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    l10n.setYourOwnTargetAndSchedule,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Iconsax.arrow_right_3,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final int? badgeCount;
  final Color containerColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.count,
    this.badgeCount,
    required this.containerColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: containerColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 28),
                    ),
                    if (badgeCount != null && badgeCount! > 0)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: theme.colorScheme.surface,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            '$badgeCount',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.itemsCount(count),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
