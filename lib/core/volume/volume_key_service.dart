import 'dart:async';

import 'package:flutter/services.dart';

/// Intercepts hardware volume up/down key presses natively (Android) so that
/// the system volume overlay is NOT shown and the media volume is not changed.
/// The key presses are forwarded to Dart as stream events.
///
/// On platforms where the native handler is not registered (e.g. iOS), calls
/// are no-ops and [enable] returns false.
class VolumeKeyService {
  static final VolumeKeyService instance = VolumeKeyService._();

  VolumeKeyService._();

  static const MethodChannel _methodChannel =
      MethodChannel('tesbeeh/volume_keys');
  static const EventChannel _eventChannel =
      EventChannel('tesbeeh/volume_keys_events');

  StreamSubscription<dynamic>? _subscription;
  StreamController<String>? _controller;
  bool _enabled = false;

  /// Whether interception is currently active.
  bool get isEnabled => _enabled;

  /// Emits "up" or "down" for each hardware volume key press while enabled.
  Stream<String>? get events => _controller?.stream;

  /// Enables native volume key interception. Returns false if the platform
  /// does not support it.
  Future<bool> enable() async {
    if (_enabled) return true;
    try {
      await _methodChannel.invokeMethod<dynamic>('enable');
    } on PlatformException catch (_) {
      return false;
    } on MissingPluginException catch (_) {
      return false;
    }

    _controller = StreamController<String>.broadcast();
    _subscription = _eventChannel.receiveBroadcastStream().listen(
      (data) => _controller?.add(data.toString()),
      onError: (_) {},
    );
    _enabled = true;
    return true;
  }

  /// Disables interception and restores default volume key behaviour.
  Future<void> disable() async {
    if (!_enabled) return;
    try {
      await _methodChannel.invokeMethod<dynamic>('disable');
    } on PlatformException catch (_) {
      // ignore
    } on MissingPluginException catch (_) {
      // ignore
    }
    await _subscription?.cancel();
    _subscription = null;
    await _controller?.close();
    _controller = null;
    _enabled = false;
  }
}
