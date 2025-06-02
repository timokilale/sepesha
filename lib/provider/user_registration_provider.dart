import 'package:flutter/material.dart';
import 'package:sepesha_app/models/driver_model.dart';
import 'package:sepesha_app/models/vehicle_model.dart';
import 'package:sepesha_app/screens/auth/otp_screen.dart';
import 'package:sepesha_app/service/auth_services.dart';
import 'package:sepesha_app/services/session_manager.dart';

class UserRegistrationProvider with ChangeNotifier {
  int _currentStep = 0;
  Driver _driver = Driver();
  Vehicle _vehicle = Vehicle();
  Map<String, dynamic> _documents = {};
  Map<String, bool> _documentCompletionStatus = {};

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int get currentStep => _currentStep;
  Driver get driver => _driver;
  Vehicle get vehicle => _vehicle;
  Map<String, dynamic> get documents => _documents;

  Future<void> userLogin(BuildContext context, String phoneNumber) async {
    _setLoading(true);

    try {
      phoneNumber = phoneNumber.replaceFirst('+255', '');
      print(phoneNumber);
      final phone = int.parse(phoneNumber);
      SessionManager.instance.setPhone(phone);
      await AuthServices.login(phoneNumber: phone, context: context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OTPScreen()),
      );
    } catch (e) {
      _setLoading(false);
      print('Error1: $e');
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }



  void setCurrentStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void updateDriver(Driver driver) {
    _driver = driver;
    notifyListeners();
  }

  void updateVehicle(Vehicle vehicle) {
    _vehicle = vehicle;
    notifyListeners();
  }

  void addDocument(String key, dynamic document) {
    _documents[key] = document;
    notifyListeners();
  }

  void markDocumentComplete(String key) {
    _documentCompletionStatus[key] = true;
    notifyListeners();
  }

  bool isDocumentComplete(String key) {
    return _documentCompletionStatus[key] ?? false;
  }

  bool areAllDocumentsComplete(List<String> requiredKeys) {
    for (var key in requiredKeys) {
      if (!(_documentCompletionStatus[key] ?? false)) {
        return false;
      }
    }
    return true;
  }

  void completeRegistration() {
    // Save all data and complete registration
    // You would typically call an API here
    _currentStep = 0;
    _driver = Driver();
    _vehicle = Vehicle();
    _documents = {};
    _documentCompletionStatus = {};
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
