import 'package:hive_flutter/hive_flutter.dart';
import '../../models/dhikr.dart';
import '../../models/app_settings.dart';
import '../constants/app_constants.dart';

class LocalStorage {
  static LocalStorage? _instance;
  static LocalStorage get instance => _instance!;

  late Box<Dhikr> _dhikrBox;
  late Box<AppSettings> _settingsBox;

  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DhikrAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AppSettingsAdapter());
    }

    _instance = LocalStorage._();
    await _instance!._initBoxes();
  }

  LocalStorage._();

  Future<void> _initBoxes() async {
    _dhikrBox = await Hive.openBox<Dhikr>(AppConstants.dhikrBox);
    _settingsBox = await Hive.openBox<AppSettings>(AppConstants.settingsBox);

    // Initialize default settings if not present
    if (_settingsBox.isEmpty) {
      await _settingsBox.put('settings', AppSettings.defaultSettings());
    }

    // Seed any missing default dhikrs (by name) so newly added
    // defaults appear for existing installs without wiping user data.
    final existingDefaultNames = _dhikrBox.values
        .where((d) => d.isDefault)
        .map((d) => d.name)
        .toSet();

    for (final dhikrData in AppConstants.defaultDhikrs) {
      final name = dhikrData['name'] as String;
      if (existingDefaultNames.contains(name)) continue;

      final dhikr = Dhikr(
        id: DateTime.now().millisecondsSinceEpoch.toString() + name,
        name: name,
        arabicText: dhikrData['arabicText'] as String?,
        transliteration: dhikrData['transliteration'] as String?,
        translation: dhikrData['translation'] as String?,
        targetCount: dhikrData['targetCount'] as int,
        isDefault: dhikrData['isDefault'] as bool,
        schedule: dhikrData['schedule'] as String?,
      );
      await _dhikrBox.put(dhikr.id, dhikr);
    }
  }

  // Dhikr operations
  List<Dhikr> getAllDhikrs() => _dhikrBox.values.toList();

  List<Dhikr> getDefaultDhikrs() =>
      _dhikrBox.values.where((d) => d.isDefault).toList();

  List<Dhikr> getCustomDhikrs() =>
      _dhikrBox.values.where((d) => !d.isDefault).toList();

  List<Dhikr> getActiveDhikrs() =>
      _dhikrBox.values.where((d) => d.currentCount > 0 && d.currentCount < d.targetCount).toList();

  Dhikr? getDhikr(String id) => _dhikrBox.get(id);

  Future<void> saveDhikr(Dhikr dhikr) async {
    await _dhikrBox.put(dhikr.id, dhikr);
  }

  Future<void> deleteDhikr(String id) async {
    await _dhikrBox.delete(id);
  }

  // Settings operations
  AppSettings getSettings() => _settingsBox.get('settings') ?? AppSettings.defaultSettings();

  Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox.put('settings', settings);
  }
}
