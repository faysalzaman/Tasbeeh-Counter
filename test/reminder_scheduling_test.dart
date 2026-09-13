import 'package:flutter_test/flutter_test.dart';
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
}

class _FakeLocalStorage implements LocalStorage {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
