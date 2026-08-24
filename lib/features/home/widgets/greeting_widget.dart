import 'package:flutter/material.dart';
import '../../../core/localization/l10n_extension.dart';

class GreetingWidget extends StatelessWidget {
  const GreetingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final hour = DateTime.now().hour;

    final (_GreetingData data) = switch (hour) {
      < 5 => _GreetingData(
        text: l10n.goodNight,
        icon: Icons.nightlight_round_rounded,
      ),
      < 12 => _GreetingData(
        text: l10n.goodMorning,
        icon: Icons.wb_sunny_rounded,
      ),
      < 17 => _GreetingData(
        text: l10n.goodAfternoon,
        icon: Icons.wb_twilight_rounded,
      ),
      < 20 => _GreetingData(
        text: l10n.goodEvening,
        icon: Icons.bedtime_rounded,
      ),
      _ => _GreetingData(text: l10n.goodNight, icon: Icons.dark_mode_rounded),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Time Period Dynamic Icon Badge
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
          child: Icon(
            data.icon,
            color: theme.colorScheme.onPrimaryContainer,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),

        // Text Column
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              data.text,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.keepConnected,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GreetingData {
  final String text;
  final IconData icon;

  const _GreetingData({required this.text, required this.icon});
}
