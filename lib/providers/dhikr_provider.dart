import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/local_storage.dart';
import '../models/dhikr.dart';
import '../models/dhikr_progress.dart';
import '../repositories/dhikr_repository.dart';

final dhikrRepositoryProvider = Provider<DhikrRepository>((ref) {
  return DhikrRepository(LocalStorage.instance);
});

// --- Content ---

final dhikrListNotifierProvider =
    StateNotifierProvider<DhikrListNotifier, List<Dhikr>>((ref) {
  return DhikrListNotifier(ref.watch(dhikrRepositoryProvider));
});

final allDhikrsProvider = Provider<List<Dhikr>>((ref) {
  return ref.watch(dhikrListNotifierProvider);
});

final defaultDhikrsProvider = Provider<List<Dhikr>>((ref) {
  final all = ref.watch(dhikrListNotifierProvider);
  return all.where((d) => d.isDefault).toList();
});

final customDhikrsProvider = Provider<List<Dhikr>>((ref) {
  final all = ref.watch(dhikrListNotifierProvider);
  return all.where((d) => d.isCustom).toList();
});

final dhikrByIdProvider = Provider.family<Dhikr?, String>((ref, id) {
  final all = ref.watch(dhikrListNotifierProvider);
  for (final d in all) {
    if (d.id == id) return d;
  }
  return null;
});

// --- Progress ---

final progressListNotifierProvider =
    StateNotifierProvider<ProgressListNotifier, Map<String, DhikrProgress>>(
        (ref) {
  return ProgressListNotifier(ref.watch(dhikrRepositoryProvider));
});

final progressByIdProvider =
    Provider.family<DhikrProgress?, String>((ref, id) {
  return ref.watch(progressListNotifierProvider)[id];
});

// --- Joined views ---

final activeDhikrsProvider = Provider<List<Dhikr>>((ref) {
  final all = ref.watch(dhikrListNotifierProvider);
  final progress = ref.watch(progressListNotifierProvider);
  return all.where((d) {
    final p = progress[d.id];
    if (p == null) return false;
    return p.currentCount > 0 && p.currentCount < d.totalTargetCount;
  }).toList();
});

final suggestedDhikrsProvider = Provider<List<Dhikr>>((ref) {
  final defaults = ref.watch(defaultDhikrsProvider);
  final list = [...defaults];
  list.sort((a, b) {
    final aRelevant = isDhikrCategoryRelevantNow(a.category);
    final bRelevant = isDhikrCategoryRelevantNow(b.category);
    if (aRelevant && !bRelevant) return -1;
    if (!aRelevant && bRelevant) return 1;
    return 0;
  });
  return list;
});

/// A curated subset of short, important single-phrase dhikrs for the
/// "Quick Dhikr" screen. Collections and longer duas are excluded so only
/// quick-to-recite phrases are shown.
final quickDhikrsProvider = Provider<List<Dhikr>>((ref) {
  final defaults = ref.watch(defaultDhikrsProvider);
  final list = defaults.where((d) => d.type == DhikrType.single).toList();
  list.sort((a, b) {
    final aRelevant = isDhikrCategoryRelevantNow(a.category);
    final bRelevant = isDhikrCategoryRelevantNow(b.category);
    if (aRelevant && !bRelevant) return -1;
    if (!aRelevant && bRelevant) return 1;
    return 0;
  });
  return list;
});

final relevantNowDhikrsProvider = Provider<List<Dhikr>>((ref) {
  return ref
      .watch(defaultDhikrsProvider)
      .where((d) => isDhikrCategoryRelevantNow(d.category))
      .toList();
});

final relevantNowQuickDhikrsProvider = Provider<List<Dhikr>>((ref) {
  return ref
      .watch(quickDhikrsProvider)
      .where((d) => isDhikrCategoryRelevantNow(d.category))
      .toList();
});

// --- Notifiers ---

class DhikrListNotifier extends StateNotifier<List<Dhikr>> {
  final DhikrRepository _repository;

  DhikrListNotifier(this._repository) : super(_repository.getAllDhikrs());

  void refresh() {
    state = _repository.getAllDhikrs();
  }

  Future<void> saveDhikr(Dhikr dhikr) async {
    await _repository.saveDhikr(dhikr);
    refresh();
  }

  Future<void> deleteDhikr(String id) async {
    await _repository.deleteDhikr(id);
    refresh();
  }

  Future<Dhikr> createCustomDhikr({
    required String name,
    String? arabicTitle,
    String? translation,
    String? description,
    String? arabicText,
    String? transliteration,
    required int targetCount,
    bool repeatEnabled = false,
    bool reminderEnabled = false,
    String? reminderTime,
    DateTime? startDate,
    int? numberOfDays,
    String? notes,
    String? schedule,
  }) async {
    final dhikr = await _repository.createCustomDhikr(
      name: name,
      arabicTitle: arabicTitle,
      translation: translation,
      description: description,
      arabicText: arabicText,
      transliteration: transliteration,
      targetCount: targetCount,
      repeatEnabled: repeatEnabled,
      reminderEnabled: reminderEnabled,
      reminderTime: reminderTime,
      startDate: startDate,
      numberOfDays: numberOfDays,
      notes: notes,
      schedule: schedule,
    );
    refresh();
    return dhikr;
  }
}

class ProgressListNotifier extends StateNotifier<Map<String, DhikrProgress>> {
  final DhikrRepository _repository;

  ProgressListNotifier(this._repository) : super(_repository.getAllProgress());

  void refresh() {
    state = _repository.getAllProgress();
  }
}
