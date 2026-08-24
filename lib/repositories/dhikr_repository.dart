import '../core/storage/local_storage.dart';
import '../models/dhikr.dart';

class DhikrRepository {
  final LocalStorage _storage;

  DhikrRepository(this._storage);

  List<Dhikr> getAllDhikrs() => _storage.getAllDhikrs();

  List<Dhikr> getDefaultDhikrs() => _storage.getDefaultDhikrs();

  List<Dhikr> getCustomDhikrs() => _storage.getCustomDhikrs();

  List<Dhikr> getActiveDhikrs() => _storage.getActiveDhikrs();

  Dhikr? getDhikr(String id) => _storage.getDhikr(id);

  Future<void> saveDhikr(Dhikr dhikr) async {
    await _storage.saveDhikr(dhikr);
  }

  Future<void> deleteDhikr(String id) async {
    await _storage.deleteDhikr(id);
  }

  Future<void> incrementCount(String id) async {
    final dhikr = _storage.getDhikr(id);
    if (dhikr == null) return;

    final newCount = dhikr.currentCount + 1;
    final updated = dhikr.copyWith(
      currentCount: newCount,
      lastSessionDate: DateTime.now(),
    );
    await _storage.saveDhikr(updated);
  }

  Future<void> resetCount(String id) async {
    final dhikr = _storage.getDhikr(id);
    if (dhikr == null) return;

    final updated = dhikr.copyWith(
      currentCount: 0,
      roundCount: 1,
      isCompleted: false,
      lastSessionDate: DateTime.now(),
    );
    await _storage.saveDhikr(updated);
  }

  Future<void> completeDhikr(String id) async {
    final dhikr = _storage.getDhikr(id);
    if (dhikr == null) return;

    if (dhikr.repeatEnabled) {
      // Start next round
      final updated = dhikr.copyWith(
        currentCount: 0,
        roundCount: dhikr.roundCount + 1,
        lastSessionDate: DateTime.now(),
      );
      await _storage.saveDhikr(updated);
    } else {
      final updated = dhikr.copyWith(
        isCompleted: true,
        currentCount: dhikr.targetCount,
        lastSessionDate: DateTime.now(),
      );
      await _storage.saveDhikr(updated);
    }
  }

  Future<void> createCustomDhikr({
    required String name,
    String? arabicText,
    String? transliteration,
    String? translation,
    required int targetCount,
    bool repeatEnabled = false,
    bool reminderEnabled = false,
    String? reminderTime,
    DateTime? startDate,
    int? numberOfDays,
    String? notes,
  }) async {
    final id = '${DateTime.now().millisecondsSinceEpoch}_$name';
    final dhikr = Dhikr(
      id: id,
      name: name,
      arabicText: arabicText,
      transliteration: transliteration,
      translation: translation,
      targetCount: targetCount,
      isDefault: false,
      repeatEnabled: repeatEnabled,
      reminderEnabled: reminderEnabled,
      reminderTime: reminderTime,
      startDate: startDate,
      numberOfDays: numberOfDays,
      notes: notes,
    );

    if (numberOfDays != null && startDate != null) {
      dhikr.endDate = startDate.add(Duration(days: numberOfDays));
    }

    await _storage.saveDhikr(dhikr);
  }

  Future<void> updateDhikr(Dhikr dhikr) async {
    await _storage.saveDhikr(dhikr);
  }
}
