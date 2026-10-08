import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tesbeeh_counter/providers/settings_provider.dart';
import 'package:tesbeeh_counter/repositories/settings_repository.dart';
import 'package:tesbeeh_counter/core/storage/local_storage.dart';
import 'package:tesbeeh_counter/models/app_settings.dart';
import 'package:tesbeeh_counter/models/dhikr.dart';
import 'package:tesbeeh_counter/models/dhikr_progress.dart';
import 'package:tesbeeh_counter/providers/counter_provider.dart';
import 'package:tesbeeh_counter/providers/dhikr_provider.dart';
import 'package:tesbeeh_counter/repositories/dhikr_repository.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  late _MemoryStorage storage;
  late DhikrRepository repository;
  late ProgressListNotifier progressNotifier;
  late CounterNotifier counter;

  setUpAll(() {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (_) async => null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global/events'),
      (_) async => null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (call) async {
        if (call.method == 'create') {
          final id = (call.arguments as Map)['playerId'];
          messenger.setMockMethodCallHandler(
            MethodChannel('xyz.luan/audioplayers/events/$id'),
            (_) async => null,
          );
        }
        return null;
      },
    );
  });

  setUp(() {
    storage = _MemoryStorage();
    repository = DhikrRepository(storage);
    progressNotifier = ProgressListNotifier(repository);
    counter = CounterNotifier(
      repository,
      AppSettings.defaultSettings().copyWith(
        countingVibration: false,
        completionVibration: false,
        countingSound: false,
        completionSound: false,
      ),
      progressNotifier,
    );
    counter.setDhikr(storage.dhikrs['first']!);
  });

  tearDown(() {
    counter.dispose();
    progressNotifier.dispose();
  });

  test('settings changes preserve active counter and pending writes', () async {
    final container = ProviderContainer(
      overrides: [
        dhikrRepositoryProvider.overrideWithValue(repository),
        settingsRepositoryProvider.overrideWithValue(
          SettingsRepository(storage),
        ),
      ],
    );
    addTearDown(container.dispose);
    final active = container.read(counterStateProvider.notifier);
    active.setDhikr(storage.dhikrs['first']!);
    storage.gate = Completer<void>();
    final input = active.increment('first');
    await container.read(settingsProvider.notifier).updateTheme('dark');
    expect(container.read(counterStateProvider.notifier), same(active));
    expect(container.read(counterStateProvider).displayCount, 1);
    final second = active.increment('first');
    storage.gate!.complete();
    await Future.wait([input, second]);
    expect(storage.getProgress('first')!.currentCount, 2);
    expect(container.read(counterStateProvider).displayCount, 2);
  });

  test(
    'active completed counter resets when app resumes on the next day',
    () async {
      var now = DateTime(2026, 10, 8, 21);
      final repo = DhikrRepository(storage, now: () => now);
      final active = CounterNotifier(repo, storage.settings, progressNotifier);
      addTearDown(active.dispose);
      storage.progress['first'] = DhikrProgress(
        id: 'first',
        currentCount: 3,
        isCompleted: true,
        schedule: 'daily',
        lastSessionDate: now,
      );
      active.setDhikr(storage.dhikrs['first']!);
      expect(active.state.isCompleted, isTrue);
      now = DateTime(2026, 10, 9, 0, 1);
      await active.refreshExpiredSchedules();
      expect(active.state.displayCount, 0);
      expect(active.state.isCompleted, isFalse);
      expect(storage.getProgress('first')!.roundCount, 2);
      await active.refreshExpiredSchedules();
      expect(storage.getProgress('first')!.roundCount, 2);
      await active.increment('first');
      expect(active.state.displayCount, 1);
      expect(storage.getProgress('first')!.currentCount, 1);
    },
  );

  test(
    'opening yesterday completed default starts with fresh progress',
    () async {
      final now = DateTime(2026, 10, 9, 8);
      storage.dhikrs['first'] = storage.dhikrs['first']!.copyWith(
        reminderEnabled: true,
      );
      storage.progress['first'] = DhikrProgress(
        id: 'first',
        currentCount: 3,
        isCompleted: true,
        lastSessionDate: DateTime(2026, 10, 8, 21),
      );
      final active = CounterNotifier(
        DhikrRepository(storage, now: () => now),
        storage.settings,
        progressNotifier,
      );
      addTearDown(active.dispose);
      active.setDhikr(storage.dhikrs['first']!);
      expect(active.state.displayCount, 0);
      expect(active.state.isCompleted, isFalse);
      await active.increment('first');
      expect(storage.getProgress('first')!.currentCount, 1);
      expect(storage.getProgress('first')!.isCompleted, isFalse);
    },
  );

  test('rapid mixed inputs stop at target while storage is blocked', () async {
    storage.gate = Completer<void>();
    final inputs = List.generate(30, (_) => counter.increment('first'));
    expect(counter.state.displayCount, 3);
    expect(counter.state.isCompleted, isTrue);
    expect(storage.getProgress('first'), isNull);
    storage.gate!.complete();
    await Future.wait(inputs);
    expect(storage.getProgress('first')!.currentCount, 3);
    expect(storage.getProgress('first')!.isCompleted, isTrue);
    expect(storage.savedCounts.every((count) => count <= 3), isTrue);
    await counter.increment('first');
    expect(counter.state.displayCount, 3);
  });

  test('rapid presses below target are saved individually', () async {
    storage.dhikrs['first'] = _dhikr('first', 100);
    counter.setDhikr(storage.dhikrs['first']!);
    storage.gate = Completer<void>();
    final inputs = List.generate(20, (_) => counter.increment('first'));
    expect(counter.state.displayCount, 20);
    storage.gate!.complete();
    await Future.wait(inputs);
    expect(storage.getProgress('first')!.currentCount, 20);
    expect(counter.state.isCompleted, isFalse);
  });

  test(
    'repeat mode blocks input during completion and starts one round',
    () async {
      storage.progress['first'] = DhikrProgress(
        id: 'first',
        repeatEnabled: true,
      );
      counter.setDhikr(storage.dhikrs['first']!);
      final inputs = List.generate(20, (_) => counter.increment('first'));
      expect(counter.state.displayCount, 3);
      await counter.saveAndExit('first');
      expect(storage.getProgress('first')!.roundCount, 2);
      expect(storage.getProgress('first')!.currentCount, 0);
      await counter.increment('first');
      expect(counter.state.displayCount, 3);
      await Future.wait(inputs);
      expect(counter.state.displayCount, 0);
      expect(counter.state.roundCount, 2);
      expect(counter.state.isCompleted, isFalse);
      await counter.increment('first');
      expect(counter.state.displayCount, 1);
      expect(storage.getProgress('first')!.currentCount, 1);
    },
  );

  test(
    'reset is saved after pending presses without resurrecting old counts',
    () async {
      storage.gate = Completer<void>();
      final inputs = List.generate(3, (_) => counter.increment('first'));
      final reset = counter.reset('first');
      expect(counter.state.displayCount, 0);
      expect(counter.state.isCompleted, isFalse);
      storage.gate!.complete();
      await Future.wait([...inputs, reset]);
      expect(storage.getProgress('first')!.currentCount, 0);
      expect(storage.getProgress('first')!.isCompleted, isFalse);
      await counter.increment('first');
      expect(counter.state.displayCount, 1);
    },
  );

  test('previous repeat timer cannot overwrite another dhikr', () async {
    storage.progress['first'] = DhikrProgress(id: 'first', repeatEnabled: true);
    counter.setDhikr(storage.dhikrs['first']!);
    final inputs = List.generate(3, (_) => counter.increment('first'));
    await counter.saveAndExit('first');
    counter.setDhikr(storage.dhikrs['second']!);
    await counter.increment('second');
    await Future.wait(inputs);
    expect(counter.state.displayCount, 1);
    expect(counter.state.roundCount, 1);
    expect(counter.state.isCompleted, isFalse);
  });

  test('opening an old excessive count repairs display and storage', () async {
    storage.progress['first'] = DhikrProgress(id: 'first', currentCount: 8);
    counter.setDhikr(storage.dhikrs['first']!);
    expect(counter.state.displayCount, 3);
    expect(counter.state.isCompleted, isTrue);
    await counter.saveAndExit('first');
    expect(storage.getProgress('first')!.currentCount, 3);
    expect(storage.getProgress('first')!.isCompleted, isTrue);
  });

  test('save and exit waits for pending presses', () async {
    storage.gate = Completer<void>();
    final first = counter.increment('first');
    final second = counter.increment('first');
    var saved = false;
    final exit = counter.saveAndExit('first').then((_) => saved = true);
    expect(saved, isFalse);
    storage.gate!.complete();
    await Future.wait([first, second, exit]);
    expect(saved, isTrue);
    expect(storage.getProgress('first')!.currentCount, 2);
  });
}

Dhikr _dhikr(String id, int target) => Dhikr.fromMap({
  'id': id,
  'name': id,
  'azkar': [
    {'id': id, 'targetCount': target},
  ],
});

class _MemoryStorage implements LocalStorage {
  AppSettings settings = AppSettings.defaultSettings().copyWith(
    countingVibration: false,
    completionVibration: false,
    countingSound: false,
    completionSound: false,
  );
  @override
  AppSettings getSettings() => settings;
  @override
  Future<void> saveSettings(AppSettings value) async => settings = value;
  final dhikrs = {'first': _dhikr('first', 3), 'second': _dhikr('second', 10)};
  final progress = <String, DhikrProgress>{};
  final savedCounts = <int>[];
  Completer<void>? gate;

  @override
  Dhikr? getDhikr(String id) => dhikrs[id];
  @override
  DhikrProgress? getProgress(String id) => progress[id];
  @override
  Map<String, DhikrProgress> getAllProgress() => Map.of(progress);
  @override
  Future<void> saveProgress(DhikrProgress value) async {
    await gate?.future;
    progress[value.id] = value;
    savedCounts.add(value.currentCount);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
