import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/dhikr.dart';
import '../../../router/app_router.dart';

class QuickDhikrButtons extends StatelessWidget {
  final List<Dhikr> dhikrs;

  const QuickDhikrButtons({super.key, required this.dhikrs});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: dhikrs.map((dhikr) {
        return ActionChip(
          avatar: const Icon(Icons.touch_app, size: 18),
          label: Text(dhikr.name),
          onPressed: () => context.push(AppRoutes.counter, extra: dhikr.id),
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          side: BorderSide.none,
        );
      }).toList(),
    );
  }
}
