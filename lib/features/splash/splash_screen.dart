import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

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
  }

  void _onBismillahStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      Future.delayed(const Duration(milliseconds: 600), _navigateToHome);
    }
  }

  void _navigateToHome() {
    if (mounted) {
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
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/icon/splash_screen.png', fit: BoxFit.cover),
            Positioned(
              left: 0,
              right: 0,
              bottom: 32,
              child: Center(
                child: SizedBox(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
