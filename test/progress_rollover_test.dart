import 'package:flutter_test/flutter_test.dart';
import 'package:tesbeeh_counter/core/storage/progress_rollover.dart';
import 'package:tesbeeh_counter/models/dhikr.dart';
import 'package:tesbeeh_counter/models/dhikr_progress.dart';

void main() {
  final daily = Dhikr.fromMap({
    'id': 'daily',
    'name': 'Daily',
    'reminderEnabled': true,
    'reminderTime': '08:00',
  });
  final now = DateTime(2026, 10, 9, 0, 1);

  test(
    'completed default resets next day and preserves reminder preferences',
    () {
      final progress = DhikrProgress(
        id: daily.id,
        currentCount: 100,
        isCompleted: true,
        lastSessionDate: DateTime(2026, 10, 8, 21),
        reminderEnabled: true,
        reminderTime: '09:15',
        roundCount: 2,
      );
      final updated = rolledOverProgress(daily, progress, now)!;
      expect(updated.currentCount, 0);
      expect(updated.isCompleted, isFalse);
      expect(updated.roundCount, 3);
      expect(updated.reminderEnabled, isTrue);
      expect(updated.reminderTime, '09:15');
      expect(rolledOverProgress(daily, updated, now), isNull);
    },
  );

  test('custom with no explicit schedule resets partial count daily', () {
    final custom = daily.copyWith(isCustom: true, reminderEnabled: false);
    final progress = DhikrProgress(
      id: daily.id,
      currentCount: 12,
      lastSessionDate: DateTime(2026, 10, 8, 14),
      roundCount: 2,
    );
    final updated = rolledOverProgress(custom, progress, now)!;
    expect(updated.currentCount, 0);
    expect(updated.roundCount, 2);
  });

  test('same-day progress is retained', () {
    final progress = DhikrProgress(
      id: daily.id,
      currentCount: 12,
      lastSessionDate: DateTime(2026, 10, 9),
    );
    expect(rolledOverProgress(daily, progress, now), isNull);
  });

  test('unscheduled counter with disabled reminder retains its count', () {
    final progress = DhikrProgress(
      id: daily.id,
      currentCount: 12,
      reminderEnabled: false,
      reminderTime: '08:00',
      lastSessionDate: DateTime(2026, 10, 8),
    );
    expect(rolledOverProgress(daily, progress, now), isNull);
  });

  test('Friday default resets at next Friday, not the following Saturday', () {
    final friday = daily.copyWith(category: DhikrCategory.friday);
    final progress = DhikrProgress(
      id: daily.id,
      currentCount: 100,
      isCompleted: true,
      lastSessionDate: DateTime(2026, 10, 2, 16),
    );
    expect(rolledOverProgress(friday, progress, DateTime(2026, 10, 3)), isNull);
    expect(rolledOverProgress(friday, progress, now)!.currentCount, 0);
  });

  test('morning and night schedules reset at their next window', () {
    for (final entry in {'morning': 6, 'night': 20}.entries) {
      final progress = DhikrProgress(
        id: daily.id,
        currentCount: 12,
        schedule: entry.key,
        lastSessionDate: DateTime(2026, 10, 8, entry.value + 1),
      );
      expect(
        rolledOverProgress(
          daily,
          progress,
          DateTime(2026, 10, 9, entry.value - 1),
        ),
        isNull,
      );
      expect(
        rolledOverProgress(
          daily,
          progress,
          DateTime(2026, 10, 9, entry.value),
        )!.currentCount,
        0,
      );
    }
  });
}
