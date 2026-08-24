import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import 'package:volume_controller/volume_controller.dart';
import '../../core/audio/audio_service.dart';
import '../../core/haptics/haptics_service.dart';
import '../../models/dhikr.dart';
import '../../providers/counter_provider.dart';
import '../../providers/dhikr_provider.dart';
import '../../providers/settings_provider.dart';
import 'widgets/circular_progress.dart';
import 'widgets/count_button.dart';

class CounterScreen extends ConsumerStatefulWidget {
  final String dhikrId;

  const CounterScreen({super.key, required this.dhikrId});

  @override
  ConsumerState<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends ConsumerState<CounterScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  StreamSubscription<double>? _volumeSubscription;
  double _currentVolume = 0.5;
  bool _isVolumeKeyPressed = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDhikr();
      _setupVolumeKeys();
    });
  }

  void _initializeDhikr() {
    final dhikr = ref.read(dhikrByIdProvider(widget.dhikrId));
    if (dhikr != null) {
      ref.read(currentDhikrIdProvider.notifier).state = widget.dhikrId;
      ref.read(counterStateProvider.notifier).setDhikr(dhikr);
    }
  }

  void _setupVolumeKeys() {
    final settings = ref.read(settingsProvider);
    if (!settings.volumeKeyCounting) return;

    _volumeSubscription = VolumeController.instance.addListener((volume) {
      if (!mounted) return;

      if ((volume - _currentVolume).abs() > 0.01 && !_isVolumeKeyPressed) {
        _isVolumeKeyPressed = true;
        _handleCount();

        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) _isVolumeKeyPressed = false;
        });
      }
      _currentVolume = volume;
    });
  }

  void _handleCount() {
    final dhikr = ref.read(dhikrByIdProvider(widget.dhikrId));
    if (dhikr != null && !dhikr.isCompleted) {
      ref.read(counterStateProvider.notifier).increment(widget.dhikrId);
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text(
          'This will reset the current count to zero. The Dhikr configuration will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(counterStateProvider.notifier).reset(widget.dhikrId);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _saveAndExit() {
    ref.read(counterStateProvider.notifier).saveAndExit(widget.dhikrId);
    context.pop();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _volumeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dhikr = ref.watch(dhikrByIdProvider(widget.dhikrId));
    final counterState = ref.watch(counterStateProvider);
    final settings = ref.watch(settingsProvider);

    if (dhikr == null) {
      return const Scaffold(
        body: Center(child: Text('Dhikr not found')),
      );
    }

    // Trigger confetti on completion
    if (counterState.showCompletionAnimation && !_confettiController.state.name.contains('playing')) {
      _confettiController.play();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(dhikr.name),
        actions: [
          if (dhikr.repeatEnabled)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Round ${counterState.roundCount}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Arabic text
                        if (dhikr.arabicText != null) ...[
                          Text(
                            dhikr.arabicText!,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 8),
                        ],

                        // Transliteration
                        if (dhikr.transliteration != null)
                          Text(
                            dhikr.transliteration!,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                ),
                            textAlign: TextAlign.center,
                          ),

                        const SizedBox(height: 40),

                        // Circular Progress & Counter
                        CircularProgressWidget(
                          progress: dhikr.targetCount > 0
                              ? counterState.displayCount / dhikr.targetCount
                              : 0,
                          currentCount: counterState.displayCount,
                          targetCount: dhikr.targetCount,
                          remainingCount: dhikr.targetCount - counterState.displayCount,
                        ),

                        const SizedBox(height: 40),

                        // Completion message
                        if (counterState.isCompleted && !dhikr.repeatEnabled)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'MashaAllah! Completed',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Bottom controls
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Count button
                      CountButton(
                        onTap: dhikr.isCompleted && !dhikr.repeatEnabled
                            ? null
                            : _handleCount,
                      ),
                      const SizedBox(height: 20),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _showResetDialog,
                              icon: const Icon(Icons.restart_alt, size: 20),
                              label: const Text('Reset'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _saveAndExit,
                              icon: const Icon(Icons.save, size: 20),
                              label: const Text('Save & Exit'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
                Colors.green,
                Colors.amber,
              ],
              numberOfParticles: 30,
              gravity: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
