import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../constants/app_constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<bool> initialize() async {
    if (_initialized) return true;

    tz_data.initializeTimeZones();

    // Set tz.local to the device's real timezone instead of defaulting to UTC.
    try {
      final TimezoneInfo timezoneInfo =
          await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (e) {
      debugPrint('NotificationService: failed to set local timezone: $e');
      // Falls back to UTC — better to log this loudly since it silently
      // breaks every scheduled time otherwise.
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      final result = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      const androidChannel = AndroidNotificationChannel(
        AppConstants.reminderChannelId,
        AppConstants.reminderChannelName,
        description: AppConstants.reminderChannelDescription,
        importance: Importance.high,
        playSound: true,
      );

      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(androidChannel);

      // NOTE: on iOS, initialize() returns `false` whenever
      // requestAlertPermission/Badge/Sound are all false in
      // DarwinInitializationSettings — this is a documented quirk
      // (flutter_local_notifications#1828), not a failure. Since we
      // intentionally defer permission requests to requestPermission(),
      // treat reaching this point without an exception as success.
      _initialized = true;
      debugPrint(
        'NotificationService: initialize() native result was $result (treated as success)',
      );
      return _initialized;
    } catch (e, stack) {
      debugPrint('NotificationService initialize error: $e');
      debugPrint('$stack');
      return false;
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    // TODO: Navigate to the specific dhikr when a reminder notification is tapped.
  }

  Future<bool> requestPermission() async {
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }

      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }

      return false;
    } catch (e, stack) {
      debugPrint('NotificationService requestPermission error: $e');
      debugPrint('$stack');
      return false;
    }
  }

  /// Checks whether the app can schedule exact alarms on Android 12+.
  Future<bool> canScheduleExactAlarms() async {
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin == null) return true; // Not Android
      return await androidPlugin.canScheduleExactNotifications() ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Opens the system "Alarms & reminders" special-access screen.
  /// Call this once, e.g. from a settings screen or right after onboarding,
  /// with an explanation of why exact timing matters for prayer reminders.
  Future<bool> requestExactAlarmPermission() async {
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin == null) return true; // Not Android

      if (await androidPlugin.canScheduleExactNotifications() ?? false) {
        return true;
      }
      final granted = await androidPlugin.requestExactAlarmsPermission();
      return granted ?? false;
    } catch (e, stack) {
      debugPrint('NotificationService requestExactAlarmPermission error: $e');
      debugPrint('$stack');
      return false;
    }
  }

  /// Picks exact vs inexact scheduling based on what's actually granted,
  /// so a schedule call never silently fails or throws.
  Future<AndroidScheduleMode> _resolveScheduleMode() async {
    final exact = await canScheduleExactAlarms();
    return exact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  Future<bool> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!_initialized && !(await initialize())) {
      debugPrint('NotificationService not initialized');
      return false;
    }

    try {
      final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      );

      if (tzScheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        debugPrint('NotificationService: scheduledDate is in the past');
        return false;
      }

      final scheduleMode = await _resolveScheduleMode();

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.reminderChannelId,
            AppConstants.reminderChannelName,
            channelDescription: AppConstants.reminderChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint(
        'NotificationService: scheduled reminder $id at $scheduledDate ($scheduleMode)',
      );
      return true;
    } catch (e, stack) {
      debugPrint('NotificationService scheduleReminder error: $e');
      debugPrint('$stack');
      return false;
    }
  }

  Future<bool> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (!_initialized && !(await initialize())) {
      debugPrint('NotificationService not initialized');
      return false;
    }

    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (!scheduled.isAfter(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      final scheduleMode = await _resolveScheduleMode();

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.reminderChannelId,
            AppConstants.reminderChannelName,
            channelDescription: AppConstants.reminderChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint(
        'NotificationService: scheduled daily reminder $id at $hour:$minute ($scheduleMode)',
      );
      return true;
    } catch (e, stack) {
      debugPrint('NotificationService scheduleDailyReminder error: $e');
      debugPrint('$stack');
      return false;
    }
  }

  Future<bool> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized && !(await initialize())) return false;

    try {
      await _notifications.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.reminderChannelId,
            AppConstants.reminderChannelName,
            channelDescription: AppConstants.reminderChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
      return true;
    } catch (e, stack) {
      debugPrint('NotificationService showImmediateNotification error: $e');
      debugPrint('$stack');
      return false;
    }
  }

  Future<void> cancelReminder(int id) async {
    if (!_initialized) return;
    try {
      await _notifications.cancel(id);
      debugPrint('NotificationService: cancelled reminder $id');
    } catch (e, stack) {
      debugPrint('NotificationService cancelReminder error: $e');
      debugPrint('$stack');
    }
  }

  Future<void> cancelAllReminders() async {
    if (!_initialized) return;
    try {
      await _notifications.cancelAll();
    } catch (e, stack) {
      debugPrint('NotificationService cancelAllReminders error: $e');
      debugPrint('$stack');
    }
  }

  Future<bool> areNotificationsEnabled() async {
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        final enabled = await androidPlugin.areNotificationsEnabled();
        return enabled ?? false;
      }
      return true;
    } catch (e, stack) {
      debugPrint('NotificationService areNotificationsEnabled error: $e');
      debugPrint('$stack');
      return false;
    }
  }
}
