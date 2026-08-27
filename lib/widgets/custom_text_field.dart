import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

// =============================================================================
// REUSABLE APP TEXT FIELD
// =============================================================================
// A minimal, platform-aware drop-in replacement for [TextFormField].
//
// Usage:
//   AppTextField(
//     controller: _nameController,
//     label: l10n.dhikrName,
//     hint: l10n.dhikrNameHint,
//     prefixIcon: Iconsax.text,
//     validator: (v) => v?.trim().isEmpty ?? true ? l10n.validationRequired : null,
//   )
// =============================================================================

/// A clean, consistent text field used across all forms in the app.
///
/// Automatically handles:
/// - Themed borders, fill color, and focus states
/// - Prefix / suffix icons with correct sizing
/// - RTL text direction support
/// - Platform-adaptive density (compact on iOS)
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.textDirection,
    this.style,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.obscureText = false,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.readOnly = false,
    this.onTap,
    this.initialValue,
    this.maxLength,
    this.inputFormatters,
  });

  /// For number-only inputs (target count, days, etc.).
  factory AppTextField.number({
    Key? key,
    TextEditingController? controller,
    String? label,
    String? hint,
    IconData? prefixIcon,
    String? Function(String?)? validator,
    bool enabled = true,
    TextInputAction? textInputAction,
    ValueChanged<String>? onChanged,
    VoidCallback? onSubmitted,
    FocusNode? focusNode,
    bool autofocus = false,
  }) => AppTextField(
    key: key,
    controller: controller,
    label: label,
    hint: hint,
    prefixIcon: prefixIcon,
    validator: validator,
    keyboardType: TextInputType.number,
    enabled: enabled,
    textInputAction: textInputAction,
    onChanged: onChanged,
    onSubmitted: onSubmitted != null ? (_) => onSubmitted() : null,
    focusNode: focusNode,
    autofocus: autofocus,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  );

  /// For multi-line inputs (notes, descriptions).
  factory AppTextField.multiline({
    Key? key,
    TextEditingController? controller,
    String? label,
    String? hint,
    IconData? prefixIcon,
    int maxLines = 3,
    int minLines = 2,
    bool enabled = true,
    ValueChanged<String>? onChanged,
    FocusNode? focusNode,
  }) => AppTextField(
    key: key,
    controller: controller,
    label: label,
    hint: hint,
    prefixIcon: prefixIcon,
    maxLines: maxLines,
    minLines: minLines,
    enabled: enabled,
    onChanged: onChanged,
    focusNode: focusNode,
    keyboardType: TextInputType.multiline,
    textInputAction: TextInputAction.newline,
  );

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextDirection? textDirection;
  final TextStyle? style;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? initialValue;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  static const _radius = 12.0;
  static const _contentPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 16,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isIOS =
        theme.platform == TargetPlatform.iOS ||
        theme.platform == TargetPlatform.macOS;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(_radius),
      borderSide: BorderSide(
        color: cs.outlineVariant.withValues(alpha: 0.5),
      ),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(_radius),
      borderSide: BorderSide(
        color: cs.primary,
        width: isIOS ? 1.5 : 2,
      ),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(_radius),
      borderSide: BorderSide(
        color: cs.error,
        width: isIOS ? 1.5 : 2,
      ),
    );

    final filledColor = enabled
        ? cs.surfaceContainerHighest.withValues(alpha: 0.4)
        : cs.surfaceContainerHighest.withValues(alpha: 0.2);

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      validator: validator,
      keyboardType: keyboardType,
      textDirection: textDirection,
      style: style ?? theme.textTheme.bodyLarge,
      maxLines: maxLines,
      minLines: minLines,
      enabled: enabled,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      focusNode: focusNode,
      autofocus: autofocus,
      readOnly: readOnly,
      onTap: onTap,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 20, color: cs.onSurfaceVariant)
            : null,
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, size: 20, color: cs.onSurfaceVariant)
            : null,
        filled: true,
        fillColor: filledColor,
        contentPadding: _contentPadding,
        border: border,
        enabledBorder: border,
        focusedBorder: focusedBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
        disabledBorder: border,
        labelStyle: theme.textTheme.bodyLarge?.copyWith(
          color: cs.onSurfaceVariant,
        ),
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: cs.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        errorStyle: theme.textTheme.bodySmall?.copyWith(
          color: cs.error,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        alignLabelWithHint: maxLines != null && maxLines! > 1,
      ),
    );
  }
}
