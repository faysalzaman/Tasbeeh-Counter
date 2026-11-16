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

  /// Invoked when the user taps a dhikr reminder notification while the app
  /// is running. Registered from main() so this service stays free of
  /// router/UI imports.
  void Function(String dhikrId)? onDhikrReminderTap;

  Future<bool> initialize() async {
    if (_initialized) return true;

    tz_data.initializeTimeZones();

    if (!await refreshTimezone()) return false;

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

  /// Points tz.local at the device's current time zone. Refreshed on resume
  /// too, since the zone can change while away. Never fails outright: if the
  /// reported identifier is unknown or disagrees with the device clock, the
  /// zone is derived from the device UTC offset instead.
  Future<bool> refreshTimezone() async {
    final now = DateTime.now();
    tz.Location? location;
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      location = tz.getLocation(info.identifier);
    } catch (e) {
      debugPrint('NotificationService: could not resolve timezone id: $e');
    }
    if (location == null ||
        location.timeZone(now.millisecondsSinceEpoch).offset !=
            now.timeZoneOffset.inMilliseconds) {
      location = locationForDeviceOffset(now);
    }
    if (location == null) {
      debugPrint('NotificationService: failed to set local timezone');
      return false;
    }
    tz.setLocalLocation(location);
    return true;
  }

  @visibleForTesting
  static tz.Location? locationForDeviceOffset(DateTime now) {
    final offsetMs = now.timeZoneOffset.inMilliseconds;
    final atMs = now.millisecondsSinceEpoch;
    tz.Location? match;
    for (final location in tz.timeZoneDatabase.locations.values) {
      final zone = location.timeZone(atMs);
      if (zone.offset != offsetMs) continue;
      if (zone.abbreviation == now.timeZoneName) return location;
      match ??= location;
    }
    return match;
  }

  Future<List<PendingNotificationRequest>> pendingReminders() async {
    if (!_initialized && !await initialize()) return [];
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e, stack) {
      debugPrint('NotificationService pendingReminders error: $e');
      debugPrint('$stack');
      return [];
    }
  }

  @visibleForTesting
  static tz.TZDateTime nextDailyReminder(
    tz.TZDateTime now,
    int hour,
    int minute,
  ) {
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw ArgumentError('Invalid reminder time: $hour:$minute');
    }
    var scheduled = tz.TZDateTime(
      now.location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      // Calendar arithmetic preserves the wall-clock time across DST changes.
      scheduled = tz.TZDateTime(
        now.location,
        now.year,
        now.month,
        now.day + 1,
        hour,
        minute,
      );
    }
    return scheduled;
  }

  void _onNotificationTap(NotificationResponse response) {
    final dhikrId = response.payload;
    if (dhikrId == null || dhikrId.isEmpty) return;
    debugPrint('NotificationService: reminder tapped for dhikr $dhikrId');
    onDhikrReminderTap?.call(dhikrId);
  }

  /// The dhikr id whose reminder notification launched the app (cold start),
  /// if any. Check once on app launch to deep-link into the counter.
  Future<String?> getLaunchDhikrId() async {
    try {
      final details = await _notifications.getNotificationAppLaunchDetails();
      if (details == null || !details.didNotificationLaunchApp) return null;
      final payload = details.notificationResponse?.payload;
      if (payload != null && payload.isNotEmpty) return payload;
    } catch (e, stack) {
      debugPrint('NotificationService getLaunchDhikrId error: $e');
      debugPrint('$stack');
    }
    return null;
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

  int get pendingReminderLimit =>
      defaultTargetPlatform == TargetPlatform.iOS ? 64 : 500;

  Future<bool> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_initialized && !(await initialize())) {
      debugPrint('NotificationService not initialized');
      return false;
    }

    try {
      // Keep the wall-clock time the user expects in the device time zone.
      final localDate = scheduledDate.toLocal();
      final tz.TZDateTime tzScheduledDate = tz.TZDateTime(
        tz.local,
        localDate.year,
        localDate.month,
        localDate.day,
        localDate.hour,
        localDate.minute,
        localDate.second,
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
        payload: payload,
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
    String? payload,
  }) => _scheduleRepeatingReminder(
    id: id,
    title: title,
    body: body,
    hour: hour,
    minute: minute,
    payload: payload,
  );

  Future<bool> scheduleWeeklyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required int weekday,
    String? payload,
  }) => _scheduleRepeatingReminder(
    id: id,
    title: title,
    body: body,
    hour: hour,
    minute: minute,
    weekday: weekday,
    payload: payload,
  );

  Future<bool> _scheduleRepeatingReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
    int? weekday,
  }) async {
    if (!_initialized && !(await initialize())) {
      debugPrint('NotificationService not initialized');
      return false;
    }

    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduled = nextDailyReminder(now, hour, minute);
      if (weekday != null) {
        scheduled = tz.TZDateTime(
          now.location,
          scheduled.year,
          scheduled.month,
          scheduled.day + (weekday - scheduled.weekday) % 7,
          hour,
          minute,
        );
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
        matchDateTimeComponents: weekday == null
            ? DateTimeComponents.time
            : DateTimeComponents.dayOfWeekAndTime,
        payload: payload,
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
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iosPlugin != null) {
        return (await iosPlugin.checkPermissions())?.isEnabled ?? false;
      }
      return true;
    } catch (e, stack) {
      debugPrint('NotificationService areNotificationsEnabled error: $e');
      debugPrint('$stack');
      return false;
    }
  }
}
