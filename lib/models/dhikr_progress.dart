import 'package:hive/hive.dart';
import 'dhikr_schedule.dart';

part 'dhikr_progress.g.dart';

@HiveType(typeId: 2)
class DhikrProgress extends HiveObject {
  /// Links to the [Dhikr.id] this progress tracks.
  @HiveField(0)
  String id;

  @HiveField(1)
  int currentCount;

  @HiveField(2)
  int roundCount;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  bool repeatEnabled;

  @HiveField(5)
  bool reminderEnabled;

  @HiveField(6)
  String? reminderTime;

  @HiveField(7)
  DateTime? startDate;

  @HiveField(8)
  DateTime? endDate;

  @HiveField(9)
  int? numberOfDays;

  @HiveField(10)
  String? notes;

  @HiveField(11)
  String? schedule;

  @HiveField(12)
  DateTime? lastSessionDate;

  @HiveField(13)
  DateTime createdAt;

  @HiveField(14)
  DateTime updatedAt;

  DhikrProgress({
    required this.id,
    this.currentCount = 0,
    this.roundCount = 1,
    this.isCompleted = false,
    this.repeatEnabled = false,
    this.reminderEnabled = false,
    this.reminderTime,
    this.startDate,
    this.endDate,
    this.numberOfDays,
    this.notes,
    this.schedule,
    this.lastSessionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  DhikrSchedule? get scheduleEnum {
    if (schedule == null) return null;
    try {
      return DhikrSchedule.values.byName(schedule!);
    } catch (_) {
      return null;
    }
  }

  DhikrProgress copyWith({
    String? id,
    int? currentCount,
    int? roundCount,
    bool? isCompleted,
    bool? repeatEnabled,
    bool? reminderEnabled,
    String? reminderTime,
    DateTime? startDate,
    DateTime? endDate,
    int? numberOfDays,
    String? notes,
    String? schedule,
    DateTime? lastSessionDate,
    DateTime? updatedAt,
  }) {
    return DhikrProgress(
      id: id ?? this.id,
      currentCount: currentCount ?? this.currentCount,
      roundCount: roundCount ?? this.roundCount,
      isCompleted: isCompleted ?? this.isCompleted,
      repeatEnabled: repeatEnabled ?? this.repeatEnabled,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      numberOfDays: numberOfDays ?? this.numberOfDays,
      notes: notes ?? this.notes,
      schedule: schedule ?? this.schedule,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
