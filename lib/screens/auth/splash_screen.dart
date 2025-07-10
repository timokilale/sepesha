import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sepesha_app/Utilities/app_images.dart';
import 'package:sepesha_app/screens/auth/auth_screen.dart';
import 'package:sepesha_app/screens/auth/onboarding_screen.dart';
import 'package:sepesha_app/screens/dashboard/dashboard.dart';
import 'package:sepesha_app/Driver/dasboard/driver_dashboard.dart';
import 'package:sepesha_app/services/preferences.dart';
import 'package:sepesha_app/services/session_manager.dart';
import 'package:sepesha_app/services/token_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Create fade-in animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    // Create scale animation
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start animation
    _animationController.forward();

    // Check for token and navigate after animation completes
    Timer(const Duration(milliseconds: 2000), () {
      _checkTokenAndNavigate();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkTokenAndNavigate() async {
    // Use TokenManager to check if user is authenticated
    final isAuthenticated = await TokenManager.instance.isAuthenticated();

    if (isAuthenticated) {
      // User is authenticated, check user type and navigate accordingly
      final userType = await Preferences.instance.fetch<String?>('user_type');

      if (userType == 'driver') {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => DriverDashboard()));
      } else if (userType == 'vendor') {
        // For now, navigate to regular dashboard
        // In future, this could be a VendorDashboard
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => Dashboard()));
      } else {
        // Default to customer dashboard
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => Dashboard()));
      }
    } else {
      // User is not authenticated, navigate to auth screen
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => OnboardingScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  AppImages.sepeshaRedLogo,
                  width: 200,
                  height: 200,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
