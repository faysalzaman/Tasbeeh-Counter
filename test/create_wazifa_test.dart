import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tesbeeh_counter/core/localization/generated/app_localizations.dart';
import 'package:tesbeeh_counter/core/storage/local_storage.dart';
import 'package:tesbeeh_counter/features/wazifa/create_wazifa_screen.dart';
import 'package:tesbeeh_counter/models/app_settings.dart';
import 'package:tesbeeh_counter/models/dhikr.dart';
import 'package:tesbeeh_counter/models/dhikr_progress.dart';
import 'package:tesbeeh_counter/providers/dhikr_provider.dart';
import 'package:tesbeeh_counter/providers/settings_provider.dart';
import 'package:tesbeeh_counter/repositories/dhikr_repository.dart';
import 'package:tesbeeh_counter/repositories/settings_repository.dart';

void main() {
  testWidgets('repeated Save presses create only one wazifa', (tester) async {
    final repo = _DelayedRepository();
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(path: '/create', builder: (_, _) => const CreateWazifaScreen()),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dhikrRepositoryProvider.overrideWithValue(repo),
          settingsRepositoryProvider.overrideWithValue(
            SettingsRepository(_SettingsStorage()),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    unawaited(router.push('/create'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'My wazifa');
    final save = find.widgetWithText(FilledButton, 'Create');
    await tester.ensureVisible(save);
    await tester.tap(save);
    // A second press before rebuild must also be ignored by the handler.
    await tester.tap(save);
    await tester.pump();
    expect(repo.calls, 1);
    expect(tester.widget<FilledButton>(save).onPressed, isNull);
    repo.saved.complete(
      Dhikr.fromMap({
        'id': 'custom',
        'name': 'My wazifa',
        'azkar': [
          {'id': 'custom', 'targetCount': 100},
        ],
      }),
    );
    await tester.pumpAndSettle();
    expect(repo.calls, 1);
    expect(find.text('Home'), findsOneWidget);
  });
}

class _DelayedRepository implements DhikrRepository {
  final saved = Completer<Dhikr>();
  int calls = 0;
  @override
  List<Dhikr> getAllDhikrs() => [];
  @override
  Map<String, DhikrProgress> getAllProgress() => {};
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #createCustomDhikr) {
      calls++;
      return saved.future;
    }
    return super.noSuchMethod(invocation);
  }
}

class _SettingsStorage implements LocalStorage {
  @override
  AppSettings getSettings() =>
      AppSettings.defaultSettings().copyWith(reminderNotifications: false);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
