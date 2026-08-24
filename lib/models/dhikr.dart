import 'package:hive/hive.dart';
import 'dhikr_schedule.dart';

part 'dhikr.g.dart';

@HiveType(typeId: 0)
class Dhikr extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? arabicText;

  @HiveField(3)
  final String? transliteration;

  @HiveField(4)
  final String? translation;

  @HiveField(5)
  final int targetCount;

  @HiveField(6)
  int currentCount;

  @HiveField(7)
  final bool isDefault;

  @HiveField(8)
  bool repeatEnabled;

  @HiveField(9)
  int roundCount;

  @HiveField(10)
  bool reminderEnabled;

  @HiveField(11)
  String? reminderTime;

  @HiveField(12)
  DateTime? startDate;

  @HiveField(13)
  DateTime? endDate;

  @HiveField(14)
  int? numberOfDays;

  @HiveField(15)
  String? notes;

  @HiveField(16)
  bool isCompleted;

  @HiveField(17)
  DateTime? lastSessionDate;

  @HiveField(18)
  final DateTime createdAt;

  @HiveField(19)
  DateTime updatedAt;

  @HiveField(20)
  String? schedule;

  Dhikr({
    required this.id,
    required this.name,
    this.arabicText,
    this.transliteration,
    this.translation,
    required this.targetCount,
    this.currentCount = 0,
    required this.isDefault,
    this.repeatEnabled = false,
    this.roundCount = 1,
    this.reminderEnabled = false,
    this.reminderTime,
    this.startDate,
    this.endDate,
    this.numberOfDays,
    this.notes,
    this.isCompleted = false,
    this.lastSessionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.schedule,
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

  Dhikr copyWith({
    String? id,
    String? name,
    String? arabicText,
    String? transliteration,
    String? translation,
    int? targetCount,
    int? currentCount,
    bool? isDefault,
    bool? repeatEnabled,
    int? roundCount,
    bool? reminderEnabled,
    String? reminderTime,
    DateTime? startDate,
    DateTime? endDate,
    int? numberOfDays,
    String? notes,
    bool? isCompleted,
    DateTime? lastSessionDate,
    DateTime? updatedAt,
    String? schedule,
  }) {
    return Dhikr(
      id: id ?? this.id,
      name: name ?? this.name,
      arabicText: arabicText ?? this.arabicText,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      isDefault: isDefault ?? this.isDefault,
      repeatEnabled: repeatEnabled ?? this.repeatEnabled,
      roundCount: roundCount ?? this.roundCount,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      numberOfDays: numberOfDays ?? this.numberOfDays,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      schedule: schedule ?? this.schedule,
    );
  }

  double get progressPercentage =>
      targetCount > 0 ? (currentCount / targetCount).clamp(0.0, 1.0) : 0.0;

  int get remainingCount => (targetCount - currentCount).clamp(0, targetCount);

  bool get isInProgress => currentCount > 0 && currentCount < targetCount;
}
