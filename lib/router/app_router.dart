import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/counter/counter_screen.dart';
import '../features/dhikr_selection/dhikr_selection_screen.dart';
import '../features/wazifa/create_wazifa_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/onboarding/onboarding_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String counter = '/counter';
  static const String dhikrSelection = '/dhikr-selection';
  static const String createWazifa = '/create-wazifa';
  static const String settings = '/settings';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.counter,
      builder: (context, state) {
        final dhikrId = state.extra as String?;
        return CounterScreen(dhikrId: dhikrId ?? '');
      },
    ),
    GoRoute(
      path: AppRoutes.dhikrSelection,
      builder: (context, state) => const DhikrSelectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.createWazifa,
      builder: (context, state) {
        final dhikrId = state.extra as String?;
        return CreateWazifaScreen(dhikrId: dhikrId);
      },
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
