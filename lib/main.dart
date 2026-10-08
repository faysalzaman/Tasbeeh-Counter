import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/audio/audio_service.dart';
import 'core/haptics/haptics_service.dart';
import 'core/notifications/notification_service.dart';
import 'core/storage/local_storage.dart';
import 'repositories/dhikr_repository.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorage.initialize();
  await LocalStorage.instance.resetExpiredSchedules();

  await AudioService().initialize();
  await HapticsService().initialize();
  await NotificationService().initialize();

  // Request notification permission (Android 13+ / iOS) before
  // syncing reminders, otherwise scheduled notifications won't show.
  await NotificationService().requestPermission();

  // Deep-link: tapping a dhikr reminder while the app is running opens that
  // dhikr's counter.
  NotificationService().onDhikrReminderTap = (dhikrId) {
    appRouter.push(AppRoutes.counter, extra: dhikrId);
  };

  await DhikrRepository(LocalStorage.instance).syncAllReminders();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: TasbeehCounterApp()));
}
