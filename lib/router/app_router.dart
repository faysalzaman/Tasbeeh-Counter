import 'package:go_router/go_router.dart';
import '../core/storage/local_storage.dart';
import '../features/home/home_screen.dart';
import '../features/counter/counter_screen.dart';
import '../features/dhikr_detail/dhikr_detail_screen.dart';
import '../features/dhikr_selection/dhikr_selection_screen.dart';
import '../features/wazifa/create_wazifa_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/quick_dhikr/quick_dhikr_screen.dart';
import '../features/my_wazifas/my_wazifas_screen.dart';
import '../features/continue_wazifa/continue_wazifa_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String counter = '/counter';
  static const String dhikrDetail = '/dhikr-detail';
  static const String dhikrSelection = '/dhikr-selection';
  static const String createWazifa = '/create-wazifa';
  static const String settings = '/settings';
  static const String quickDhikr = '/quick-dhikr';
  static const String myWazifas = '/my-wazifas';
  static const String continueWazifa = '/continue-wazifa';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  redirect: (context, state) {
    final hasCompletedOnboarding =
        LocalStorage.instance.getSettings().hasCompletedOnboarding;
    final isOnboarding = state.matchedLocation == AppRoutes.onboarding;

    if (!hasCompletedOnboarding && !isOnboarding) {
      return AppRoutes.onboarding;
    }
    if (hasCompletedOnboarding && isOnboarding) {
      return AppRoutes.home;
    }
    return null;
  },
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
      path: AppRoutes.dhikrDetail,
      builder: (context, state) {
        final dhikrId = state.extra as String?;
        return DhikrDetailScreen(dhikrId: dhikrId ?? '');
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
    GoRoute(
      path: AppRoutes.quickDhikr,
      builder: (context, state) => const QuickDhikrScreen(),
    ),
    GoRoute(
      path: AppRoutes.myWazifas,
      builder: (context, state) => const MyWazifasScreen(),
    ),
    GoRoute(
      path: AppRoutes.continueWazifa,
      builder: (context, state) => const ContinueWazifaScreen(),
    ),
  ],
);
