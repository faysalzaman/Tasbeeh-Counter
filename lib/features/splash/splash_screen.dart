import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../core/theme/app_colors.dart';
import '../../router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bismillahController;
  late final AnimationController _prayController;

  bool _showPray = false;
  bool _prayLoaded = false;

  @override
  void initState() {
    super.initState();
    _bismillahController = AnimationController(vsync: this);
    _prayController = AnimationController(vsync: this);

    _bismillahController.addStatusListener(_onBismillahStatusChanged);
    _prayController.addStatusListener(_onPrayStatusChanged);
  }

  void _onBismillahStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() => _showPray = true);
      if (_prayLoaded) {
        _prayController.forward();
      }
    }
  }

  void _onPrayStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _navigateToHome();
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
    _prayController.removeStatusListener(_onPrayStatusChanged);
    _bismillahController.dispose();
    _prayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final lottieWidth = size.width * 0.7;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: lottieWidth,
                child: Lottie.asset(
                  'assets/lottie/bismillah.json',
                  controller: _bismillahController,
                  onLoaded: (composition) {
                    _bismillahController.duration = composition.duration;
                    _bismillahController.forward();
                  },
                ),
              ),
              if (_showPray)
                SizedBox(
                  width: lottieWidth,
                  child: Lottie.asset(
                    'assets/lottie/pray.json',
                    controller: _prayController,
                    onLoaded: (composition) {
                      _prayController.duration = composition.duration;
                      _prayLoaded = true;
                      _prayController.forward();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
