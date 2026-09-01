import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../providers/settings_provider.dart';
import '../../../widgets/custom_buttons.dart';

class LanguagePickerSheet extends ConsumerWidget {
  const LanguagePickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.language,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppIconButton(
                    icon: Iconsax.close_circle,
                    onPressed: () => Navigator.pop(context),
                    size: 36,
                  ),
                ],
              ),
            ),
            const Divider(),
            RadioGroup<String>(
              groupValue: settings.languageCode,
              onChanged: (value) {
                if (value == null) return;
                ref.read(settingsProvider.notifier).updateLanguage(value);
                context.pop();
              },
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: Text(l10n.languageSystem),
                    value: 'system',
                  ),
                  RadioListTile<String>(
                    title: Text(l10n.languageEnglish),
                    value: 'en',
                  ),
                  RadioListTile<String>(
                    title: Text(l10n.languageArabic),
                    subtitle: const Text(
                      'العربية',
                      style: TextStyle(fontFamily: 'Amiri'),
                    ),
                    value: 'ar',
                  ),
                  RadioListTile<String>(
                    title: Text(l10n.languageUrdu),
                    subtitle: const Text('اردو'),
                    value: 'ur',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
