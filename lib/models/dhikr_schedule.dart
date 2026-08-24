enum DhikrSchedule {
  daily,
  fajr,
  morning,
  asar,
  maghrib,
  night,
  friday,
  saturday,
  sunday,
}

extension DhikrScheduleExtension on DhikrSchedule {
  String get label {
    switch (this) {
      case DhikrSchedule.daily:
        return 'Daily';
      case DhikrSchedule.fajr:
        return 'Fajr';
      case DhikrSchedule.morning:
        return 'Morning';
      case DhikrSchedule.asar:
        return 'Asar';
      case DhikrSchedule.maghrib:
        return 'Maghrib';
      case DhikrSchedule.night:
        return 'Night';
      case DhikrSchedule.friday:
        return 'Friday';
      case DhikrSchedule.saturday:
        return 'Saturday';
      case DhikrSchedule.sunday:
        return 'Sunday';
    }
  }

  String get description {
    switch (this) {
      case DhikrSchedule.daily:
        return 'Any time';
      case DhikrSchedule.fajr:
        return 'After Fajr';
      case DhikrSchedule.morning:
        return 'Daytime';
      case DhikrSchedule.asar:
        return 'After Asar';
      case DhikrSchedule.maghrib:
        return 'After Maghrib';
      case DhikrSchedule.night:
        return 'After Isha';
      case DhikrSchedule.friday:
        return 'Friday only';
      case DhikrSchedule.saturday:
        return 'Saturday only';
      case DhikrSchedule.sunday:
        return 'Sunday only';
    }
  }
}

class ScheduleHelper {
  static bool shouldShowNow(DhikrSchedule? schedule) {
    if (schedule == null || schedule == DhikrSchedule.daily) return true;

    final now = DateTime.now();
    final hour = now.hour;

    switch (schedule) {
      case DhikrSchedule.friday:
        return now.weekday == DateTime.friday;
      case DhikrSchedule.saturday:
        return now.weekday == DateTime.saturday;
      case DhikrSchedule.sunday:
        return now.weekday == DateTime.sunday;
      case DhikrSchedule.fajr:
        return hour >= 4 && hour < 9;
      case DhikrSchedule.morning:
        return hour >= 6 && hour < 17;
      case DhikrSchedule.asar:
        return hour >= 15 && hour < 19;
      case DhikrSchedule.maghrib:
        return hour >= 18 && hour < 21;
      case DhikrSchedule.night:
        return hour >= 20 || hour < 5;
      case DhikrSchedule.daily:
        return true;
    }
  }

  static List<DhikrSchedule> get activeSchedulesNow {
    final now = DateTime.now();
    final hour = now.hour;
    final weekday = now.weekday;

    final active = <DhikrSchedule>[DhikrSchedule.daily];

    if (hour >= 4 && hour < 9) active.add(DhikrSchedule.fajr);
    if (hour >= 6 && hour < 17) active.add(DhikrSchedule.morning);
    if (hour >= 15 && hour < 19) active.add(DhikrSchedule.asar);
    if (hour >= 18 && hour < 21) active.add(DhikrSchedule.maghrib);
    if (hour >= 20 || hour < 5) active.add(DhikrSchedule.night);
    if (weekday == DateTime.friday) active.add(DhikrSchedule.friday);
    if (weekday == DateTime.saturday) active.add(DhikrSchedule.saturday);
    if (weekday == DateTime.sunday) active.add(DhikrSchedule.sunday);

    return active;
  }
}
