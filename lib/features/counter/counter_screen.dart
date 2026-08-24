import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import 'package:volume_controller/volume_controller.dart';
import '../../core/localization/l10n_extension.dart';
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
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

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
    final progress = ref.read(progressByIdProvider(widget.dhikrId));
    final isCompleted = progress?.isCompleted ?? false;
    if (dhikr != null && !isCompleted) {
      ref.read(counterStateProvider.notifier).increment(widget.dhikrId);
    }
  }

  void _showResetDialog() {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetProgressTitle),
        content: Text(l10n.resetProgressMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              ref.read(counterStateProvider.notifier).reset(widget.dhikrId);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.reset),
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
    final progress = ref.watch(progressByIdProvider(widget.dhikrId));
    final counterState = ref.watch(counterStateProvider);
    final l10n = context.l10n;

    if (dhikr == null) {
      return Scaffold(body: Center(child: Text(l10n.noCustomWazifas)));
    }

    final targetCount = dhikr.totalTargetCount;
    final isCompleted = progress?.isCompleted ?? false;
    final repeatEnabled = progress?.repeatEnabled ?? false;

    // Trigger confetti on completion
    if (counterState.showCompletionAnimation &&
        !_confettiController.state.name.contains('playing')) {
      _confettiController.play();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(dhikr.name),
        actions: [
          if (repeatEnabled)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${l10n.round} ${counterState.roundCount}',
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            kToolbarHeight -
                            240,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Arabic text
                          if (dhikr.arabicText != null) ...[
                            Text(
                              dhikr.arabicText!,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                            ),
                            const SizedBox(height: 6),
                          ],

                          // Transliteration
                          if (dhikr.transliteration != null)
                            Text(
                              dhikr.transliteration!,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                              textAlign: TextAlign.center,
                            ),

                          const SizedBox(height: 24),

                          // Circular Progress & Counter
                          CircularProgressWidget(
                            progress: targetCount > 0
                                ? counterState.displayCount / targetCount
                                : 0,
                            currentCount: counterState.displayCount,
                            targetCount: targetCount,
                            remainingCount:
                                targetCount - counterState.displayCount,
                          ),

                          const SizedBox(height: 24),

                          // Completion message
                          if (counterState.isCompleted && !repeatEnabled)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                l10n.mashaAllahCompleted,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom controls
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Count button
                      CountButton(
                        onTap: isCompleted && !repeatEnabled
                            ? null
                            : _handleCount,
                      ),
                      const SizedBox(height: 12),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _showResetDialog,
                              icon: const Icon(Icons.restart_alt, size: 18),
                              label: Text(l10n.reset),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _saveAndExit,
                              icon: const Icon(Icons.save, size: 18),
                              label: Text(l10n.saveAndExit),
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
