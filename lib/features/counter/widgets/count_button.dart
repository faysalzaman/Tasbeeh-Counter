import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/localization/l10n_extension.dart';

class CountButton extends StatefulWidget {
  final VoidCallback? onTap;

  const CountButton({super.key, this.onTap});

  @override
  State<CountButton> createState() => _CountButtonState();
}

class _CountButtonState extends State<CountButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    HapticFeedback.lightImpact();
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    widget.onTap!();
  }

  void _onTapCancel() {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isDisabled = widget.onTap == null;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isDisabled
                ? LinearGradient(
                    colors: [
                      theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
            boxShadow: isDisabled
                ? []
                : [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(
                        alpha: _isPressed ? 0.15 : 0.35,
                      ),
                      blurRadius: _isPressed ? 10 : 20,
                      spreadRadius: _isPressed ? 1 : 2,
                      offset: Offset(0, _isPressed ? 4 : 8),
                    ),
                  ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: 48,
                  color: isDisabled
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                      : Colors.white,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.tap,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDisabled
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                        : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
