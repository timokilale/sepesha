import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:sepesha_app/screens/dashboard/dashboard.dart';
import 'package:sepesha_app/service/auth_services.dart';
import 'package:sepesha_app/services/session_manager.dart';

class OTPProvider with ChangeNotifier {
  int _resendTimer = 30;
  List<TextEditingController> _otpControllers = List.generate(
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
    _setLoading(true);

    try {
      final phone = SessionManager.instance.phone;
      await AuthServices.resendOtp(phoneNumber: phone, context: context);
    } catch (e) {
      print('Error1: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Update OTP digit at specific index
  void updateOTPDigit(int index, String value) {
    _errorMessage = ''; // Clear error when user types
    notifyListeners();

    if (value.isNotEmpty && !RegExp(r'^[0-9]$').hasMatch(value)) {
      _otpControllers[index].clear();
      return;
    }
  }

  // Verify the OTP
  Future<void> verifyOTP(
    BuildContext context,
    phoneNumber,
    String otpFromField,
  ) async {
    _isLoading = true;
    notifyListeners();

    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 4) {
      _errorMessage = 'Please enter a 4-digit OTP';
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (!RegExp(r'^[0-9]{4}$').hasMatch(otp)) {
      _errorMessage = 'OTP should contain only numbers';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final parsedOtp = int.parse(otp);
      await AuthServices.verifyOtp(
        phoneNumber: phoneNumber,
        otp: parsedOtp,
        context: context,
      );
    } catch (e, s) {
      // _errorMessage = e.toString();
      print('Error: $e at $s');
      _clearOTPFields();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear all OTP fields
  void _clearOTPFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
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
