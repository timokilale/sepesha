import '../Driver/model/user_model.dart';
import '../models/driver_model.dart';
import '../models/driver_document_model.dart';
import 'package:sepesha_app/models/vehicle_model.dart';

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
  Driver? _user;
  Vehicle? _vehicle;
  Map<String, dynamic> _documents = {};
  Map<String, bool> _documentCompletionStatus = {};
  List<DriverDocumentModel> _completedDocuments = [];




  void setUser(Driver user) {
    _user = user;
  }

  Driver? get user {
    if (_user == null) throw Exception("user is NULL");
    return _user;
  }

  void setVehicle(Vehicle vehicle) {
    _vehicle = vehicle;
  }

  Vehicle? get vehicle {
    if (_vehicle == null) throw Exception("vehicle is NULL");
    return _vehicle;
  }

  void addDocument(String key, dynamic document) {
    _documents[key] = document;
  }

  void markDocumentComplete(String key, {
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
