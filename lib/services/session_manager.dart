import 'package:flutter/material.dart';
import 'package:sepesha_app/models/user_data.dart';
import 'package:sepesha_app/services/preferences.dart';

import '../models/driver_document_model.dart';
import 'package:sepesha_app/models/vehicle_model.dart';
// Add these imports at the top if not already present
import 'package:sepesha_app/models/payment_method.dart';

class SessionManager {
  SessionManager._();
  static final SessionManager _instance = SessionManager._();
  static SessionManager get instance => _instance;

  int? _phone;
  String? _firstname;
  String? _lastname;
  String? _middlename;
  String? _email;
  String? _distanceCovered;
  String? _userType;
  UserData? _user;
  Vehicle? _vehicle;
  Map<String, dynamic> _documents = {};
  Map<String, bool> _documentCompletionStatus = {};
  List<DriverDocumentModel> _completedDocuments = [];

  // Add these private fields to the SessionManager class
  String? _preferredPaymentMethod;
  WalletBalance? _walletBalance;

  // Add these getter methods
  String? get preferredPaymentMethod => _preferredPaymentMethod;
  WalletBalance? get walletBalance => _walletBalance;
  String? get userType => _userType;

  // Add these setter methods
  void setPreferredPaymentMethod(String? method) {
    _preferredPaymentMethod = method;
  }

  void setWalletBalance(WalletBalance? balance) {
    _walletBalance = balance;
  }

  void setUserType(String? userType) {
    _userType = userType;
  }

  // Clear all session data
  void clearSession() {
    _phone = null;
    _firstname = null;
    _lastname = null;
    _middlename = null;
    _email = null;
    _distanceCovered = null;
    _userType = null;
    _user = null;
    _vehicle = null;
    _documents.clear();
    _documentCompletionStatus.clear();
    _completedDocuments.clear();
    _preferredPaymentMethod = null;
    _walletBalance = null;
  }

  /// Restore session data from preferences
  Future<void> restoreSession() async {
    try {
      _firstname = await Preferences.instance.firstName;
      _lastname = await Preferences.instance.lastName;
      _email = await Preferences.instance.email;
      final phoneString = await Preferences.instance.phoneNumber;
      if (phoneString != null) {
        _phone = int.tryParse(phoneString);
      }

      // Restore user type from preferences - try both keys for compatibility
      _userType = await Preferences.instance.selectedUserType ??
                  await Preferences.instance.getString('role') ??
                  'customer';

      // Restore user data object if available
      final userData = await Preferences.instance.userDataObject;
      if (userData != null) {
        _user = userData;
      }

      // Restore other session data as needed
      debugPrint('Session restored successfully');
      debugPrint('Restored user type: $_userType');
      debugPrint('Restored user data: ${_user != null ? 'Yes' : 'No'}');
    } catch (e) {
      debugPrint('Error restoring session: $e');
    }
  }

  void setUser(UserData user) {
    _user = user;
  }

  UserData? get user {
    return _user;
  }

  void setVehicle(Vehicle vehicle) {
    _vehicle = vehicle;
  }

  Vehicle? get vehicle {
    return _vehicle;
  }

  void addDocument(String key, dynamic document) {
    _documents[key] = document;
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
  }

  bool isDocumentComplete(String key) {
    // First check explicit completion status
    if (_documentCompletionStatus.containsKey(key)) {
      return _documentCompletionStatus[key]!;
    }

    // Then check if document exists with all required fields
    if (!_documents.containsKey(key)) {
      return false;
    }

    final doc = _documents[key];
    if (doc == null) return false;

    // Must have a file
    if (doc['file'] == null) return false;

    return true;
  }

  Map<String, dynamic> get documents => _documents;

  List<DriverDocumentModel> get completedDocuments => _completedDocuments;

  void addCompletedDocument(DriverDocumentModel document) {
    _completedDocuments.add(document);
  }

  void setCompletedDocuments(List<DriverDocumentModel> documents) {
    _completedDocuments = documents;
  }

  void clearDocuments() {
    _documents = {};
    _documentCompletionStatus = {};
    _completedDocuments = [];
  }

  void setDistanceCovered(String distance) {
    print('Distance obtained and to be saved is $distance');
    _distanceCovered = distance;
  }

  String get distanceCovered {
    if (_distanceCovered == null) throw Exception("distance is NULL");
    return _distanceCovered!;
  }

  int get phone {
    if (_phone == null) throw Exception("phone is NULL");
    return _phone!;
  }

  void setPhone(int phone) {
    _phone = phone;
    // Also store as string in preferences for consistency
    Preferences.instance.save(PrefKeys.phoneNumber, phone.toString());
  }

  void setPhoneFromString(String phoneString) {
    final phoneInt = int.tryParse(phoneString);
    if (phoneInt != null) {
      _phone = phoneInt;
      // Store as string in preferences
      Preferences.instance.save(PrefKeys.phoneNumber, phoneString);
    }
  }

  String get getFirstname {
    if (_firstname == null) throw Exception("firstname is NULL");
    return _firstname!;
  }

  void setFirstname(String name) {
    _firstname = name;
  }

  String get getLastname {
    if (_lastname == null) throw Exception("lastname is NULL");
    return _lastname!;
  }

  void setLastname(String name) {
    _lastname = name;
  }

  String get getMiddlename {
    if (_middlename == null) throw Exception("middlename is NULL");
    return _middlename!;
  }

  void setMiddlename(String name) {
    _middlename = name;
  }

  String get getEmail {
    if (_email == null) throw Exception("email is NULL");
    return _email!;
  }

  void setEmail(String emailAddress) {
    _email = emailAddress;
  }
}
