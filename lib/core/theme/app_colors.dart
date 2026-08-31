import 'package:flutter/material.dart';

@immutable
class AppColors {
  const AppColors._();

  // Primary - Deep Oceanic Teal sampled directly from logo background gradient
  static const Color primaryLight = Color(0xFF1D5C73); // Muted Deep Teal
  static const Color primaryDark = Color(
    0xFF1E5266,
  ); // Deep Teal Base (Icon Mid-tone)

  // Secondary - Refined Champagne Gold sampled from the metallic crescent/beads
  static const Color secondaryLight = Color(0xFFCBA569); // Elegant Warm Gold
  static const Color secondaryDark = Color(0xFFE5C384); // Soft Glowing Gold

  // Backgrounds & Surfaces (Muted slate-blues to complement the logo background)
  static const Color backgroundLight = Color(0xFFF4F8FA);
  static const Color backgroundDark = Color(0xFF0D1C24); // Deep Night Teal
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF152630); // Elevated Teal Surface

  // Text / Content
  static const Color textPrimaryLight = Color(0xFF0F1B21);
  static const Color textPrimaryDark = Color(0xFFECEFF1);
  static const Color textSecondaryLight = Color(0xFF4A616C);
  static const Color textSecondaryDark = Color(0xFF8BA2AD);

  // Accents & Feedback
  static const Color success = Color(0xFF2E8B75);
  static const Color warning = Color(0xFFD99B26);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF2980B9);

  // Custom Extension Tokens
  static const Color progressBackgroundLight = Color(0xFFDDE6EB);
  static const Color progressBackgroundDark = Color(0xFF223642);

  /// Light ColorScheme
  static ColorScheme get lightColorScheme => const ColorScheme(
    brightness: Brightness.light,
    primary: primaryLight,
    onPrimary: Colors.white,
    secondary: secondaryLight,
    onSecondary: Colors.black,
    error: error,
    onError: Colors.white,
    surface: surfaceLight,
    onSurface: textPrimaryLight,
    onSurfaceVariant: textSecondaryLight,
  );

  /// Dark ColorScheme
  static ColorScheme get darkColorScheme => const ColorScheme(
    brightness: Brightness.dark,
    primary: primaryDark,
    onPrimary: Colors.white,
    secondary: secondaryDark,
    onSecondary: Colors.black,
    error: error,
    onError: Colors.white,
    surface: surfaceDark,
    onSurface: textPrimaryDark,
    onSurfaceVariant: textSecondaryDark,
  );

  /// Complete Light ThemeData
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: lightColorScheme,
    scaffoldBackgroundColor: backgroundLight,
    extensions: const [
      DhikrThemeExtension(
        progressTrackColor: progressBackgroundLight,
        counterSuccess: success,
      ),
    ],
  );

  /// Complete Dark ThemeData
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: darkColorScheme,
    scaffoldBackgroundColor: backgroundDark,
    extensions: const [
      DhikrThemeExtension(
        progressTrackColor: progressBackgroundDark,
        counterSuccess: success,
      ),
    ],
  );
}

/// Custom Theme Extension for domain-specific counter colors
@immutable
class DhikrThemeExtension extends ThemeExtension<DhikrThemeExtension> {
  final Color progressTrackColor;
  final Color counterSuccess;

  const DhikrThemeExtension({
    required this.progressTrackColor,
    required this.counterSuccess,
  });

  @override
  DhikrThemeExtension copyWith({
    Color? progressTrackColor,
    Color? counterSuccess,
  }) {
    return DhikrThemeExtension(
      progressTrackColor: progressTrackColor ?? this.progressTrackColor,
      counterSuccess: counterSuccess ?? this.counterSuccess,
    );
  }

  @override
  DhikrThemeExtension lerp(
    ThemeExtension<DhikrThemeExtension>? other,
    double t,
  ) {
    if (other is! DhikrThemeExtension) return this;
    return DhikrThemeExtension(
      progressTrackColor: Color.lerp(
        progressTrackColor,
        other.progressTrackColor,
        t,
      )!,
      counterSuccess: Color.lerp(counterSuccess, other.counterSuccess, t)!,
    );
  }
}
