import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:tesbeeh_counter/core/notifications/notification_service.dart';
import 'package:tesbeeh_counter/models/app_settings.dart';
import 'package:tesbeeh_counter/core/constants/app_constants.dart';
import 'package:tesbeeh_counter/models/dhikr.dart';
import 'package:tesbeeh_counter/models/dhikr_progress.dart';
import 'package:tesbeeh_counter/repositories/dhikr_repository.dart';
import 'package:tesbeeh_counter/core/storage/local_storage.dart';

void main() {
  group('Default Dhikrs Reminder Configuration', () {
    test(
      'every default dhikr has reminderEnabled = true and valid reminderTime',
      () {
        expect(AppConstants.defaultDhikrs.isNotEmpty, isTrue);

        final timeRegex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');

        for (final map in AppConstants.defaultDhikrs) {
          final id = map['id'];
          final name = map['name'];
          expect(
            map['reminderEnabled'],
            isTrue,
            reason: 'Dhikr "$name" ($id) must have reminderEnabled: true',
          );
          expect(
            map['reminderTime'],
            isNotNull,
            reason: 'Dhikr "$name" ($id) must have a non-null reminderTime',
          );

          final time = map['reminderTime'] as String;
          expect(
            timeRegex.hasMatch(time),
            isTrue,
            reason:
                'Dhikr "$name" ($id) has invalid time format "$time". Expected HH:mm',
          );
        }
      },
    );

    test('Dhikr model parses reminderEnabled and reminderTime from map', () {
      for (final map in AppConstants.defaultDhikrs) {
        final dhikr = Dhikr.fromMap(Map<String, dynamic>.from(map));
        expect(dhikr.reminderEnabled, isTrue);
        expect(dhikr.reminderTime, equals(map['reminderTime']));

        final serialized = dhikr.toMap();
        expect(serialized['reminderEnabled'], isTrue);
        expect(serialized['reminderTime'], equals(map['reminderTime']));
      }
    });

    test(
      'DhikrRepository effective reminder resolution works for default and overridden dhikrs',
      () {
        final sampleMap = AppConstants.defaultDhikrs.firstWhere(
          (d) => d['id'] == 'durood_friday_80',
        );
        final dhikr = Dhikr.fromMap(Map<String, dynamic>.from(sampleMap));

        final repo = DhikrRepository(_FakeLocalStorage());

        // Case 1: No progress entry (clean install) -> uses defaults
        expect(repo.isReminderEnabledFor(dhikr, null), isTrue);
        expect(repo.getEffectiveReminderTime(dhikr, null), equals('16:30'));

        // Case 2: Progress created by counter increment (no custom reminder time set) -> still uses defaults
        final incrementProgress = DhikrProgress(id: dhikr.id, currentCount: 5);
        expect(repo.isReminderEnabledFor(dhikr, incrementProgress), isTrue);
        expect(
          repo.getEffectiveReminderTime(dhikr, incrementProgress),
          equals('16:30'),
        );

        // Case 3: Progress customized by user (e.g. disabled reminder)
        final disabledProgress = DhikrProgress(
          id: dhikr.id,
          reminderEnabled: false,
          reminderTime: '16:30',
        );
        expect(repo.isReminderEnabledFor(dhikr, disabledProgress), isFalse);

        // Case 4: Progress customized by user (changed reminder time)
        final changedTimeProgress = DhikrProgress(
          id: dhikr.id,
          reminderEnabled: true,
          reminderTime: '18:00',
        );
        expect(repo.isReminderEnabledFor(dhikr, changedTimeProgress), isTrue);
        expect(
          repo.getEffectiveReminderTime(dhikr, changedTimeProgress),
          equals('18:00'),
        );
      },
    );
  });

  group('Reminder synchronization', () {
    late _FakeLocalStorage storage;
    late _FakeNotifications notifications;
    late DhikrRepository repo;

    setUp(() {
      storage = _FakeLocalStorage();
      notifications = _FakeNotifications();
      repo = DhikrRepository(storage, notifications: notifications);
    });

    test(
      'schedules every default and new custom dhikr at its own time',
      () async {
        final custom = await repo.createCustomDhikr(name: 'Custom');
        expect(storage.getProgress(custom.id)!.reminderEnabled, isTrue);
        expect(storage.getProgress(custom.id)!.reminderTime, '21:00');
        await repo.syncAllReminders();
        expect(notifications.scheduled.length, storage.dhikrs.length);
        for (final dhikr in storage.dhikrs) {
          final scheduled =
              notifications.scheduled[DhikrRepository.reminderId(dhikr.id)]!;
          expect(scheduled.payload, dhikr.id);
          expect(scheduled.time, dhikr.reminderTime ?? '21:00');
        }
      },
    );

    test('custom time survives counting and is replaced when edited', () async {
      final custom = await repo.createCustomDhikr(
        name: 'Custom',
        reminderTime: '08:15',
      );
      final id = DhikrRepository.reminderId(custom.id);
      await repo.incrementCount(custom.id);
      await repo.syncAllReminders();
      expect(notifications.scheduled[id]!.time, '08:15');
      await repo.updateDhikrReminder(
        dhikrId: custom.id,
        enabled: true,
        reminderTime: '18:45',
      );
      expect(notifications.scheduled[id]!.time, '18:45');
      await repo.updateDhikrReminder(dhikrId: custom.id, enabled: false);
      expect(notifications.scheduled.containsKey(id), isFalse);
    });

    test('legacy custom reminder without time uses global fallback', () async {
      final custom = await repo.createCustomDhikr(name: 'Legacy');
      storage.progress[custom.id] = DhikrProgress(
        id: custom.id,
        reminderEnabled: false,
      );
      storage.settings = storage.settings.copyWith(
        defaultReminderTime: '19:25',
      );
      await repo.syncReminder(custom.id);
      expect(
        notifications.scheduled[DhikrRepository.reminderId(custom.id)]!.time,
        '19:25',
      );
    });

    test('global off cancels all reminders and on restores them', () async {
      await repo.createCustomDhikr(name: 'Custom');
      await repo.syncAllReminders();
      storage.settings = storage.settings.copyWith(
        reminderNotifications: false,
      );
      await repo.syncAllReminders();
      expect(notifications.scheduled, isEmpty);
      storage.settings = storage.settings.copyWith(reminderNotifications: true);
      await repo.syncAllReminders();
      expect(notifications.scheduled.length, storage.dhikrs.length);
    });

    test(
      'invalid time cancels stale reminder instead of scheduling midnight',
      () async {
        final custom = await repo.createCustomDhikr(name: 'Custom');
        await repo.updateDhikrReminder(
          dhikrId: custom.id,
          enabled: true,
          reminderTime: '25:70',
        );
        expect(
          notifications.scheduled.containsKey(
            DhikrRepository.reminderId(custom.id),
          ),
          isFalse,
        );
      },
    );

    test(
      'removes legacy and orphan IDs, and deletion cancels current ID',
      () async {
        final custom = await repo.createCustomDhikr(name: 'Custom');
        notifications.pending = [
          PendingNotificationRequest(42, '', '', custom.id),
          const PendingNotificationRequest(43, '', '', 'deleted-dhikr'),
          const PendingNotificationRequest(44, '', '', null),
        ];
        await repo.syncAllReminders();
        expect(notifications.cancelled, containsAll([42, 43]));
        expect(notifications.cancelled, isNot(contains(44)));
        final id = DhikrRepository.reminderId(custom.id);
        await repo.deleteDhikr(custom.id);
        expect(notifications.scheduled.containsKey(id), isFalse);
        expect(storage.getDhikr(custom.id), isNull);
      },
    );
  });

  group('Local reminder time', () {
    setUpAll(tz_data.initializeTimeZones);

    test('uses today if upcoming, tomorrow if already passed or equal', () {
      final location = tz.getLocation('Asia/Riyadh');
      final now = tz.TZDateTime(location, 2026, 10, 8, 15, 30);
      expect(
        NotificationService.nextDailyReminder(now, 16, 0),
        tz.TZDateTime(location, 2026, 10, 8, 16),
      );
      expect(
        NotificationService.nextDailyReminder(now, 15, 30),
        tz.TZDateTime(location, 2026, 10, 9, 15, 30),
      );
      expect(
        NotificationService.nextDailyReminder(now, 8, 0),
        tz.TZDateTime(location, 2026, 10, 9, 8),
      );
    });

    test('preserves chosen hour across spring and autumn DST changes', () {
      final location = tz.getLocation('America/New_York');
      for (final now in [
        tz.TZDateTime(location, 2026, 3, 7, 22),
        tz.TZDateTime(location, 2026, 10, 31, 22),
      ]) {
        final next = NotificationService.nextDailyReminder(now, 9, 15);
        expect(next.day, now.day == 31 ? 1 : 8);
        expect(next.hour, 9);
        expect(next.minute, 15);
      }
    });
  });
}

class _FakeLocalStorage implements LocalStorage {
  final dhikrs = AppConstants.defaultDhikrs
      .map((map) => Dhikr.fromMap(Map<String, dynamic>.from(map)))
      .toList();
  final progress = <String, DhikrProgress>{};
  AppSettings settings = AppSettings.defaultSettings();

  @override
  AppSettings getSettings() => settings;
  @override
  List<Dhikr> getAllDhikrs() => List.of(dhikrs);
  @override
  Dhikr? getDhikr(String id) => dhikrs.where((d) => d.id == id).firstOrNull;
  @override
  DhikrProgress? getProgress(String id) => progress[id];
  @override
  Future<void> saveCustomDhikr(Dhikr dhikr) async => dhikrs.add(dhikr);
  @override
  Future<void> saveProgress(DhikrProgress value) async =>
      progress[value.id] = value;
  @override
  Future<void> deleteDhikr(String id) async {
    dhikrs.removeWhere((d) => d.id == id);
    progress.remove(id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeNotifications implements NotificationService {
  final scheduled = <int, ({String time, String? payload})>{};
  final cancelled = <int>[];
  List<PendingNotificationRequest> pending = [];

  @override
  Future<List<PendingNotificationRequest>> pendingReminders() async => pending;
  @override
  Future<bool> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    scheduled[id] = (
      time:
          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
      payload: payload,
    );
    return true;
  }

  @override
  Future<void> cancelReminder(int id) async {
    cancelled.add(id);
    scheduled.remove(id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
