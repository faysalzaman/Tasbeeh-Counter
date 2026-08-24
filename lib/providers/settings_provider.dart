import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/local_storage.dart';
import '../models/app_settings.dart';
import '../repositories/dhikr_repository.dart';
import '../repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(LocalStorage.instance);
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repository);
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(_repository.getSettings());

  Future<void> updateTheme(String themeMode) async {
    await _repository.updateTheme(themeMode);
    state = _repository.getSettings();
  }

  Future<void> updateLanguage(String languageCode) async {
    await _repository.updateLanguage(languageCode);
    state = _repository.getSettings();
  }

  Future<void> updateCountingVibration(bool enabled) async {
    await _repository.updateCountingVibration(enabled);
    state = _repository.getSettings();
  }

  Future<void> updateCompletionVibration(bool enabled) async {
    await _repository.updateCompletionVibration(enabled);
    state = _repository.getSettings();
  }

  Future<void> updateCountingSound(bool enabled) async {
    await _repository.updateCountingSound(enabled);
    state = _repository.getSettings();
  }

  Future<void> updateCompletionSound(bool enabled) async {
    await _repository.updateCompletionSound(enabled);
    state = _repository.getSettings();
  }

  Future<void> updateVolumeKeyCounting(bool enabled) async {
    await _repository.updateVolumeKeyCounting(enabled);
    state = _repository.getSettings();
  }

  Future<void> updateReminderNotifications(bool enabled) async {
    await _repository.updateReminderNotifications(enabled);
    state = _repository.getSettings();
    // Reschedule (if enabled) or cancel every wazifa reminder based on the
    // new global setting.
    await DhikrRepository(LocalStorage.instance).syncAllReminders();
  }

  Future<void> updateDefaultReminderTime(String time) async {
    await _repository.updateDefaultReminderTime(time);
    state = _repository.getSettings();
  }

  Future<void> completeOnboarding() async {
    await _repository.completeOnboarding();
    state = _repository.getSettings();
  }
}
