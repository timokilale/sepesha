import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sepesha_app/Utilities/app_images.dart';
import 'package:sepesha_app/screens/auth/auth_screen.dart';
import 'package:sepesha_app/screens/auth/onboarding_screen.dart';
import 'package:sepesha_app/screens/dashboard/dashboard.dart';
import 'package:sepesha_app/Driver/driver_home_screen.dart';
import 'package:sepesha_app/screens/auth/driver_verification_waiting_screen.dart';
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
    // Restore session data first
    await SessionManager.instance.restoreSession();

    // Use TokenManager to check if user is authenticated
    final isAuthenticated = await TokenManager.instance.isAuthenticated();

    if (isAuthenticated) {
      // User is authenticated, check user type and navigate accordingly
      final userType =
          await Preferences.instance.fetch<String?>('selected_user_type') ??
          await Preferences.instance.fetch<String?>('user_type') ??
          'customer';

      // Store in session for current app session
      SessionManager.instance.setUserType(userType);

      // Debug: Print what we found
      debugPrint('User authenticated: $isAuthenticated');
      debugPrint('User type: $userType');

      if (userType == 'driver') {
        // Check if driver is verified
        final userData = await Preferences.instance.userDataObject;
        final isVerified = userData?.isVerified ?? false;

        if (isVerified) {
          // Drivers go to MainLayout (which contains DashboardScreen)
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainLayout()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const DriverVerificationWaitingScreen(),
            ),
          );
        }
      } else {
        // Vendors and customers go to Dashboard
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const Dashboard()));
      }
    } else {
      // User not authenticated, show onboarding or auth
      final hasSeenOnboarding =
          await Preferences.instance.fetch<bool?>('has_seen_onboarding') ??
          false;

      if (hasSeenOnboarding) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
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
