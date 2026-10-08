import 'package:flutter/foundation.dart';
import '../core/notifications/notification_service.dart';
import '../core/storage/local_storage.dart';
import '../models/dhikr.dart';
import '../models/dhikr_progress.dart';

class DhikrRepository {
  final LocalStorage _storage;
  final NotificationService _notifications;

  DhikrRepository(this._storage, {NotificationService? notifications})
    : _notifications = notifications ?? NotificationService();

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
  }

  // --- Progress ---

  DhikrProgress? getProgress(String id) => _storage.getProgress(id);

  Map<String, DhikrProgress> getAllProgress() => _storage.getAllProgress();

  Future<void> saveProgress(DhikrProgress progress) async {
    await _storage.saveProgress(progress);
  }

  Future<DhikrProgress> incrementCount(String id) async {
    final progress = _storage.getProgress(id) ?? DhikrProgress(id: id);
    final updated = progress.copyWith(
      currentCount: progress.currentCount + 1,
      lastSessionDate: DateTime.now(),
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
      lastSessionDate: DateTime.now(),
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
        lastSessionDate: DateTime.now(),
      );
      await _storage.saveProgress(updated);
    } else {
      final updated = progress.copyWith(
        isCompleted: true,
        currentCount: targetCount,
        lastSessionDate: DateTime.now(),
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
      startDate: startDate,
      numberOfDays: numberOfDays,
      notes: notes,
      schedule: schedule,
    );

    if (numberOfDays != null && startDate != null) {
      progress.endDate = startDate.add(Duration(days: numberOfDays));
    }

    await _storage.saveCustomDhikr(dhikr);
    await _storage.saveProgress(progress);
    await _syncReminderFor(dhikr, progress);
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

  Future<void> _syncReminderFor(Dhikr dhikr, DhikrProgress? progress) async {
    final id = reminderId(dhikr.id);
    final settings = _storage.getSettings();
    final reminderEnabled = isReminderEnabledFor(dhikr, progress);
    final reminderTime = getEffectiveReminderTime(dhikr, progress);

    final shouldRemind =
        reminderEnabled &&
        reminderTime != null &&
        reminderTime.isNotEmpty &&
        settings.reminderNotifications;

    if (shouldRemind) {
      final match = RegExp(
        r'^([01]\d|2[0-3]):([0-5]\d)$',
      ).firstMatch(reminderTime);
      if (match == null) {
        debugPrint('DhikrRepository: invalid reminder time "$reminderTime"');
        await _notifications.cancelReminder(id);
        return;
      }
      final hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      debugPrint(
        'DhikrRepository: scheduling daily reminder for "${dhikr.name}" (id=$id) at $hour:$minute',
      );
      final ok = await _notifications.scheduleDailyReminder(
        id: id,
        title: dhikr.name,
        body: "It's time for your dhikr: ${dhikr.name}",
        hour: hour,
        minute: minute,
        payload: dhikr.id,
      );
      if (!ok) {
        debugPrint(
          'DhikrRepository: FAILED to schedule reminder for "${dhikr.name}"',
        );
      }
    } else {
      debugPrint(
        'DhikrRepository: cancelling reminder for "${dhikr.name}" (id=$id)',
      );
      await _notifications.cancelReminder(id);
    }
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
    final dhikr = getDhikr(id);
    if (dhikr == null) {
      await _notifications.cancelReminder(reminderId(id));
      return;
    }
    final progress = getProgress(id);
    await _syncReminderFor(dhikr, progress);
  }

  /// Syncs reminders for every dhikr (both default dhikrs and custom wazaif).
  /// Call on app start and whenever the global reminder setting changes.
  Future<void> syncAllReminders() async {
    final all = getAllDhikrs();
    // Remove legacy IDs and reminders belonging to deleted azkaar. Use the
    // payload so unrelated notifications are left alone.
    final ids = {for (final dhikr in all) dhikr.id: reminderId(dhikr.id)};
    for (final pending in await _notifications.pendingReminders()) {
      final payload = pending.payload;
      if (payload != null && payload.isNotEmpty && ids[payload] != pending.id) {
        await _notifications.cancelReminder(pending.id);
      }
    }
    for (final dhikr in all) {
      final progress = getProgress(dhikr.id);
      await _syncReminderFor(dhikr, progress);
    }
  }
}
