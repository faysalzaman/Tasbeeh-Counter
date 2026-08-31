import 'package:hive_flutter/hive_flutter.dart';
import '../../models/app_settings.dart';
import '../../models/dhikr.dart';
import '../../models/dhikr_progress.dart';
import '../../models/dhikr_schedule.dart';
import '../constants/app_constants.dart';

class LocalStorage {
  static LocalStorage? _instance;
  static LocalStorage get instance => _instance!;

  /// Stores custom (user-created) dhikrs as serialized maps.
  late Box _customDhikrBox;

  /// Stores per-dhikr counting/tracking state.
  late Box<DhikrProgress> _progressBox;

  late Box<AppSettings> _settingsBox;

  /// In-memory default dhikr content, parsed once from [AppConstants].
  late final List<Dhikr> _defaultDhikrs;

  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AppSettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(DhikrProgressAdapter());
    }

    _instance = LocalStorage._();
    await _instance!._initBoxes();
  }

  LocalStorage._();

  Future<void> _initBoxes() async {
    _customDhikrBox = await Hive.openBox(AppConstants.customDhikrBox);
    _progressBox = await Hive.openBox<DhikrProgress>(
      AppConstants.dhikrProgressBox,
    );
    _settingsBox = await Hive.openBox<AppSettings>(AppConstants.settingsBox);

    // Initialize default settings if not present
    if (_settingsBox.isEmpty) {
      await _settingsBox.put('settings', AppSettings.defaultSettings());
    }

    _defaultDhikrs = AppConstants.defaultDhikrs
        .map((map) => Dhikr.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  // --- Dhikr content ---

  List<Dhikr> getDefaultDhikrs() => List.unmodifiable(_defaultDhikrs);

  List<Dhikr> getCustomDhikrs() => _customDhikrBox.values
      .map((raw) => Dhikr.fromMap(Map<String, dynamic>.from(raw as Map)))
      .toList();

  List<Dhikr> getAllDhikrs() => [..._defaultDhikrs, ...getCustomDhikrs()];

  Dhikr? getDhikr(String id) {
    for (final d in _defaultDhikrs) {
      if (d.id == id) return d;
    }
    final raw = _customDhikrBox.get(id);
    if (raw != null) {
      return Dhikr.fromMap(Map<String, dynamic>.from(raw as Map));
    }
    return null;
  }

  Future<void> saveCustomDhikr(Dhikr dhikr) async {
    await _customDhikrBox.put(dhikr.id, dhikr.toMap());
  }

  Future<void> deleteDhikr(String id) async {
    await _customDhikrBox.delete(id);
    await _progressBox.delete(id);
  }

  // --- Dhikr progress (tracking state) ---

  DhikrProgress? getProgress(String id) => _progressBox.get(id);

  Map<String, DhikrProgress> getAllProgress() {
    return {for (final p in _progressBox.values) p.id: p};
  }

  Future<void> saveProgress(DhikrProgress progress) async {
    await _progressBox.put(progress.id, progress);
  }

  /// Resets progress of every scheduled dhikr whose schedule period has
  /// rolled over since its last session:
  /// - daily: resets at midnight
  /// - friday/saturday/sunday: resets when that weekday begins
  /// - fajr/morning/asar/maghrib/night: resets when the time window reopens
  ///
  /// Completed dhikrs start a fresh round; partially counted ("continue")
  /// dhikrs restart from zero. Dhikrs without a schedule are left untouched.
  /// Runs on the splash screen, before any provider reads the progress box.
  Future<void> resetExpiredSchedules() async {
    final now = DateTime.now();

    for (final progress in _progressBox.values.toList()) {
      final schedule = progress.scheduleEnum;
      if (schedule == null) continue;
      if (progress.currentCount == 0 && !progress.isCompleted) continue;

      final lastActive = progress.lastSessionDate ?? progress.updatedAt;
      if (!lastActive.isBefore(_currentPeriodStart(schedule, now))) continue;

      await _progressBox.put(
        progress.id,
        progress.copyWith(
          currentCount: 0,
          isCompleted: false,
          roundCount: progress.isCompleted
              ? progress.roundCount + 1
              : progress.roundCount,
        ),
      );
    }
  }

  DateTime _currentPeriodStart(DhikrSchedule schedule, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);

    switch (schedule) {
      case DhikrSchedule.daily:
        return today;

      case DhikrSchedule.friday:
      case DhikrSchedule.saturday:
      case DhikrSchedule.sunday:
        final weekday = switch (schedule) {
          DhikrSchedule.friday => DateTime.friday,
          DhikrSchedule.saturday => DateTime.saturday,
          _ => DateTime.sunday,
        };
        return today.subtract(Duration(days: (now.weekday - weekday) % 7));

      case DhikrSchedule.fajr:
      case DhikrSchedule.morning:
      case DhikrSchedule.asar:
      case DhikrSchedule.maghrib:
        final startHour = switch (schedule) {
          DhikrSchedule.fajr => 4,
          DhikrSchedule.morning => 6,
          DhikrSchedule.asar => 15,
          _ => 18,
        };
        final start = DateTime(now.year, now.month, now.day, startHour);
        return now.isBefore(start)
            ? start.subtract(const Duration(days: 1))
            : start;

      case DhikrSchedule.night:
        final tonight = DateTime(now.year, now.month, now.day, 20);
        return now.isBefore(tonight)
            ? DateTime(now.year, now.month, now.day - 1, 20)
            : tonight;
    }
  }

  // --- Settings ---

  AppSettings getSettings() =>
      _settingsBox.get('settings') ?? AppSettings.defaultSettings();

  Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox.put('settings', settings);
  }
}
