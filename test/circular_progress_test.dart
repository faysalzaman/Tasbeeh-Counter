import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tesbeeh_counter/core/localization/generated/app_localizations.dart';
import 'package:tesbeeh_counter/core/theme/app_theme.dart';
import 'package:tesbeeh_counter/features/counter/widgets/circular_progress.dart';

void main() {
  Widget buildTestableWidget({
    required Widget child,
    ThemeData? theme,
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: theme ?? AppTheme.lightTheme,
      home: Scaffold(
        body: Center(
          child: child,
        ),
      ),
    );
  }

  group('CircularProgressWidget Tests', () {
    testWidgets('renders count, percentage, and target properly at 50% progress',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: const CircularProgressWidget(
            progress: 0.5,
            currentCount: 16,
            targetCount: 33,
            remainingCount: 17,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('16'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('/ 33'), findsOneWidget);
      expect(find.textContaining('17'), findsOneWidget);
    });

    testWidgets('renders completed state when count reaches target',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: const CircularProgressWidget(
            progress: 1.0,
            currentCount: 33,
            targetCount: 33,
            remainingCount: 0,
            isCompleted: true,
            showCompletionAnimation: true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('33'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('/ 33'), findsOneWidget);
      expect(find.textContaining('Completed'), findsOneWidget);
    });

    testWidgets('tapping on CircularProgressWidget triggers onTap callback',
        (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          child: CircularProgressWidget(
            progress: 0.1,
            currentCount: 1,
            targetCount: 33,
            remainingCount: 32,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(CircularProgressWidget));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('renders properly in dark mode', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          theme: AppTheme.darkTheme,
          child: const CircularProgressWidget(
            progress: 0.75,
            currentCount: 25,
            targetCount: 33,
            remainingCount: 8,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('25'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
    });
  });
}
