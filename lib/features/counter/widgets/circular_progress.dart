import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/localization/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';

class CircularProgressWidget extends StatefulWidget {
  final double progress;
  final int currentCount;
  final int targetCount;
  final int remainingCount;
  final bool isCompleted;
  final bool showCompletionAnimation;
  final VoidCallback? onTap;

  const CircularProgressWidget({
    super.key,
    required this.progress,
    required this.currentCount,
    required this.targetCount,
    required this.remainingCount,
    this.isCompleted = false,
    this.showCompletionAnimation = false,
    this.onTap,
  });

  @override
  State<CircularProgressWidget> createState() => _CircularProgressWidgetState();
}

class _CircularProgressWidgetState extends State<CircularProgressWidget>
    with TickerProviderStateMixin {
  late final AnimationController _waveController;
  late final AnimationController _heightController;
  late final AnimationController _perturbationController;
  late final AnimationController _completionController;

  late Animation<double> _heightAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    final clampedProgress = widget.progress.clamp(0.0, 1.0);

    // Continuous wave motion loop
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // Smooth liquid level rising animation
    _heightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _heightAnimation = Tween<double>(
      begin: clampedProgress,
      end: clampedProgress,
    ).animate(CurvedAnimation(
      parent: _heightController,
      curve: Curves.easeOutCubic,
    ));

    // Transient wave perturbation / ripple splash on tap
    _perturbationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    // Completion flow & outward ripple waves loop
    _completionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    if (widget.isCompleted || widget.showCompletionAnimation) {
      _completionController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant CircularProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newClamped = widget.progress.clamp(0.0, 1.0);

    // If progress changes, smoothly animate water level
    if (oldWidget.progress != widget.progress) {
      _heightAnimation = Tween<double>(
        begin: _heightAnimation.value,
        end: newClamped,
      ).animate(CurvedAnimation(
        parent: _heightController,
        curve: Curves.easeOutCubic,
      ));
      _heightController.forward(from: 0.0);
    }

    // If count increases, trigger ripple agitation
    if (widget.currentCount > oldWidget.currentCount) {
      _perturbationController.forward(from: 0.0);
    }

    // Completion animation management
    if (widget.isCompleted && !oldWidget.isCompleted) {
      _completionController.repeat();
    } else if (!widget.isCompleted && oldWidget.isCompleted) {
      _completionController.stop();
      _completionController.reset();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _heightController.dispose();
    _perturbationController.dispose();
    _completionController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    widget.onTap!();
  }

  void _handleTapCancel() {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;
    final themeExtension = theme.extension<DhikrThemeExtension>();
    final trackColor = themeExtension?.progressTrackColor ??
        (isDark ? AppColors.progressBackgroundDark : AppColors.progressBackgroundLight);

    final clampedProgress = widget.progress.clamp(0.0, 1.0);
    final percentInt = (clampedProgress * 100).toInt();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsively adapt diameter while leaving room for outer ripple waves
        final maxAvailable = math.min(constraints.maxWidth, constraints.maxHeight);
        final baseDiameter = (maxAvailable - 32).clamp(190.0, 260.0);
        // Canvas size accommodates outer ripple waves expanding up to 18dp outwards
        final canvasSize = baseDiameter + 36.0;

        return AnimatedScale(
          scale: _isPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: canvasSize,
              height: canvasSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Animated water wave canvas
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _waveController,
                      _heightController,
                      _perturbationController,
                      _completionController,
                    ]),
                    builder: (context, _) {
                      return CustomPaint(
                        size: Size(canvasSize, canvasSize),
                        painter: _WaterWavePainter(
                          progress: _heightAnimation.value,
                          wavePhase: _waveController.value * 2 * math.pi,
                          perturbation: 1.0 - _perturbationController.value,
                          completionProgress: _completionController.value,
                          isCompleted: widget.isCompleted,
                          primaryColor: theme.colorScheme.primary,
                          secondaryColor: theme.colorScheme.secondary,
                          trackColor: trackColor,
                          isDark: isDark,
                        ),
                      );
                    },
                  ),

                  // Center information overlay
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Percentage Chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: (widget.isCompleted
                                    ? AppColors.secondaryLight
                                    : (isDark ? Colors.black : Colors.white))
                                .withValues(alpha: isDark ? 0.45 : 0.70),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: (widget.isCompleted
                                      ? AppColors.secondaryLight
                                      : theme.colorScheme.primary)
                                  .withValues(alpha: 0.35),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            '$percentInt%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: widget.isCompleted
                                  ? (isDark ? AppColors.secondaryDark : const Color(0xFF8C621E))
                                  : (isDark ? Colors.white : theme.colorScheme.primary),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Current Count with AnimatedSwitcher
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 160),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: Text(
                            '${widget.currentCount}',
                            key: ValueKey<int>(widget.currentCount),
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: baseDiameter > 220 ? 58 : 46,
                              height: 1.05,
                              color: isDark ? Colors.white : theme.colorScheme.onSurface,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                                if (!isDark)
                                  Shadow(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    blurRadius: 8,
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // Target Count
                        Text(
                          widget.targetCount > 0 ? '/ ${widget.targetCount}' : '∞',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: baseDiameter > 220 ? 16 : 14,
                            fontWeight: FontWeight.w600,
                            color: (isDark ? Colors.white : theme.colorScheme.onSurface)
                                .withValues(alpha: 0.72),
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Status Badge: Completed or Remaining Count
                        if (widget.isCompleted)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Iconsax.tick_circle,
                                size: 16,
                                color: isDark
                                    ? AppColors.secondaryDark
                                    : const Color(0xFF8C621E),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.completed,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark
                                      ? AppColors.secondaryDark
                                      : const Color(0xFF8C621E),
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.35),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            widget.targetCount > 0
                                ? '${widget.remainingCount} ${l10n.remaining}'
                                : '${widget.currentCount} ${l10n.completed}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: baseDiameter > 220 ? 13 : 11,
                              color: (isDark ? Colors.white : theme.colorScheme.onSurface)
                                  .withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WaterWavePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0 (smooth height)
  final double wavePhase; // 0 to 2*pi
  final double perturbation; // 0.0 to 1.0 (decays to 0)
  final double completionProgress; // 0.0 to 1.0
  final bool isCompleted;
  final Color primaryColor;
  final Color secondaryColor;
  final Color trackColor;
  final bool isDark;

  _WaterWavePainter({
    required this.progress,
    required this.wavePhase,
    required this.perturbation,
    required this.completionProgress,
    required this.isCompleted,
    required this.primaryColor,
    required this.secondaryColor,
    required this.trackColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Radius of circular body (leaving outer margin for celebration ripple rings)
    final radius = (size.width - 36.0) / 2;

    // 1. OUTWARD RIPPLE WAVES (Celebration / Flow effect upon completion)
    if (isCompleted) {
      for (int i = 0; i < 2; i++) {
        final ringProgress = (completionProgress + (i * 0.5)) % 1.0;
        final ringRadius = radius + (ringProgress * 17.0);
        final ringAlpha = (1.0 - ringProgress).clamp(0.0, 1.0) * 0.55;
        final ringPaint = Paint()
          ..color = (isDark ? AppColors.secondaryDark : AppColors.secondaryLight)
              .withValues(alpha: ringAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4 * (1.0 - ringProgress * 0.45);
        canvas.drawCircle(center, ringRadius, ringPaint);
      }
    }

    // 2. AMBIENT DROP SHADOW
    final shadowPaint = Paint()
      ..color = isDark
          ? Colors.black.withValues(alpha: 0.50)
          : primaryColor.withValues(alpha: 0.14)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(center, radius, shadowPaint);

    // 3. BASE BACKGROUND DISC
    final basePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          isDark ? const Color(0xFF142732) : const Color(0xFFFFFFFF),
          isDark ? const Color(0xFF0C1920) : const Color(0xFFEFF5F8),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, basePaint);

    // 4. CLIP INSIDE CIRCLE FOR WATER
    canvas.save();
    final clipPath = Path()..addOval(Rect.fromCircle(center: center, radius: radius - 1.5));
    canvas.clipPath(clipPath);

    // Effective liquid height calculation
    final effectiveProgress = progress.clamp(0.0, 1.0);
    final waterY = center.dy + radius - (effectiveProgress * 2 * radius);

    // Wave amplitude dampening near 0% and 100%
    final damp = math.sin(effectiveProgress * math.pi).clamp(0.0, 1.0);
    final extraAmp = perturbation * 6.0;
    final baseAmp = 5.5 + extraAmp;
    final amp = baseAmp * math.max(damp, isCompleted ? 0.35 : 0.05);

    if (effectiveProgress > 0.001) {
      final waveWidth = radius * 2 + 10;
      final startX = center.dx - radius - 5;
      final endX = center.dx + radius + 5;
      final bottomY = center.dy + radius + 10;

      // 4A. BACK WAVE (Layer 1 - Offset phase & lower opacity)
      final backPath = Path()..moveTo(startX, bottomY);
      for (double x = startX; x <= endX; x += 4.0) {
        final relX = (x - startX) / waveWidth;
        final y = waterY +
            (amp * 0.75) *
                math.sin((relX * 2 * math.pi * 1.25) + wavePhase + 1.2);
        backPath.lineTo(x, y);
      }
      backPath.lineTo(endX, bottomY);
      backPath.close();

      final backWavePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isCompleted
              ? [
                  AppColors.secondaryLight.withValues(alpha: 0.45),
                  AppColors.secondaryDark.withValues(alpha: 0.25),
                ]
              : [
                  primaryColor.withValues(alpha: 0.42),
                  primaryColor.withValues(alpha: 0.20),
                ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawPath(backPath, backWavePaint);

      // 4B. FOREGROUND WAVE (Layer 2 - Main rich gradient)
      final frontPath = Path()..moveTo(startX, bottomY);
      final crestPoints = <Offset>[];
      for (double x = startX; x <= endX; x += 3.0) {
        final relX = (x - startX) / waveWidth;
        final y = waterY + amp * math.cos((relX * 2 * math.pi) + wavePhase);
        frontPath.lineTo(x, y);
        crestPoints.add(Offset(x, y));
      }
      frontPath.lineTo(endX, bottomY);
      frontPath.close();

      final frontWavePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isCompleted
              ? [
                  AppColors.secondaryDark.withValues(alpha: 0.95),
                  AppColors.secondaryLight.withValues(alpha: 0.85),
                  const Color(0xFFC4984F).withValues(alpha: 0.92),
                ]
              : [
                  (isDark ? AppColors.primaryDark : primaryColor).withValues(alpha: 0.90),
                  primaryColor.withValues(alpha: 0.82),
                  (isDark ? const Color(0xFF0F323E) : const Color(0xFF144759)).withValues(alpha: 0.95),
                ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawPath(frontPath, frontWavePaint);

      // 4C. GLISTENING CREST HIGHLIGHT LINE
      if (crestPoints.isNotEmpty && effectiveProgress > 0.02 && effectiveProgress < 0.985) {
        final crestPath = Path()..moveTo(crestPoints.first.dx, crestPoints.first.dy);
        for (int i = 1; i < crestPoints.length; i++) {
          crestPath.lineTo(crestPoints[i].dx, crestPoints[i].dy);
        }
        final crestPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..color = Colors.white.withValues(alpha: isCompleted ? 0.85 : 0.65);
        canvas.drawPath(crestPath, crestPaint);
      }

      // 4D. ASCENDING MICRO-BUBBLES
      if (effectiveProgress > 0.08) {
        final bubblePaint = Paint()..style = PaintingStyle.fill;
        for (int i = 0; i < 6; i++) {
          final phase = (wavePhase / (2 * math.pi) + (i * 0.165)) % 1.0;
          final bubbleX = center.dx - radius * 0.65 + ((i * 41) % (radius * 1.3));
          final startBubbleY = center.dy + radius - 10;
          final targetBubbleY = waterY + 12;
          final bubbleY = startBubbleY - (phase * (startBubbleY - targetBubbleY));

          if (bubbleY > waterY + 4 && bubbleY < startBubbleY) {
            final bubbleRadius = 1.6 + ((i % 3) * 0.7);
            final bubbleAlpha = (math.sin(phase * math.pi) * 0.40).clamp(0.0, 0.40);
            bubblePaint.color = Colors.white.withValues(alpha: bubbleAlpha);
            canvas.drawCircle(Offset(bubbleX, bubbleY), bubbleRadius, bubblePaint);
          }
        }
      }

      // 4E. COMPLETION SHIMMER LIGHT SWEEP
      if (isCompleted) {
        final sweepAngle = (completionProgress * 2 * math.pi);
        final shimmerPaint = Paint()
          ..shader = ui.Gradient.sweep(
            center,
            [
              Colors.white.withValues(alpha: 0.0),
              Colors.white.withValues(alpha: 0.28),
              Colors.white.withValues(alpha: 0.0),
            ],
            [0.0, 0.15, 0.30],
            TileMode.clamp,
            sweepAngle,
            sweepAngle + 0.6,
          );
        canvas.drawCircle(center, radius - 2, shimmerPaint);
      }
    }

    // 5. 3D GLASS SPECULAR REFLECTION (Curved Porthole Highlight)
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.20 : 0.38),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(center.dx, center.dy - radius * 0.55),
          radius: radius * 0.7,
        ),
      );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - radius * 0.58),
        width: radius * 1.15,
        height: radius * 0.40,
      ),
      highlightPaint,
    );

    canvas.restore(); // Restore clip

    // 6. OUTER BEZEL & PROGRESS TRACK
    final bezelPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..color = isCompleted
          ? AppColors.secondaryLight
          : (isDark
              ? primaryColor.withValues(alpha: 0.30)
              : trackColor.withValues(alpha: 0.85));
    canvas.drawCircle(center, radius, bezelPaint);

    // Perimeter progress arc
    if (effectiveProgress > 0.0) {
      final arcPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 4.5
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: isCompleted
              ? [AppColors.secondaryLight, AppColors.secondaryDark]
              : [
                  isDark ? AppColors.primaryDark : primaryColor,
                  isDark ? AppColors.primaryLight : primaryColor,
                ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * effectiveProgress,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaterWavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.wavePhase != wavePhase ||
        oldDelegate.perturbation != perturbation ||
        oldDelegate.completionProgress != completionProgress ||
        oldDelegate.isCompleted != isCompleted ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.isDark != isDark;
  }
}
