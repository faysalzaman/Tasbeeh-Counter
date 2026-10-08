import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/audio/audio_service.dart';
import '../core/haptics/haptics_service.dart';
import '../models/app_settings.dart';
import '../models/dhikr.dart';
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
  Future<void> _pendingWrite = Future.value();
  String? _dhikrId;
  int _session = 0;

  Future<void> _writeInOrder(Future<void> Function() action) {
    final write = _pendingWrite.then((_) => action());
    // A failed write must not prevent subsequent resets or saves.
    _pendingWrite = write.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return write;
  }

  bool _isCurrent(int session, String id) =>
      mounted && _session == session && _dhikrId == id;

  CounterNotifier(this._repository, this._settings, this._progressNotifier)
    : super(const CounterState());

  void setDhikr(Dhikr dhikr) {
    _dhikrId = dhikr.id;
    _session++;
    final progress = _repository.getProgress(dhikr.id);
    final target = dhikr.totalTargetCount;
    final count = progress?.currentCount ?? 0;
    final reached = target > 0 && count >= target;
    final repeat = progress?.repeatEnabled ?? false;
    final displayCount = reached ? (repeat ? 0 : target) : count;
    final roundCount =
        (progress?.roundCount ?? 1) + (reached && repeat ? 1 : 0);
    final completed = reached ? !repeat : (progress?.isCompleted ?? false);
    state = CounterState(
      displayCount: displayCount,
      roundCount: roundCount,
      isCompleted: completed,
    );

    // Repair counts left above the target by the old asynchronous flow, or
    // by editing a wazifa to have a smaller target.
    if (progress != null &&
        (count != displayCount || progress.isCompleted != completed)) {
      unawaited(
        _writeInOrder(() async {
          await _repository.saveProgress(
            progress.copyWith(
              currentCount: displayCount,
              roundCount: roundCount,
              isCompleted: completed,
            ),
          );
          if (mounted) _progressNotifier.refresh();
        }),
      );
    }
  }

  Future<void> increment(String dhikrId) async {
    if (_dhikrId != dhikrId || state.isCompleted) return;
    final dhikr = _repository.getDhikr(dhikrId);
    if (dhikr == null) return;

    final target = dhikr.totalTargetCount;
    if (target > 0 && state.displayCount >= target) return;
    final session = _session;
    final newCount = state.displayCount + 1;
    final isTargetReached = target > 0 && newCount == target;

    // Reserve this press before any await. All input sources see the same
    // count and completion guard, even while feedback or storage is pending.
    state = state.copyWith(
      displayCount: newCount,
      isCompleted: isTargetReached,
      showCompletionAnimation: isTargetReached,
    );

    await _writeInOrder(() async {
      await _repository.incrementCount(dhikrId);
      if (isTargetReached) {
        await _repository.completeDhikr(dhikrId, target);
      }
      if (mounted) _progressNotifier.refresh();
    });
    if (!_isCurrent(session, dhikrId)) return;

    if (_settings.countingVibration) await _haptics.lightImpact();
    if (_settings.countingSound) await _audio.playCountSound();
    if (!isTargetReached || !_isCurrent(session, dhikrId)) return;

    if (_settings.completionVibration) await _haptics.completionFeedback();
    if (_settings.completionSound) await _audio.playCompletionSound();
    if (!_isCurrent(session, dhikrId)) return;

    final progress = _repository.getProgress(dhikrId);
    if (progress?.repeatEnabled ?? false) {
      await Future.delayed(const Duration(seconds: 2));
      // Resetting or changing dhikr invalidates an earlier round's timer.
      if (!_isCurrent(session, dhikrId)) return;
      final updated = _repository.getProgress(dhikrId);
      if (updated != null) {
        state = CounterState(
          displayCount: updated.currentCount,
          roundCount: updated.roundCount,
        );
      }
    }
  }

  Future<void> reset(String dhikrId) async {
    if (_dhikrId != dhikrId) return;
    _session++;
    state = const CounterState();
    await _writeInOrder(() async {
      await _repository.resetCount(dhikrId);
      if (mounted) _progressNotifier.refresh();
    });
  }

  Future<void> saveAndExit(String dhikrId) async {
    await _writeInOrder(() async {
      final progress = _repository.getProgress(dhikrId);
      if (progress != null) {
        await _repository.saveProgress(
          progress.copyWith(lastSessionDate: DateTime.now()),
        );
        if (mounted) _progressNotifier.refresh();
      }
    });
  }

  void dismissCompletionAnimation() {
    state = state.copyWith(showCompletionAnimation: false);
  }
}
