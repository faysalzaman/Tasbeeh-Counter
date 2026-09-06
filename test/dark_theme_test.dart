import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tesbeeh_counter/core/theme/app_colors.dart';
import 'package:tesbeeh_counter/core/theme/app_theme.dart';
import 'package:tesbeeh_counter/features/settings/widgets/settings_group_card.dart';

/// Verify that key dark-theme text colors have enough contrast to be readable.
void main() {
  group('Dark theme text visibility', () {
    test('primary color is light enough against dark surfaces', () {
      final scheme = AppTheme.darkTheme.colorScheme;
      expect(
        scheme.primary,
        equals(AppColors.primaryDark),
        reason: 'dark primary should be the light teal',
      );
      expect(
        scheme.onPrimary,
        equals(Colors.black),
        reason: 'dark onPrimary should be black for contrast',
      );
    });

    testWidgets('SettingsGroupCard title is readable in dark mode',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: const Scaffold(
            body: SettingsGroupCard(
              title: 'Appearance',
              children: [
                ListTile(title: Text('Theme'), subtitle: Text('System')),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the rendered title text and check its color brightness.
      final title = tester.renderObject<RenderParagraph>(
        find.text('Appearance'),
      );
      final titleColor = title.text.style!.color!;
      expect(
        titleColor.computeLuminance(),
        greaterThan(0.3),
        reason: 'Title should be light enough on a dark card background',
      );

      // ListTile title color (defaults) should also be light.
      final tileTitle = tester.renderObject<RenderParagraph>(
        find.text('Theme'),
      );
      final tileTitleColor = tileTitle.text.style!.color!;
      expect(
        tileTitleColor.computeLuminance(),
        greaterThan(0.3),
        reason: 'ListTile title should be light on dark surface',
      );

      // ListTile subtitle color should be light too.
      final subtitle = tester.renderObject<RenderParagraph>(
        find.text('System'),
      );
      final subtitleColor = subtitle.text.style!.color!;
      expect(
        subtitleColor.computeLuminance(),
        greaterThan(0.2),
        reason: 'ListTile subtitle should be visible on dark surface',
      );
    });

    testWidgets(
      'CupertinoNavigationBar title resolves to light color when CupertinoTheme brightness is dark',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            builder: (context, child) {
              return CupertinoTheme(
                data: const CupertinoThemeData(brightness: Brightness.dark),
                child: child!,
              );
            },
            home: const CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(middle: Text('Settings')),
              child: Placeholder(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final title = tester.renderObject<RenderParagraph>(
          find.text('Settings'),
        );
        final resolvedColor = title.text.style!.color!;
        expect(
          resolvedColor.computeLuminance(),
          greaterThan(0.4),
          reason: 'Nav-bar title must be light when brightness is dark',
        );
      },
    );
  });
}
