import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 1)
class AppSettings extends HiveObject {
  @HiveField(0)
  String themeMode;

  @HiveField(1)
  String languageCode;

  @HiveField(2)
  bool countingVibration;

  @HiveField(3)
  bool completionVibration;

  @HiveField(4)
  bool countingSound;

  @HiveField(5)
  bool completionSound;

  @HiveField(6)
  bool volumeKeyCounting;

  @HiveField(7)
  bool reminderNotifications;

  @HiveField(8)
  String defaultReminderTime;

  @HiveField(9)
  bool hasCompletedOnboarding;

  AppSettings({
    required this.themeMode,
    required this.languageCode,
    required this.countingVibration,
    required this.completionVibration,
    required this.countingSound,
    required this.completionSound,
    required this.volumeKeyCounting,
    required this.reminderNotifications,
    required this.defaultReminderTime,
    required this.hasCompletedOnboarding,
  });

  factory AppSettings.defaultSettings() => AppSettings(
        themeMode: 'system',
        languageCode: 'system',
        countingVibration: true,
        completionVibration: true,
        countingSound: false,
        completionSound: true,
        volumeKeyCounting: false,
        reminderNotifications: true,
        defaultReminderTime: '21:00',
        hasCompletedOnboarding: false,
      );

  AppSettings copyWith({
    String? themeMode,
    String? languageCode,
    bool? countingVibration,
    bool? completionVibration,
    bool? countingSound,
    bool? completionSound,
    bool? volumeKeyCounting,
    bool? reminderNotifications,
    String? defaultReminderTime,
    bool? hasCompletedOnboarding,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      countingVibration: countingVibration ?? this.countingVibration,
      completionVibration: completionVibration ?? this.completionVibration,
      countingSound: countingSound ?? this.countingSound,
      completionSound: completionSound ?? this.completionSound,
      volumeKeyCounting: volumeKeyCounting ?? this.volumeKeyCounting,
      reminderNotifications: reminderNotifications ?? this.reminderNotifications,
      defaultReminderTime: defaultReminderTime ?? this.defaultReminderTime,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}
