import '../core/storage/local_storage.dart';
import '../models/app_settings.dart';

class SettingsRepository {
  final LocalStorage _storage;

  SettingsRepository(this._storage);

  AppSettings getSettings() => _storage.getSettings();

  Future<void> saveSettings(AppSettings settings) async {
    await _storage.saveSettings(settings);
  }

  Future<void> updateTheme(String themeMode) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(themeMode: themeMode));
  }

  Future<void> updateLanguage(String languageCode) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(languageCode: languageCode));
  }

  Future<void> updateCountingVibration(bool enabled) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(countingVibration: enabled));
  }

  Future<void> updateCompletionVibration(bool enabled) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(completionVibration: enabled));
  }

  Future<void> updateCountingSound(bool enabled) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(countingSound: enabled));
  }

  Future<void> updateCompletionSound(bool enabled) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(completionSound: enabled));
  }

  Future<void> updateVolumeKeyCounting(bool enabled) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(volumeKeyCounting: enabled));
  }

  Future<void> updateReminderNotifications(bool enabled) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(reminderNotifications: enabled));
  }

  Future<void> updateDefaultReminderTime(String time) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(defaultReminderTime: time));
  }

  Future<void> completeOnboarding() async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(hasCompletedOnboarding: true));
  }
}
