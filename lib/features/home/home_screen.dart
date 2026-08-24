import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/l10n_extension.dart';
import '../../providers/dhikr_provider.dart';
import '../../router/app_router.dart';
import 'widgets/greeting_widget.dart';
import 'widgets/continue_wazifa_card.dart';
import 'widgets/quick_dhikr_buttons.dart';
import 'widgets/my_wazifas_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDhikrs = ref.watch(activeDhikrsProvider);
    final defaultDhikrs = ref.watch(defaultDhikrsProvider);
    final customDhikrs = ref.watch(customDhikrsProvider);
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const GreetingWidget(),
                        IconButton(
                          onPressed: () => context.push(AppRoutes.settings),
                          icon: const Icon(Icons.settings_outlined),
                          tooltip: l10n.settings,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Continue Wazifa Section
                    if (activeDhikrs.isNotEmpty) ...[
                      Text(
                        l10n.continueWazifa,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...activeDhikrs.map((dhikr) => ContinueWazifaCard(dhikr: dhikr)),
                      const SizedBox(height: 24),
                    ],

                    // Quick Dhikr Section
                    Text(
                      l10n.quickDhikr,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    QuickDhikrButtons(dhikrs: defaultDhikrs.take(6).toList()),
                    const SizedBox(height: 24),

                    // My Wazifas Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.myWazifas,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => context.push(AppRoutes.createWazifa),
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(l10n.create),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Custom Wazifas List
            if (customDhikrs.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          size: 48,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.noCustomWazifas,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.noCustomWazifasSubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
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
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final dhikr = customDhikrs[index];
                      return MyWazifaCard(dhikr: dhikr);
                    },
                    childCount: customDhikrs.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.dhikrSelection),
        icon: const Icon(Icons.menu_book),
        label: Text(l10n.allAzkaar),
      ),
    );
  }
}
