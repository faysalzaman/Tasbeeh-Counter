import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/local_storage.dart';
import '../models/dhikr.dart';
import '../models/dhikr_schedule.dart';
import '../repositories/dhikr_repository.dart';

final dhikrRepositoryProvider = Provider<DhikrRepository>((ref) {
  return DhikrRepository(LocalStorage.instance);
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
  return all.where((d) => !d.isDefault).toList();
});

final activeDhikrsProvider = Provider<List<Dhikr>>((ref) {
  final all = ref.watch(dhikrListNotifierProvider);
  return all
      .where((d) => d.currentCount > 0 && d.currentCount < d.targetCount)
      .toList();
});

final dhikrByIdProvider = Provider.family<Dhikr?, String>((ref, id) {
  final all = ref.watch(dhikrListNotifierProvider);
  try {
    return all.firstWhere((d) => d.id == id);
  } catch (e) {
    return null;
  }
});

final suggestedDhikrsProvider = Provider<List<Dhikr>>((ref) {
  final all = ref.watch(dhikrListNotifierProvider);
  final activeSchedules = ScheduleHelper.activeSchedulesNow;

  final defaults = all.where((d) => d.isDefault).toList();

  // Sort: relevant schedules first, then daily, then others
  defaults.sort((a, b) {
    final aSchedule = a.scheduleEnum;
    final bSchedule = b.scheduleEnum;

    final aRelevant = aSchedule == null || activeSchedules.contains(aSchedule);
    final bRelevant = bSchedule == null || activeSchedules.contains(bSchedule);

    if (aRelevant && !bRelevant) return -1;
    if (!aRelevant && bRelevant) return 1;

    // Both relevant: daily first, then specific schedules
    if (aSchedule == DhikrSchedule.daily && bSchedule != DhikrSchedule.daily) {
      return -1;
    }
    if (aSchedule != DhikrSchedule.daily && bSchedule == DhikrSchedule.daily) {
      return 1;
    }

    return 0;
  });

  return defaults;
});

final dhikrListNotifierProvider =
    StateNotifierProvider<DhikrListNotifier, List<Dhikr>>((ref) {
      final repository = ref.watch(dhikrRepositoryProvider);
      return DhikrListNotifier(repository);
    });

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
    String? schedule,
  }) async {
    await _repository.createCustomDhikr(
      name: name,
      arabicText: arabicText,
      transliteration: transliteration,
      translation: translation,
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
  }
}
