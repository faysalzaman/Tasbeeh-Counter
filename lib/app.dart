import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/localization/generated/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'providers/dhikr_provider.dart';
import 'providers/counter_provider.dart';
import 'core/notifications/notification_service.dart';
import 'router/app_router.dart';

class TasbeehCounterApp extends ConsumerStatefulWidget {
  const TasbeehCounterApp({super.key});

  @override
  ConsumerState<TasbeehCounterApp> createState() => _TasbeehCounterAppState();
}

class _TasbeehCounterAppState extends ConsumerState<TasbeehCounterApp>
    with WidgetsBindingObserver {
  Timer? _rolloverTimer;

  void _startRolloverTimer() {
    _rolloverTimer?.cancel();
    final now = DateTime.now();
    // Each schedule boundary falls on a whole minute (including midnight).
    final next = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 1,
    );
    _rolloverTimer = Timer(next.difference(now), () async {
      if (!mounted) return;
      await ref.read(counterStateProvider.notifier).refreshExpiredSchedules();
      if (mounted) _startRolloverTimer();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startRolloverTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !ref.read(settingsProvider).reminderNotifications) return;
      // Default azkaar also need exact-alarm access for reminders on time.
      if (await NotificationService().areNotificationsEnabled()) {
        final notifications = NotificationService();
        if (!await notifications.canScheduleExactAlarms()) {
          final preferences = await SharedPreferences.getInstance();
          const key = 'hasRequestedExactAlarmPermission';
          if (!(preferences.getBool(key) ?? false)) {
            await preferences.setBool(key, true);
            await notifications.requestExactAlarmPermission();
          }
        }
        await _syncReminders();
      }
    });
  }

  Future<void> _syncReminders() async {
    await ref.read(counterStateProvider.notifier).refreshExpiredSchedules();
    if (!mounted) return;
    final notifications = NotificationService();
    if (!await notifications.initialize()) return;
    if (!await notifications.refreshTimezone() || !mounted) return;
    await ref.read(dhikrRepositoryProvider).syncAllReminders();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startRolloverTimer();
      _syncReminders();
    } else {
      _rolloverTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _rolloverTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  ThemeMode _getThemeMode(String themeMode) {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Locale? _getLocale(String languageCode) {
    switch (languageCode) {
      case 'en':
        return const Locale('en');
      case 'ar':
        return const Locale('ar');
      case 'ur':
        return const Locale('ur');
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _getThemeMode(settings.themeMode),
      locale: _getLocale(settings.languageCode),
      localizationsDelegates: [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
      builder: (context, child) {
        final locale = Localizations.localeOf(context);
        final isRTL =
            locale.languageCode == 'ar' || locale.languageCode == 'ur';
        final platformBrightness = MediaQuery.platformBrightnessOf(context);

        final effectiveBrightness = switch (settings.themeMode) {
          'light' => Brightness.light,
          'dark' => Brightness.dark,
          _ => platformBrightness,
        };

        return CupertinoTheme(
          data: CupertinoThemeData(brightness: effectiveBrightness),
          child: Directionality(
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            child: child!,
          ),
        );
      },
    );
  }
}
