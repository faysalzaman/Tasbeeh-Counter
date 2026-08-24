import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/audio/audio_service.dart';
import '../core/haptics/haptics_service.dart';
import '../models/app_settings.dart';
import '../models/dhikr.dart';
import '../models/dhikr_progress.dart';
import '../repositories/dhikr_repository.dart';
import 'dhikr_provider.dart';
import 'settings_provider.dart';

final currentDhikrIdProvider = StateProvider<String?>((ref) => null);

final currentDhikrProvider = Provider<Dhikr?>((ref) {
  final id = ref.watch(currentDhikrIdProvider);
  if (id == null) return null;
  return ref.watch(dhikrByIdProvider(id));
});

final counterStateProvider =
    StateNotifierProvider<CounterNotifier, CounterState>((ref) {
  final dhikrRepo = ref.watch(dhikrRepositoryProvider);
  final settings = ref.watch(settingsProvider);
  final progressNotifier = ref.watch(progressListNotifierProvider.notifier);
  return CounterNotifier(dhikrRepo, settings, progressNotifier);
});

class CounterState {
  final bool isCompleted;
  final bool showCompletionAnimation;
  final int displayCount;
  final int roundCount;

  const CounterState({
    this.isCompleted = false,
    this.showCompletionAnimation = false,
    this.displayCount = 0,
    this.roundCount = 1,
  });

  CounterState copyWith({
    bool? isCompleted,
    bool? showCompletionAnimation,
    int? displayCount,
    int? roundCount,
  }) {
    return CounterState(
      isCompleted: isCompleted ?? this.isCompleted,
      showCompletionAnimation:
          showCompletionAnimation ?? this.showCompletionAnimation,
      displayCount: displayCount ?? this.displayCount,
      roundCount: roundCount ?? this.roundCount,
    );
  }
}

class CounterNotifier extends StateNotifier<CounterState> {
  final DhikrRepository _repository;
  final AppSettings _settings;
  final ProgressListNotifier _progressNotifier;
  final AudioService _audio = AudioService();
  final HapticsService _haptics = HapticsService();

  CounterNotifier(this._repository, this._settings, this._progressNotifier)
      : super(const CounterState());

  void setDhikr(Dhikr dhikr) {
    final progress = _repository.getProgress(dhikr.id);
    state = CounterState(
      displayCount: progress?.currentCount ?? 0,
      roundCount: progress?.roundCount ?? 1,
      isCompleted: progress?.isCompleted ?? false,
    );
  }

  Future<void> increment(String dhikrId) async {
    final dhikr = _repository.getDhikr(dhikrId);
    if (dhikr == null) return;

    var progress = _repository.getProgress(dhikrId);
    progress ??= DhikrProgress(id: dhikrId);
    if (progress.isCompleted && !progress.repeatEnabled) return;

    final target = dhikr.totalTargetCount;
    final newCount = progress.currentCount + 1;
    final isTargetReached = target > 0 && newCount >= target;

    // Update state immediately for smooth UI
    state = state.copyWith(displayCount: newCount);

    // Haptic feedback
    if (_settings.countingVibration) {
      await _haptics.lightImpact();
    }

    // Sound feedback
    if (_settings.countingSound) {
      await _audio.playCountSound();
    }

    // Persist to storage
    await _repository.incrementCount(dhikrId);
    _progressNotifier.refresh();

    if (isTargetReached) {
      await _handleCompletion(dhikrId, target);
    }
  }

  Future<void> _handleCompletion(String dhikrId, int target) async {
    final dhikr = _repository.getDhikr(dhikrId);
    if (dhikr == null) return;
    final progress = _repository.getProgress(dhikrId);
    if (progress == null) return;

    // Show completion animation
    state = state.copyWith(isCompleted: true, showCompletionAnimation: true);

    // Completion haptics
    if (_settings.completionVibration) {
      await _haptics.completionFeedback();
    }

    // Completion sound
    if (_settings.completionSound) {
      await _audio.playCompletionSound();
    }

    // Complete dhikr / start next round
    await _repository.completeDhikr(dhikrId, target);
    _progressNotifier.refresh();

    // If repeat mode, reset after animation
    if (progress.repeatEnabled) {
      await Future.delayed(const Duration(seconds: 2));
      final updatedDhikr = _repository.getDhikr(dhikrId);
      if (updatedDhikr != null) {
        final updated = _repository.getProgress(dhikrId);
        if (updated != null) {
          state = CounterState(
            displayCount: updated.currentCount,
            roundCount: updated.roundCount,
            isCompleted: false,
            showCompletionAnimation: false,
          );
        }
      }
    }
  }

  Future<void> reset(String dhikrId) async {
    await _repository.resetCount(dhikrId);
    _progressNotifier.refresh();

    final progress = _repository.getProgress(dhikrId);
    state = CounterState(
      displayCount: progress?.currentCount ?? 0,
      roundCount: progress?.roundCount ?? 1,
    );
  }

  Future<void> saveAndExit(String dhikrId) async {
    final progress = _repository.getProgress(dhikrId);
    if (progress != null) {
      final updated = progress.copyWith(lastSessionDate: DateTime.now());
      await _repository.saveProgress(updated);
      _progressNotifier.refresh();
    }
  }

  void dismissCompletionAnimation() {
    state = state.copyWith(showCompletionAnimation: false);
  }
}
