import 'package:hive_flutter/hive_flutter.dart';
import '../../models/app_settings.dart';
import '../../models/dhikr.dart';
import '../../models/dhikr_progress.dart';
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
    _progressBox = await Hive.openBox<DhikrProgress>(AppConstants.dhikrProgressBox);
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

  // --- Settings ---

  AppSettings getSettings() =>
      _settingsBox.get('settings') ?? AppSettings.defaultSettings();

  Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox.put('settings', settings);
  }
}
