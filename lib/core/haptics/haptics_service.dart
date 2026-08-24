import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class HapticsService {
  static final HapticsService _instance = HapticsService._internal();
  factory HapticsService() => _instance;
  HapticsService._internal();

  bool _hasVibrator = false;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _hasVibrator = await Vibration.hasVibrator();
      _initialized = true;
    } catch (e) {
      _hasVibrator = false;
      _initialized = true;
    }
  }

  Future<void> lightImpact() async {
    if (!_hasVibrator) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Fallback to vibration package
      try {
        await Vibration.vibrate(duration: 20);
      } catch (_) {}
    }
  }

  Future<void> mediumImpact() async {
    if (!_hasVibrator) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      try {
        await Vibration.vibrate(duration: 40);
      } catch (_) {}
    }
  }

  Future<void> heavyImpact() async {
    if (!_hasVibrator) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      try {
        await Vibration.vibrate(duration: 60);
      } catch (_) {}
    }
  }

  Future<void> completionFeedback() async {
    if (!_hasVibrator) return;
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
    } catch (e) {
      try {
        await Vibration.vibrate(pattern: [0, 100, 100, 100, 100, 100]);
      } catch (_) {}
    }
  }
}
