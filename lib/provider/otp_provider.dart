import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sepesha_app/services/auth_services.dart';
import 'package:sepesha_app/services/session_manager.dart';

class OTPProvider with ChangeNotifier {
  int _resendTimer = 30;
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  bool _isLoading = false;
  String _errorMessage = '';
  Timer? _timer;

  // Getters
  int get resendTimer => _resendTimer;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<TextEditingController> get otpControllers => _otpControllers;

  // Start the resend timer
  void startTimer() {
    _resendTimer = 30;
    _timer?.cancel(); // Cancel any existing timer

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        _resendTimer--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> resendOtp(BuildContext context) async {
    print('=== RESEND OTP STARTED ===');
    _setLoading(true);
    _errorMessage = ''; // Clear previous errors

    try {
      int? phone;
      try {
        phone = SessionManager.instance.phone;
      } catch (e) {
        print('Error getting phone from session: $e');
        _errorMessage = 'Phone number not found. Please try logging in again.';
        notifyListeners();
        return;
      }

      final userType = SessionManager.instance.userType ?? 'customer';
      print('Resending OTP for phone: $phone, userType: $userType');

      await AuthServices.resendOtp(
        phoneNumber: phone,
        context: context,
        userType: userType,
      );

      print('Resend OTP successful');
    } catch (e) {
      print('Resend OTP error: $e');

      // Set user-friendly error message
      if (e.toString().contains('404')) {
        _errorMessage = 'User not found. Please register first.';
      } else if (e.toString().contains('network') ||
                 e.toString().contains('connection')) {
        _errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('too many requests') ||
                 e.toString().contains('rate limit')) {
        _errorMessage = 'Too many requests. Please wait before trying again.';
      } else {
        _errorMessage = 'Failed to resend OTP. Please try again.';
      }

      notifyListeners(); // Notify to show error message
    } finally {
      _setLoading(false);
      print('=== RESEND OTP COMPLETED ===');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Update OTP digit at specific index
  void updateOTPDigit(int index, String value) {
    _errorMessage = ''; // Clear error when user types

    // Handle paste operation (when multiple digits are pasted)
    if (value.length > 1) {
      _handlePastedOTP(value);
      return;
    }

    // Only allow single digits
    if (value.isNotEmpty && !RegExp(r'^[0-9]$').hasMatch(value)) {
      _otpControllers[index].clear();
      return;
    }

    notifyListeners();
  }

  // Handle pasted OTP code
  void _handlePastedOTP(String pastedText) {
    // Extract only digits from pasted text
    final digits = pastedText.replaceAll(RegExp(r'[^0-9]'), '');

    // Clear all fields first
    _clearOTPFields();

    // Fill fields with pasted digits (up to 4)
    for (int i = 0; i < digits.length && i < 4; i++) {
      _otpControllers[i].text = digits[i];
    }

    notifyListeners();
  }

  // Verify the OTP
  Future<void> verifyOTP(
    BuildContext context,
    phoneNumber, {
    String? userType,
  }) async {
    print('=== OTP VERIFICATION STARTED ===');
    print('Phone: $phoneNumber');
    print('User Type: $userType');

    _isLoading = true;
    _errorMessage = ''; // Clear previous errors
    notifyListeners();

    final otp = _otpControllers.map((c) => c.text).join();
    print('OTP entered: $otp');

    if (otp.length != 4) {
      _errorMessage = 'Please enter a 4-digit OTP';
      _isLoading = false;
      notifyListeners();
      print('Error: OTP length validation failed');
      return;
    }

    if (!RegExp(r'^[0-9]{4}$').hasMatch(otp)) {
      _errorMessage = 'OTP should contain only numbers';
      _isLoading = false;
      notifyListeners();
      print('Error: OTP format validation failed');
      return;
    }

    // Validate phone number
    if (phoneNumber == null) {
      _errorMessage = 'Phone number not found. Please try logging in again.';
      _isLoading = false;
      notifyListeners();
      print('Error: Phone number is null');
      return;
    }

    try {
      final parsedOtp = int.parse(otp);
      print('Parsed OTP: $parsedOtp');
      print('Calling AuthServices.verifyOtp...');

      // ENABLE ACTUAL VERIFICATION
      await AuthServices.verifyOtp(
        phoneNumber: phoneNumber,
        otp: parsedOtp,
        context: context,
        userType: userType,
      );

      print('OTP verification successful!');
      // Navigation is now handled in AuthServices.verifyOtp based on user type
    } catch (e) {
      print('OTP verification error: $e');
      print('Error type: ${e.runtimeType}');

      // Provide user-friendly error messages
      if (e.toString().contains('Invalid OTP') ||
          e.toString().contains('incorrect') ||
          e.toString().contains('wrong')) {
        _errorMessage = 'Invalid OTP. Please check and try again.';
      } else if (e.toString().contains('expired') ||
                 e.toString().contains('timeout')) {
        _errorMessage = 'OTP has expired. Please request a new one.';
      } else if (e.toString().contains('network') ||
                 e.toString().contains('connection') ||
                 e.toString().contains('internet')) {
        _errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('404')) {
        _errorMessage = 'User not found. Please register first.';
      } else if (e.toString().contains('422')) {
        _errorMessage = 'Invalid request. Please try again.';
      } else if (e.toString().contains('500')) {
        _errorMessage = 'Server error. Please try again later.';
      } else {
        _errorMessage = 'Verification failed. Please try again.';
      }

      _clearOTPFields();
    } finally {
      _isLoading = false;
      notifyListeners();
      print('=== OTP VERIFICATION COMPLETED ===');
    }
  }

  // Clear all OTP fields (public method)
  void clearOTPFields() {
    _clearOTPFields();
  }

  // Clear all OTP fields (private method)
  void _clearOTPFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _errorMessage = '';
    notifyListeners();
  }

  // Resend OTP
  Future<void> resendOTP() async {
    if (_resendTimer > 0) return;

    _clearOTPFields();
    _errorMessage = '';
    startTimer();

    // Add your resend OTP API call here
    // await _sendOTPToUser();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
