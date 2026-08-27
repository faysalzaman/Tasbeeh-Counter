import 'package:material_ui/material_ui.dart';

// =============================================================================
// REUSABLE APP BUTTONS
// =============================================================================
// Only the buttons actually repeated across screens. Keep it minimal.
//
//   AppButton.primary(label: 'Save', icon: Icons.save, onPressed: _save)
//   AppButton.outlined(label: 'Cancel', onPressed: _cancel)
//   AppButton.danger(label: 'Delete', onPressed: _delete)
//   AppIconButton(icon: Icons.edit, onPressed: _edit)
//   AppFab(icon: Icons.add, label: 'Create', onPressed: _create)
// =============================================================================

/// The main button used on almost every screen.
///
/// Wraps [FilledButton.icon] with the app's consistent border-radius,
/// height, and typography so we never repeat `styleFrom` boilerplate.
class AppButton extends StatelessWidget {
  const AppButton._({
    super.key,
    required this.variant,
    required this.label,
    this.onPressed,
    this.icon,
    this.iconAfterLabel = false,
    this.isExpanded = false,
    this.height = 45,
  });

  factory AppButton.primary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool iconAfterLabel = false,
    bool isExpanded = false,
    double height = 45,
  }) => AppButton._(
    key: key,
    variant: AppButtonVariant.primary,
    label: label,
    onPressed: onPressed,
    icon: icon,
    iconAfterLabel: iconAfterLabel,
    isExpanded: isExpanded,
    height: height,
  );

  factory AppButton.outlined({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool iconAfterLabel = false,
    bool isExpanded = false,
    double height = 45,
  }) => AppButton._(
    key: key,
    variant: AppButtonVariant.outlined,
    label: label,
    onPressed: onPressed,
    icon: icon,
    iconAfterLabel: iconAfterLabel,
    isExpanded: isExpanded,
    height: height,
  );

  factory AppButton.text({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool iconAfterLabel = false,
  }) => AppButton._(
    key: key,
    variant: AppButtonVariant.text,
    label: label,
    onPressed: onPressed,
    icon: icon,
    iconAfterLabel: iconAfterLabel,
    height: 44,
  );

  factory AppButton.danger({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool iconAfterLabel = false,
    bool isExpanded = false,
    double height = 45,
  }) => AppButton._(
    key: key,
    variant: AppButtonVariant.danger,
    label: label,
    onPressed: onPressed,
    icon: icon,
    iconAfterLabel: iconAfterLabel,
    isExpanded: isExpanded,
    height: height,
  );

  final AppButtonVariant variant;
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool iconAfterLabel;
  final bool isExpanded;
  final double height;

  static const _radius = 12.0;
  static const _padding = EdgeInsets.symmetric(horizontal: 20);

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: variant == AppButtonVariant.text ? 14 : 15,
      fontWeight: FontWeight.w600,
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_radius),
    );

    final child = _buildChild();

    switch (variant) {
      case AppButtonVariant.primary:
        return FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            minimumSize: Size(isExpanded ? double.infinity : 0, height),
            padding: _padding,
            shape: shape,
            textStyle: style,
          ),
          child: child,
        );
      case AppButtonVariant.outlined:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: Size(isExpanded ? double.infinity : 0, height),
            padding: _padding,
            shape: shape,
            textStyle: style,
          ),
          child: child,
        );
      case AppButtonVariant.text:
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            minimumSize: Size(isExpanded ? double.infinity : 0, height),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: shape,
            textStyle: style,
          ),
          child: child,
        );
      case AppButtonVariant.danger:
        final cs = Theme.of(context).colorScheme;
        return FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            minimumSize: Size(isExpanded ? double.infinity : 0, height),
            padding: _padding,
            shape: shape,
            backgroundColor: cs.error,
            foregroundColor: cs.onError,
            textStyle: style,
          ),
          child: child,
        );
    }
  }

  Widget _buildChild() {
    final labelWidget = Text(label);
    if (icon == null) return labelWidget;

    final iconWidget = Icon(icon, size: 20);
    final gap = const SizedBox(width: 8);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: iconAfterLabel
          ? [labelWidget, gap, iconWidget]
          : [iconWidget, gap, labelWidget],
    );
  }
}

enum AppButtonVariant { primary, outlined, text, danger }

/// ---------------------------------------------------------------------------
/// ICON BUTTON
/// ---------------------------------------------------------------------------
/// A clean circular or rounded icon button used for inline actions
/// (edit, delete, bookmark, share, more, close, etc.).
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 40,
    this.iconSize = 20,
    this.color,
    this.backgroundColor,
    this.tooltip,
    this.borderRadius,
    this.border,
  });

  factory AppIconButton.outlined({
    Key? key,
    required IconData icon,
    VoidCallback? onPressed,
    Color? color,
    Color? borderColor,
    String? tooltip,
  }) => AppIconButton(
    key: key,
    icon: icon,
    onPressed: onPressed,
    size: 36,
    iconSize: 18,
    color: color,
    tooltip: tooltip,
    borderRadius: 10,
    border: borderColor != null ? Border.all(color: borderColor) : null,
  );

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? color;
  final Color? backgroundColor;
  final String? tooltip;
  final double? borderRadius;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final effectiveBg =
        backgroundColor ?? cs.primaryContainer.withValues(alpha: 0.4);
    final effectiveFg = color ?? cs.onSurfaceVariant;
    final radius = borderRadius ?? size / 2;

    final child = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: border,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, size: iconSize, color: effectiveFg),
    );

    final button = Material(
      color: effectiveBg,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );

    if (tooltip != null) return Tooltip(message: tooltip!, child: button);
    return button;
  }
}

/// ---------------------------------------------------------------------------
/// FLOATING ACTION BUTTON
/// ---------------------------------------------------------------------------
/// Wraps the extended FAB so every screen uses the same elevation & shape.
class AppFab extends StatelessWidget {
  const AppFab({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
    this.elevation = 3,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? label;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        elevation: elevation,
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        icon: Icon(icon),
        label: Text(
          label!,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );
    }
    return FloatingActionButton(
      onPressed: onPressed,
      elevation: elevation,
      backgroundColor: cs.primaryContainer,
      foregroundColor: cs.onPrimaryContainer,
      child: Icon(icon),
    );
  }
}
