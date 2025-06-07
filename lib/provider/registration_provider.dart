import 'package:flutter/material.dart';
import 'package:sepesha_app/models/driver_document_model.dart';
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
  List<DriverDocumentModel> _completedDocuments = [];
  bool _isLoading = false;

  int get currentStep => _currentStep;
  Driver get driver => _driver;
  Vehicle get vehicle => _vehicle;
  Map<String, dynamic> get documents => _documents;
  List<DriverDocumentModel> get completedDocuments => _completedDocuments;
  bool get isLoading => _isLoading;

  // User implementation
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
          profilePhoto: user.profilePhoto

      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OTPScreen()),
      );
    } catch (e) {
      _setLoading(false);
      print('Error1: $e');
    }
  }






  Future<void> updateVendor(UserData user, BuildContext context) async {
    _setLoading(true);
    print('User: $user');

    try {
      SessionManager.instance.setPhone(int.parse(user.phoneNumber));

      final _businessDescription = "${user.businessName}\n${user.businessType}\n${user.businessDescription}";
      await AuthServices.registerVendor(

          context: context,
          firstName: user.firstName,
          lastName: user.lastName,
          regionId: user.regionId,
          email: user.email,
          password: user.password,
          userType: user.userType,
          phone: user.phoneNumber,
          privacyChecked: true,
          passwordConfirmation: user.password,
          middleName: user.middleName,
          phoneCode: '255',
          profilePhoto: user.profilePhoto,
          businessDescription: _businessDescription


      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OTPScreen()),
      );
    } catch (e) {
      _setLoading(false);
      print('Error1: $e');
    }
  }

  void setCurrentStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void updateDriver(Driver driver) {
    _driver = driver;
    SessionManager.instance.setUser(driver);
    notifyListeners();
  }

  void updateVehicle(Vehicle vehicle) {
    _vehicle = vehicle;
    SessionManager.instance.setVehicle(vehicle);
    notifyListeners();
  }

  void addDocument(String key, dynamic document) {
    _documents[key] = document;
    SessionManager.instance.addDocument(key, document);
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
      'isComplete': true,
    };
    _documentCompletionStatus[key] = true;

    // Create a DriverDocumentModel and add it to the list
    final document = DriverDocumentModel(
      key: key,
      document_id: idNumber,
      expire_date: expiryDate,
      document: file,
    );
    _completedDocuments.add(document);

    // Save to SessionManager
    SessionManager.instance.markDocumentComplete(
      key,
      file: file,
      idNumber: idNumber,
      expiryDate: expiryDate,
    );
    SessionManager.instance.addCompletedDocument(document);

    notifyListeners();
  }

  bool isDocumentComplete(String key) {
    // First check explicit completion status
    final documents = SessionManager.instance.documents;
    if (documents.containsKey(key) && documents[key]['isComplete'] == true) {
    if (_documentCompletionStatus.containsKey(key) ){
    return _documentCompletionStatus[key]!;
    }

    // Then check if document exists with all required fields
    if (!_documents.containsKey(key) ){
      return false;
    }

    final doc = _documents[key];
    if (doc == null) return false;

    // Must have a file
    if (doc['file'] == null) return false;

    return true;
  }

  bool areAllDocumentsComplete(List<String> requiredKeys) {
    for (var key in requiredKeys) {
      if (!isDocumentComplete(key)) {
        return false;
      }
    }
    return true;
  }

  void completeRegistration() {
    // Save the list of completed documents to SessionManager before resetting
    SessionManager.instance.setCompletedDocuments(_completedDocuments);

    // Reset all data after completion
    _currentStep = 0;
    _driver = Driver();
    _vehicle = Vehicle();
    _documents = {};
    _documentCompletionStatus = {};
    _completedDocuments = [];

    // Reset data in SessionManager
    SessionManager.instance.setUser(_driver);
    SessionManager.instance.setVehicle(_vehicle);
    SessionManager.instance.clearDocuments();

    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
