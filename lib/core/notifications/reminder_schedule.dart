import '../../models/dhikr_schedule.dart';

/// Calendar dates are local. The end date is exclusive: a one-day wazifa
/// starting Monday includes Monday and ends at Tuesday midnight.
class ReminderSchedule {
  final int hour;
  final int minute;
  final int? weekday;
  final DateTime? startDate;
  final DateTime? endDate;

  const ReminderSchedule({
    required this.hour,
    required this.minute,
    this.weekday,
    this.startDate,
    this.endDate,
  });

  static int? weekdayFor(DhikrSchedule? schedule) => switch (schedule) {
    DhikrSchedule.friday => DateTime.friday,
    DhikrSchedule.saturday => DateTime.saturday,
    DhikrSchedule.sunday => DateTime.sunday,
    _ => null,
  };

  DateTime _day(DateTime date) => DateTime(date.year, date.month, date.day);

  bool canRepeat(DateTime now) =>
      endDate == null &&
      (startDate == null || !_day(startDate!).isAfter(_day(now)));

  List<DateTime> occurrences(DateTime now, {required int limit}) {
    var day = _day(now);
    if (startDate != null && _day(startDate!).isAfter(day)) {
      day = _day(startDate!);
    }
    if (weekday != null) {
      day = DateTime(
        day.year,
        day.month,
        day.day + (weekday! - day.weekday) % 7,
      );
    }
    final dates = <DateTime>[];
    while (dates.length < limit) {
      final date = DateTime(day.year, day.month, day.day, hour, minute);
      if (endDate != null && !date.isBefore(_day(endDate!))) break;
      if (date.isAfter(now)) dates.add(date);
      day = DateTime(day.year, day.month, day.day + (weekday == null ? 1 : 7));
    }
    return dates;
  }
}
