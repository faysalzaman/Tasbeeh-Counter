import '../../models/dhikr.dart';
import '../../models/dhikr_progress.dart';
import '../../models/dhikr_schedule.dart';

/// Returns fresh progress when a daily or weekly period has rolled over.
/// Reminder preferences and the wazifa's date range are preserved.
DhikrProgress? rolledOverProgress(
  Dhikr dhikr,
  DhikrProgress progress,
  DateTime now,
) {
  var schedule = progress.scheduleEnum;
  if (schedule == null) {
    final remindersEnabled = progress.reminderTime?.isNotEmpty == true
        ? progress.reminderEnabled
        : dhikr.isCustom || dhikr.reminderEnabled;
    if (!remindersEnabled) return null;
    schedule = dhikr.category == DhikrCategory.friday
        ? DhikrSchedule.friday
        : DhikrSchedule.daily;
  }
  if (progress.currentCount == 0 && !progress.isCompleted) return null;

  final today = DateTime(now.year, now.month, now.day);
  final DateTime periodStart;
  switch (schedule) {
    case DhikrSchedule.daily:
      periodStart = today;
    case DhikrSchedule.friday:
    case DhikrSchedule.saturday:
    case DhikrSchedule.sunday:
      final weekday = switch (schedule) {
        DhikrSchedule.friday => DateTime.friday,
        DhikrSchedule.saturday => DateTime.saturday,
        _ => DateTime.sunday,
      };
      periodStart = DateTime(
        now.year,
        now.month,
        now.day - (now.weekday - weekday) % 7,
      );
    case DhikrSchedule.fajr:
    case DhikrSchedule.morning:
    case DhikrSchedule.asar:
    case DhikrSchedule.maghrib:
    case DhikrSchedule.night:
      final hour = switch (schedule) {
        DhikrSchedule.fajr => 4,
        DhikrSchedule.morning => 6,
        DhikrSchedule.asar => 15,
        DhikrSchedule.maghrib => 18,
        _ => 20,
      };
      final start = DateTime(now.year, now.month, now.day, hour);
      periodStart = now.isBefore(start)
          ? DateTime(now.year, now.month, now.day - 1, hour)
          : start;
  }
  final lastActive = progress.lastSessionDate ?? progress.updatedAt;
  if (!lastActive.isBefore(periodStart)) return null;
  return progress.copyWith(
    currentCount: 0,
    isCompleted: false,
    roundCount: progress.isCompleted
        ? progress.roundCount + 1
        : progress.roundCount,
    lastSessionDate: now,
    updatedAt: now,
  );
}
