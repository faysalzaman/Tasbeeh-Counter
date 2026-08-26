import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/l10n_extension.dart';
import '../../core/volume/volume_key_service.dart';
import '../../providers/counter_provider.dart';
import '../../providers/dhikr_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/custom_scaffold.dart';
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
  late final ConfettiController _confettiController;
  StreamSubscription<String>? _volumeSubscription;
  bool _isVolumeKeyPressed = false;
  final FocusNode _focusNode = FocusNode();

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

  Future<void> _setupVolumeKeys() async {
    final settings = ref.read(settingsProvider);
    if (!settings.volumeKeyCounting) return;

    final supported = await VolumeKeyService.instance.enable();
    if (!supported || !mounted) return;

    _volumeSubscription = VolumeKeyService.instance.events?.listen((_) {
      if (!mounted || _isVolumeKeyPressed) return;
      _isVolumeKeyPressed = true;
      _handleCount();
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _isVolumeKeyPressed = false;
      });
    });
  }

  void _handleCount() {
    final dhikr = ref.read(dhikrByIdProvider(widget.dhikrId));
    final progress = ref.read(progressByIdProvider(widget.dhikrId));
    final isCompleted = progress?.isCompleted ?? false;
    final repeatEnabled = progress?.repeatEnabled ?? false;

    if (dhikr != null && (!isCompleted || repeatEnabled)) {
      ref.read(counterStateProvider.notifier).increment(widget.dhikrId);
    }
  }

  void _showResetDialog() {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.resetProgressTitle),
        content: Text(l10n.resetProgressMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              ref.read(counterStateProvider.notifier).reset(widget.dhikrId);
              Navigator.pop(dialogContext);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
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
    _focusNode.dispose();
    _confettiController.dispose();
    _volumeSubscription?.cancel();
    VolumeKeyService.instance.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dhikr = ref.watch(dhikrByIdProvider(widget.dhikrId));
    final progress = ref.watch(progressByIdProvider(widget.dhikrId));
    final counterState = ref.watch(counterStateProvider);
    final l10n = context.l10n;

    // Reactively trigger confetti animation using ref.listen
    ref.listen(counterStateProvider.select((s) => s.showCompletionAnimation), (
      previous,
      next,
    ) {
      if (next &&
          _confettiController.state != ConfettiControllerState.playing) {
        _confettiController.play();
      }
    });

    if (dhikr == null) {
      return Scaffold(body: Center(child: Text(l10n.noCustomWazifas)));
    }

    final targetCount = dhikr.totalTargetCount;
    final isCompleted = progress?.isCompleted ?? false;
    final repeatEnabled = progress?.repeatEnabled ?? false;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        // Fallback/Web physical key support for space or volume keys
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.space ||
                event.logicalKey == LogicalKeyboardKey.audioVolumeUp ||
                event.logicalKey == LogicalKeyboardKey.audioVolumeDown)) {
          _handleCount();
        }
      },
      child: CustomScaffold(
        title: dhikr.name,
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
                    ).colorScheme.secondary.withValues(alpha: 0.15),
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
        body: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    // Text header area
                    if (dhikr.arabicText != null) ...[
                      Text(
                        dhikr.arabicText!,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (dhikr.transliteration != null)
                      Text(
                        dhikr.transliteration!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    // Centered Circular Progress takes available screen space
                    Expanded(
                      child: Center(
                        child: CircularProgressWidget(
                          progress: targetCount > 0
                              ? counterState.displayCount / targetCount
                              : 0,
                          currentCount: counterState.displayCount,
                          targetCount: targetCount,
                          remainingCount:
                              targetCount - counterState.displayCount,
                        ),
                      ),
                    ),

                    // Completion Text Badge
                    if (counterState.isCompleted && !repeatEnabled)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n.mashaAllahCompleted,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),

                    // Fixed Bottom Controls
                    CountButton(
                      onTap: isCompleted && !repeatEnabled
                          ? null
                          : _handleCount,
                    ),
                    const SizedBox(height: 12),
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
            ),
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
      ),
    );
  }
}
