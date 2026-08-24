import '../core/storage/local_storage.dart';
import '../models/dhikr.dart';
import '../models/dhikr_progress.dart';

class DhikrRepository {
  final LocalStorage _storage;

  DhikrRepository(this._storage);

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
    bool reminderEnabled = false,
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
      reminderTime: reminderTime,
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
    return dhikr;
  }
}
