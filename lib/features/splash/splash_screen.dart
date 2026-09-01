import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../core/notifications/notification_service.dart';
import '../../core/storage/local_storage.dart';
import '../../router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bismillahController;

  @override
  void initState() {
    super.initState();
    _bismillahController = AnimationController(vsync: this);
    _bismillahController.addStatusListener(_onBismillahStatusChanged);
    LocalStorage.instance.resetExpiredSchedules();
  }

  void _onBismillahStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      Future.delayed(const Duration(milliseconds: 600), _navigateToHome);
    }
  }

  Future<void> _navigateToHome() async {
    // If a reminder notification launched the app, deep-link straight into
    // that dhikr's counter instead of the home screen.
    final launchDhikrId = await NotificationService().getLaunchDhikrId();
    if (!mounted) return;
    if (launchDhikrId != null) {
      context.go(AppRoutes.counter, extra: launchDhikrId);
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _bismillahController.removeStatusListener(_onBismillahStatusChanged);
    _bismillahController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Image.asset(
              'assets/icon/playstore-icon.png',
              width: size.width * 0.35,
              height: size.width * 0.35,
            ),
            const SizedBox(height: 40),
            // Bismillah
            SizedBox(
              width: size.width * 0.7,
              child: Lottie.asset(
                'assets/lottie/bismillah.json',
                controller: _bismillahController,
                onLoaded: (composition) {
                  _bismillahController.duration = composition.duration;
                  _bismillahController.forward();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
