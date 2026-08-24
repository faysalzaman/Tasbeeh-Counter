import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/audio/audio_service.dart';
import '../core/haptics/haptics_service.dart';
import '../models/dhikr.dart';
import '../models/app_settings.dart';
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
      final dhikrListNotifier = ref.watch(dhikrListNotifierProvider.notifier);
      return CounterNotifier(dhikrRepo, settings, dhikrListNotifier);
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
  final dynamic _repository;
  final AppSettings _settings;
  final dynamic _listNotifier;
  final AudioService _audio = AudioService();
  final HapticsService _haptics = HapticsService();

  CounterNotifier(this._repository, this._settings, this._listNotifier)
    : super(const CounterState());

  void setDhikr(Dhikr dhikr) {
    state = CounterState(
      displayCount: dhikr.currentCount,
      roundCount: dhikr.roundCount,
      isCompleted: dhikr.isCompleted,
    );
  }

  Future<void> increment(String dhikrId) async {
    final dhikr = _repository.getDhikr(dhikrId);
    if (dhikr == null) return;
    if (dhikr.isCompleted && !dhikr.repeatEnabled) return;

    final newCount = dhikr.currentCount + 1;
    final isTargetReached = newCount >= dhikr.targetCount;

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
    _listNotifier.refresh();

    if (isTargetReached) {
      await _handleCompletion(dhikrId);
    }
  }

  Future<void> _handleCompletion(String dhikrId) async {
    final dhikr = _repository.getDhikr(dhikrId);
    if (dhikr == null) return;

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
    await _repository.completeDhikr(dhikrId);
    _listNotifier.refresh();

    // If repeat mode, reset after animation
    if (dhikr.repeatEnabled) {
      await Future.delayed(const Duration(seconds: 2));
      final updatedDhikr = _repository.getDhikr(dhikrId);
      if (updatedDhikr != null) {
        state = CounterState(
          displayCount: updatedDhikr.currentCount,
          roundCount: updatedDhikr.roundCount,
          isCompleted: false,
          showCompletionAnimation: false,
        );
      }
    }
  }

  Future<void> reset(String dhikrId) async {
    await _repository.resetCount(dhikrId);
    _listNotifier.refresh();

    final dhikr = _repository.getDhikr(dhikrId);
    if (dhikr != null) {
      state = CounterState(
        displayCount: dhikr.currentCount,
        roundCount: dhikr.roundCount,
      );
    }
  }

  Future<void> saveAndExit(String dhikrId) async {
    final dhikr = _repository.getDhikr(dhikrId);
    if (dhikr != null) {
      final updated = dhikr.copyWith(lastSessionDate: DateTime.now());
      await _repository.saveDhikr(updated);
      _listNotifier.refresh();
    }
  }

  void dismissCompletionAnimation() {
    state = state.copyWith(showCompletionAnimation: false);
  }
}
