import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import '../core/notifications/notification_service.dart';
import '../core/notifications/reminder_schedule.dart';
import '../core/storage/local_storage.dart';
import '../core/storage/progress_rollover.dart';
import '../models/dhikr.dart';
import '../models/dhikr_progress.dart';

class DhikrRepository {
  final LocalStorage _storage;
  final NotificationService _notifications;
  final DateTime Function() _now;
  static Future<void> _pendingReminderSync = Future.value();

  DhikrRepository(
    this._storage, {
    NotificationService? notifications,
    DateTime Function()? now,
  }) : _notifications = notifications ?? NotificationService(),
       _now = now ?? DateTime.now;

  /// A deterministic positive ID, shared by scheduling and cancellation.
  static int reminderId(String dhikrId) {
    var hash = 0x811c9dc5;
    for (final unit in dhikrId.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0xffffffff;
    }
    return hash & 0x7fffffff;
  }

  // --- Content ---

  List<Dhikr> getAllDhikrs() => _storage.getAllDhikrs();

  List<Dhikr> getDefaultDhikrs() => _storage.getDefaultDhikrs();

  List<Dhikr> getCustomDhikrs() => _storage.getCustomDhikrs();

  Dhikr? getDhikr(String id) => _storage.getDhikr(id);

  Future<void> saveDhikr(Dhikr dhikr) async {
    if (dhikr.isDefault) return;
    await _storage.saveCustomDhikr(dhikr);
  }

  Future<void> deleteDhikr(String id) async {
    await _notifications.cancelReminder(reminderId(id));
    await _storage.deleteDhikr(id);
    await syncAllReminders();
  }

  // --- Progress ---

  DhikrProgress? getProgress(String id) => _storage.getProgress(id);

  Map<String, DhikrProgress> getAllProgress() => _storage.getAllProgress();

  DhikrProgress? progressForCurrentPeriod(String id) {
    final dhikr = getDhikr(id);
    final progress = getProgress(id);
    if (dhikr == null || progress == null) return progress;
    return rolledOverProgress(dhikr, progress, _now()) ?? progress;
  }

  Future<Set<String>> resetExpiredSchedules() async {
    final resetIds = <String>{};
    for (final progress in getAllProgress().values.toList()) {
      final updated = progressForCurrentPeriod(progress.id);
      if (updated == null || identical(updated, progress)) continue;
      await _storage.saveProgress(updated);
      resetIds.add(progress.id);
    }
    return resetIds;
  }

  Future<void> saveProgress(DhikrProgress progress) async {
    await _storage.saveProgress(progress);
  }

  Future<DhikrProgress> incrementCount(String id) async {
    final progress = _storage.getProgress(id) ?? DhikrProgress(id: id);
    final target = getDhikr(id)?.totalTargetCount ?? 0;
    final nextCount = progress.currentCount + 1;
    final updated = progress.copyWith(
      currentCount: target > 0 ? math.min(nextCount, target) : nextCount,
      lastSessionDate: _now(),
    );
    await _storage.saveProgress(updated);
    return updated;
  }

  Future<void> resetCount(String id) async {
    final progress = _storage.getProgress(id);
    if (progress == null) return;
    final updated = progress.copyWith(
      currentCount: 0,
      roundCount: 1,
      isCompleted: false,
      lastSessionDate: _now(),
    );
    await _storage.saveProgress(updated);
  }

  Future<void> completeDhikr(String id, int targetCount) async {
    final progress = _storage.getProgress(id);
    if (progress == null) return;

    if (progress.repeatEnabled) {
      final updated = progress.copyWith(
        currentCount: 0,
        roundCount: progress.roundCount + 1,
        lastSessionDate: _now(),
      );
      await _storage.saveProgress(updated);
    } else {
      final updated = progress.copyWith(
        isCompleted: true,
        currentCount: targetCount,
        lastSessionDate: _now(),
      );
      await _storage.saveProgress(updated);
    }
  }

  Future<Dhikr> createCustomDhikr({
    required String name,
    String? arabicTitle,
    String? translation,
    String? description,
    String? arabicText,
    String? transliteration,
    int targetCount = 100,
    bool repeatEnabled = false,
    bool reminderEnabled = true,
    String? reminderTime,
    DateTime? startDate,
    int? numberOfDays,
    String? notes,
    String? schedule,
  }) async {
    final id = '${DateTime.now().millisecondsSinceEpoch}_$name';
    final dhikr = Dhikr(
      id: id,
      name: name,
      arabicTitle: arabicTitle?.isNotEmpty == true ? arabicTitle! : name,
      translation: translation ?? '',
      description: description ?? '',
      type: DhikrType.single,
      category: DhikrCategory.general,
      azkar: [
        AzkarItem(
          id: id,
          arabicText: arabicText ?? '',
          transliteration: transliteration ?? '',
          translation: translation ?? '',
          targetCount: targetCount,
        ),
      ],
      isDefault: false,
      isCustom: true,
      createdAt: DateTime.now(),
    );

    final progress = DhikrProgress(
      id: id,
      repeatEnabled: repeatEnabled,
      reminderEnabled: reminderEnabled,
      reminderTime: reminderTime ?? _storage.getSettings().defaultReminderTime,
      startDate: startDate ?? (numberOfDays != null ? _now() : null),
      numberOfDays: numberOfDays,
      notes: notes,
      schedule: schedule,
    );

    if (numberOfDays != null && progress.startDate != null) {
      final start = progress.startDate!;
      progress.endDate = DateTime(
        start.year,
        start.month,
        start.day + numberOfDays,
      );
    }

    await _storage.saveCustomDhikr(dhikr);
    await _storage.saveProgress(progress);
    await syncAllReminders();
    return dhikr;
  }

  // --- Reminders ---

  bool isReminderEnabledFor(Dhikr dhikr, DhikrProgress? progress) {
    final hasOverride = progress?.reminderTime?.isNotEmpty ?? false;
    if (hasOverride) return progress!.reminderEnabled;
    // Older custom azkaar had reminders off and no time by default. Treat
    // those unset preferences like new azkaar; explicit off preferences have
    // a saved time and are respected above.
    return dhikr.isCustom || dhikr.reminderEnabled;
  }

  String? getEffectiveReminderTime(Dhikr dhikr, DhikrProgress? progress) {
    if (progress != null &&
        progress.reminderTime != null &&
        progress.reminderTime!.isNotEmpty) {
      return progress.reminderTime;
    }
    return dhikr.reminderTime ?? _storage.getSettings().defaultReminderTime;
  }

  /// Updates or creates tracking state for a dhikr with custom reminder preferences
  /// and synchronizes notifications immediately.
  Future<void> updateDhikrReminder({
    required String dhikrId,
    required bool enabled,
    String? reminderTime,
  }) async {
    final dhikr = getDhikr(dhikrId);
    final existingProgress = getProgress(dhikrId) ?? DhikrProgress(id: dhikrId);
    final time =
        reminderTime ??
        existingProgress.reminderTime ??
        dhikr?.reminderTime ??
        _storage.getSettings().defaultReminderTime;
    final updatedProgress = existingProgress.copyWith(
      reminderEnabled: enabled,
      reminderTime: time,
    );
    await _storage.saveProgress(updatedProgress);
    await syncReminder(dhikrId);
  }

  /// Reschedules or cancels the reminder for a single dhikr based on its
  /// current progress or default settings and the global reminder setting.
  Future<void> syncReminder(String id) async {
    if (getDhikr(id) == null) {
      await _notifications.cancelReminder(reminderId(id));
    }
    await syncAllReminders();
  }

  /// Rebuild the pending plan within the OS budget, keeping the soonest dated
  /// occurrences. App startup and resume refill long-running dated schedules.
  Future<void> syncAllReminders() {
    final sync = _pendingReminderSync.then((_) => _syncAllReminders());
    _pendingReminderSync = sync.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return sync;
  }

  Future<void> _syncAllReminders() async {
    final all = getAllDhikrs();
    final pending = await _notifications.pendingReminders();
    final settings = _storage.getSettings();
    final now = _now();
    final limit = _notifications.pendingReminderLimit;
    final repeating = <_PlannedReminder>[];
    final dated = <_PlannedReminder>[];
    final activeIds = <String>{};
    for (final dhikr in all) {
      final progress = getProgress(dhikr.id);
      final time = getEffectiveReminderTime(dhikr, progress);
      final match = time == null
          ? null
          : RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$').firstMatch(time);
      if (!settings.reminderNotifications ||
          !isReminderEnabledFor(dhikr, progress) ||
          match == null) {
        continue;
      }
      final start = progress?.startDate;
      var end = progress?.endDate;
      if (end == null && progress?.numberOfDays != null) {
        final first = start ?? progress!.createdAt;
        end = DateTime(
          first.year,
          first.month,
          first.day + progress!.numberOfDays!,
        );
      }
      final schedule = ReminderSchedule(
        hour: int.parse(match.group(1)!),
        minute: int.parse(match.group(2)!),
        weekday:
            progress?.scheduleEnum == null &&
                dhikr.category == DhikrCategory.friday
            ? DateTime.friday
            : ReminderSchedule.weekdayFor(progress?.scheduleEnum),
        startDate: start,
        endDate: end,
      );
      final dates = schedule.occurrences(
        now,
        limit: schedule.canRepeat(now) ? 1 : limit,
      );
      if (dates.isEmpty) continue;
      if (schedule.canRepeat(now)) {
        activeIds.add(dhikr.id);
        repeating.add(
          _PlannedReminder(
            dhikr,
            schedule,
            dates.first,
            reminderId(dhikr.id),
            true,
          ),
        );
      } else {
        for (final date in dates) {
          final key = '${dhikr.id}::${date.year}-${date.month}-${date.day}';
          dated.add(
            _PlannedReminder(dhikr, schedule, date, reminderId(key), false),
          );
        }
      }
    }
    repeating.sort((a, b) => a.date.compareTo(b.date));
    dated.sort((a, b) => a.date.compareTo(b.date));
    final externalCount = pending
        .where((p) => p.payload == null || p.payload!.isEmpty)
        .length;
    final budget = math.max(0, limit - externalCount);
    final plan = [
      ...repeating.take(budget),
      ...dated.take(math.max(0, budget - repeating.length)),
    ];
    final wanted = plan.map((p) => p.id).toSet();
    for (final notification in pending) {
      if (notification.payload?.isNotEmpty == true &&
          !wanted.contains(notification.id)) {
        await _notifications.cancelReminder(notification.id);
      }
    }
    for (final dhikr in all) {
      if (!activeIds.contains(dhikr.id) ||
          !wanted.contains(reminderId(dhikr.id))) {
        await _notifications.cancelReminder(reminderId(dhikr.id));
      }
    }
    for (final reminder in plan) {
      final dhikr = reminder.dhikr;
      final schedule = reminder.schedule;
      final body = "It's time for your dhikr: ${dhikr.name}";
      final bool ok;
      if (!reminder.repeating) {
        ok = await _notifications.scheduleReminder(
          id: reminder.id,
          title: dhikr.name,
          body: body,
          scheduledDate: reminder.date,
          payload: dhikr.id,
        );
      } else if (schedule.weekday != null) {
        ok = await _notifications.scheduleWeeklyReminder(
          id: reminder.id,
          title: dhikr.name,
          body: body,
          hour: schedule.hour,
          minute: schedule.minute,
          weekday: schedule.weekday!,
          payload: dhikr.id,
        );
      } else {
        ok = await _notifications.scheduleDailyReminder(
          id: reminder.id,
          title: dhikr.name,
          body: body,
          hour: schedule.hour,
          minute: schedule.minute,
          payload: dhikr.id,
        );
      }
      if (!ok) {
        debugPrint('DhikrRepository: failed to schedule "${dhikr.name}"');
      }
    }
    if (dated.length > math.max(0, budget - repeating.length)) {
      debugPrint(
        'DhikrRepository: dated reminder budget reached; refill on resume',
      );
    }
  }
}

class _PlannedReminder {
  final Dhikr dhikr;
  final ReminderSchedule schedule;
  final DateTime date;
  final int id;
  final bool repeating;
  const _PlannedReminder(
    this.dhikr,
    this.schedule,
    this.date,
    this.id,
    this.repeating,
  );
}
