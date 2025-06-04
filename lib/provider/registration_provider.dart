import 'package:flutter/material.dart';
import 'package:sepesha_app/models/driver_model.dart';
import 'package:sepesha_app/models/user_data.dart';
import 'package:sepesha_app/models/vehicle_model.dart';
import 'package:sepesha_app/screens/auth/otp_screen.dart';
import 'package:sepesha_app/services/auth_services.dart';
import 'package:sepesha_app/services/session_manager.dart';

class RegistrationProvider with ChangeNotifier {
  int _currentStep = 0;
  Driver _driver = Driver();
  Vehicle _vehicle = Vehicle();
  Map<String, dynamic> _documents = {};
  Map<String, bool> _documentCompletionStatus = {};

  int get currentStep => _currentStep;
  Driver get driver => _driver;
  Vehicle get vehicle => _vehicle;
  Map<String, dynamic> get documents => _documents;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  //user implementation
  Future<void> updateUser(UserData user, BuildContext context) async {
    _setLoading(true);
    print('User: $user');

    try {
      SessionManager.instance.setPhone(int.parse(user.phoneNumber));
      await AuthServices.registerUser(
        context: context,
        firstName: user.firstName,
        lastName: user.lastName,
        regionId: user.regionId,
        email: user.email,
        password: user.password,
        userType: 'customer',
        phone: user.phoneNumber,
        privacyChecked: true,
        passwordConfirmation: user.password,
        middleName: user.middleName,
        phoneCode: '255',
      );

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

  //end User implementation
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

  void markDocumentComplete(
    String key, {
    required dynamic file,
    String? idNumber,
    String? expiryDate,
  }) {
    _documents[key] = {
      'file': file,
      'idNumber': idNumber,
      'expiryDate': expiryDate,
    };
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
