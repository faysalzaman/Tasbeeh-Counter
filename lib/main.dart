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
