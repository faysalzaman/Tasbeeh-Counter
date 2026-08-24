import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/dhikr.dart';
import '../../providers/dhikr_provider.dart';
import '../../router/app_router.dart';

class DhikrSelectionScreen extends ConsumerWidget {
  const DhikrSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultDhikrs = ref.watch(defaultDhikrsProvider);
    final customDhikrs = ref.watch(customDhikrsProvider);
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select Dhikr'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Default Azkaar'),
              Tab(text: 'My Wazifas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Default Azkaar Tab
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: defaultDhikrs.length,
              itemBuilder: (context, index) {
                final dhikr = defaultDhikrs[index];
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
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No custom wazifas',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => context.push(AppRoutes.createWazifa),
                          icon: const Icon(Icons.add),
                          label: const Text('Create Wazifa'),
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
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (dhikr.isInProgress)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${dhikr.currentCount}/${dhikr.targetCount}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Chip(
                    label: Text('Target: ${dhikr.targetCount}'),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  if (dhikr.repeatEnabled)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Chip(
                        label: Text('Repeat'),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  const Spacer(),
                  if (showEdit)
                    IconButton(
                      onPressed: () => context.push(AppRoutes.createWazifa, extra: dhikr.id),
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: 'Edit',
                    ),
                  if (showDelete)
                    IconButton(
                      onPressed: () => _showDeleteDialog(context, ref),
                      icon: Icon(Icons.delete_outline, size: 20, color: theme.colorScheme.error),
                      tooltip: 'Delete',
                    ),
                  if (!showEdit && !showDelete)
                    FilledButton(
                      onPressed: () => context.push(AppRoutes.counter, extra: dhikr.id),
                      child: Text(dhikr.isInProgress ? 'Continue' : 'Start'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Wazifa?'),
        content: Text('Are you sure you want to delete "${dhikr.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(dhikrListNotifierProvider.notifier).deleteDhikr(dhikr.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
