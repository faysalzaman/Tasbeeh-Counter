import 'dart:async';

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

  bool _isCompleting = false;

  CounterNotifier(this._repository, this._settings, this._progressNotifier)
      : super(const CounterState());

  void setDhikr(Dhikr dhikr) {
    _isCompleting = false;
    final progress = _repository.getProgress(dhikr.id);
    final target = dhikr.totalTargetCount;
    final rawCount = progress?.currentCount ?? 0;
    final clampedCount = target > 0 ? rawCount.clamp(0, target) : rawCount;
    final isCompleted = (progress?.isCompleted ?? false) ||
        (target > 0 &&
            clampedCount >= target &&
            !(progress?.repeatEnabled ?? false));

    state = CounterState(
      displayCount: clampedCount,
      roundCount: progress?.roundCount ?? 1,
      isCompleted: isCompleted,
    );
  }

  Future<void> increment(String dhikrId) async {
    final dhikr = _repository.getDhikr(dhikrId);
    if (dhikr == null) return;

    if (_isCompleting) return;

    var progress = _repository.getProgress(dhikrId);
    progress ??= DhikrProgress(id: dhikrId);

    final repeatEnabled = progress.repeatEnabled;
    final isAlreadyCompleted = progress.isCompleted || state.isCompleted;

    if (isAlreadyCompleted && !repeatEnabled) return;

    final target = dhikr.totalTargetCount;
    if (target > 0 && state.displayCount >= target) return;

    final newCount = state.displayCount + 1;
    final isTargetReached = target > 0 && newCount >= target;

    if (isTargetReached) {
      _isCompleting = true;
      state = state.copyWith(
        displayCount: target,
        isCompleted: true,
        showCompletionAnimation: true,
      );
    } else {
      state = state.copyWith(displayCount: newCount);
    }

    // Haptic feedback
    if (_settings.countingVibration) {
      if (isTargetReached && _settings.completionVibration) {
        // Completion haptics handled in _handleCompletion
      } else {
        unawaited(_haptics.lightImpact());
      }
    }

    // Sound feedback
    if (_settings.countingSound) {
      if (isTargetReached && _settings.completionSound) {
        // Completion sound handled in _handleCompletion
      } else {
        unawaited(_audio.playCountSound());
      }
    }

    // Persist to storage
    await _repository.updateCount(dhikrId, isTargetReached ? target : newCount);
    _progressNotifier.refresh();

    if (isTargetReached) {
      await _handleCompletion(dhikrId, target);
    }
  }

  Future<void> _handleCompletion(String dhikrId, int target) async {
    final dhikr = _repository.getDhikr(dhikrId);
    if (dhikr == null) {
      _isCompleting = false;
      return;
    }
    final progress = _repository.getProgress(dhikrId);
    if (progress == null) {
      _isCompleting = false;
      return;
    }

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
      if (updatedDhikr != null && _isCompleting) {
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
    _isCompleting = false;
  }

  Future<void> reset(String dhikrId) async {
    _isCompleting = false;
    await _repository.resetCount(dhikrId);
    _progressNotifier.refresh();

    final progress = _repository.getProgress(dhikrId);
    state = CounterState(
      displayCount: progress?.currentCount ?? 0,
      roundCount: progress?.roundCount ?? 1,
      isCompleted: false,
      showCompletionAnimation: false,
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
