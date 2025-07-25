import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sepesha_app/Driver/driver_home_screen.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/models/user_data.dart';
import 'package:sepesha_app/repositories/user_profile_repository.dart';
import 'package:sepesha_app/screens/auth/auth_screen.dart';
import 'package:sepesha_app/services/auth_services.dart';
import 'package:sepesha_app/services/preferences.dart';
import 'package:sepesha_app/services/session_manager.dart';

class DriverVerificationWaitingScreen extends StatefulWidget {
  const DriverVerificationWaitingScreen({super.key});

  @override
  State<DriverVerificationWaitingScreen> createState() =>
      _DriverVerificationWaitingScreenState();
}

class _DriverVerificationWaitingScreenState
    extends State<DriverVerificationWaitingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _checkTimer;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat(reverse: true);
    _startPeriodicCheck();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _checkTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicCheck() {
    // Check verification status every 30 seconds
    _checkTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkVerificationStatus();
    });
  }

  Future<void> _checkVerificationStatus() async {
    if (_isChecking) return;

    setState(() {
      _isChecking = true;
    });

    try {
      // Get current user data from preferences
      final userData = await Preferences.instance.userDataObject;
      if (userData != null && userData.isVerified == true) {
        // User is now verified, navigate to driver dashboard
        _checkTimer?.cancel();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainLayout()),
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking verification status: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  void _logout() {
    _checkTimer?.cancel();
    // Clear session data
    SessionManager.instance.clearSession();
    Preferences.instance.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Animated Icon
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColor.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.hourglass_empty,
                    size: 60,
                    color: AppColor.primary,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Verification in Progress',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'Thank you for registering as a driver!\n\nOur team is currently reviewing your documents and vehicle information. This process typically takes 24-48 hours.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Status indicator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.pending, color: Colors.orange, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status: Pending Verification',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'We\'ll notify you once approved',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Check Status Button
              SizedBox(
                width: double.infinity,
                child: ContinueButton(
                  onPressed: _isChecking ? () {} : _checkVerificationStatus,
                  text: _isChecking ? 'Checking...' : 'Check Status',
                  isLoading: _isChecking,
                ),
              ),

              const SizedBox(height: 16),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _logout,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColor.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, color: AppColor.primary),
                  ),
                ),
              ),

              const Spacer(),

              // Contact Support
              Text(
                'Need help? Contact our support team',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
