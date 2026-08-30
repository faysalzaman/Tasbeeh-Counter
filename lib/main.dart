import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/audio/audio_service.dart';
import 'core/haptics/haptics_service.dart';
import 'core/notifications/notification_service.dart';
import 'core/storage/local_storage.dart';
import 'repositories/dhikr_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorage.initialize();

  await AudioService().initialize();
  await HapticsService().initialize();
  await NotificationService().initialize();

  // NEW — request notification permission (Android 13+ / iOS) before
  // syncing reminders, otherwise scheduled notifications won't show.
  await NotificationService().requestPermission();

  // NEW — exact-alarm permission is a separate, more invasive prompt
  // (opens system settings on Android 12+). Don't fire it blind on cold
  // start — gate it behind onboarding or a settings toggle instead:
  //
  // await NotificationService().requestExactAlarmPermission();
  //
  // Leaving it out of main() here; call it from wherever you introduce
  // the reminder feature to the user, with context on why it matters.

  await DhikrRepository(LocalStorage.instance).syncAllReminders();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: TasbeehCounterApp()));
}
