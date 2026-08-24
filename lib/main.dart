import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/audio/audio_service.dart';
import 'core/haptics/haptics_service.dart';
import 'core/localization/generated/app_localizations.dart';
import 'core/notifications/notification_service.dart';
import 'core/storage/local_storage.dart';
import 'core/theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'repositories/dhikr_repository.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage
  await LocalStorage.initialize();

  // Initialize services
  await AudioService().initialize();
  await HapticsService().initialize();
  await NotificationService().initialize();

  // Sync wazifa reminders (reschedule/cancel based on current settings)
  await DhikrRepository(LocalStorage.instance).syncAllReminders();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: TasbeehCounterApp()));
}

class TasbeehCounterApp extends ConsumerWidget {
  const TasbeehCounterApp({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'Digital Tasbeeh',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _getThemeMode(settings.themeMode),
      locale: _getLocale(settings.languageCode),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
      builder: (context, child) {
        final locale = Localizations.localeOf(context);
        final isRTL =
            locale.languageCode == 'ar' || locale.languageCode == 'ur';

        return Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
    );
  }
}
