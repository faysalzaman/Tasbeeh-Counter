import 'package:flutter/material.dart';

@immutable
class AppColors {
  const AppColors._();

  // Primary - Islamic green/teal inspired
  static const Color primaryLight = Color(0xFF2E8B57); // Sea Green
  static const Color primaryDark = Color(0xFF3CB371); // Medium Sea Green

  // Secondary - Warm gold/amber
  static const Color secondaryLight = Color(0xFFC59529); // Rich Gold
  static const Color secondaryDark = Color(0xFFE6C875); // Soft Gold

  // Backgrounds & Surfaces
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF14171A);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF21262C);

  // Text / Content
  static const Color textPrimaryLight = Color(0xFF1F2937);
  static const Color textPrimaryDark = Color(0xFFF3F4F6);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  // Accents & Feedback
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Custom Extension Tokens
  static const Color progressBackgroundLight = Color(0xFFE5E7EB);
  static const Color progressBackgroundDark = Color(0xFF374151);

  /// Light ColorScheme
  static ColorScheme get lightColorScheme => const ColorScheme(
    brightness: Brightness.light,
    primary: primaryLight,
    onPrimary: Colors.white,
    secondary: secondaryLight,
    onSecondary: Colors.white,
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
    onPrimary: Colors.black,
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
