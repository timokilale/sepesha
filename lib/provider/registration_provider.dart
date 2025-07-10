import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:sepesha_app/models/driver_document_model.dart';
import 'package:archive/archive.dart';
import 'package:sepesha_app/models/user_data.dart';
import 'package:sepesha_app/models/vehicle_model.dart';
import 'package:sepesha_app/screens/auth/otp_screen.dart';
import 'package:sepesha_app/services/auth_services.dart';
import 'package:sepesha_app/services/session_manager.dart';

class RegistrationProvider with ChangeNotifier {
  int _currentStep = 0;
  UserData? _driver;
  Vehicle _vehicle = Vehicle();
  Map<String, dynamic> _documents = {};
  Map<String, bool> _documentCompletionStatus = {};
  List<DriverDocumentModel> _completedDocuments = [];
  bool _isLoading = false;

  int get currentStep => _currentStep;
  UserData? get driver => _driver;
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



  Future<void> registerDriver(UserData user, Vehicle vehicle, List<DriverDocumentModel> driverDocuments, BuildContext context) async {
    _setLoading(true);
    print('User: $user');

    try {
      SessionManager.instance.setPhone(int.tryParse(user.phoneNumber)!);

      // Ensure profilePhoto is not null
      if (user.profilePhoto == null) {
        throw Exception("Profile photo is required");
      }

      // Create a File from the profilePhoto
      final profilePhoto = user.profilePhoto!;

      // Create a zip file from documents if any exist
      File? documentsZipFile;
      if (driverDocuments.isNotEmpty && driverDocuments.any((doc) => doc.document != null)) {
        documentsZipFile = await _createDocumentsZip(driverDocuments);
      } else {
        // Create an empty zip file if no documents are available
        final tempDir = await getTemporaryDirectory();
        final emptyZipFile = File('${tempDir.path}/empty_documents_${DateTime.now().millisecondsSinceEpoch}.zip');
        final archive = Archive();
        final zipData = ZipEncoder().encode(archive);
        await emptyZipFile.writeAsBytes(zipData, flush: true);
        documentsZipFile = emptyZipFile;
      }

      await AuthServices.registerDriver(
        context: context,
        firstName: user.firstName,
        lastName: user.lastName,
        regionId: user.regionId,
        email: user.email,
        password: user.password,
        userType: 'driver',
        phone: user.phoneNumber,
        privacyChecked: true,
        passwordConfirmation: user.password,
        middleName: user.middleName,
        phoneCode: '255',
        profilePhoto: profilePhoto,
        licenceExpiry: '123',
        licenceNumber: '123',
        attachment: documentsZipFile
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OTPScreen()),
      );
    } catch (e) {
      _setLoading(false);
      print('Error registering driver: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register: ${e.toString()}')),
      );
    }
  }

  Future<File> _createDocumentsZip(List<DriverDocumentModel> documents) async {
    final archive = Archive();

    // Add all valid documents to the archive
    for (final doc in documents) {
      if (doc.document != null) {
        try {
          final file = doc.document!;
          final fileData = await file.readAsBytes();
          final fileName = '${doc.key}_${DateTime.now().millisecondsSinceEpoch}${_getFileExtension(file.path)}';

          archive.addFile(ArchiveFile(
            fileName,
            fileData.length,
            fileData,
          ));
        } catch (e) {
          print('Error adding document ${doc.key} to zip: $e');
        }
      }
    }

    // Check if we actually added any files
    if (archive.files.isEmpty) {
      throw Exception('No valid documents found to include in zip');
    }

    // Create the zip file in temporary directory
    final tempDir = await getTemporaryDirectory();
    final zipFile = File('${tempDir.path}/documents_${DateTime.now().millisecondsSinceEpoch}.zip');

    // Encode and write the zip file
    final zipData = ZipEncoder().encode(archive);

    await zipFile.writeAsBytes(zipData, flush: true);
    return zipFile;
  }

  String _getFileExtension(String path) {
    final extension = path.split('.').last;
    return extension == path ? '' : '.$extension'; // Handle cases where there's no extension
  }


  Future<void> updateVendor(UserData user, BuildContext context) async {
    _setLoading(true);
    print('User: $user');

    try {
      SessionManager.instance.setPhone(int.parse(user.phoneNumber));

      final businessDescription = "${user.businessName}\n${user.businessType}\n${user.businessDescription}";
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
          businessDescription: businessDescription


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

  void setDriver(UserData driver) {
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
    // First check if document exists in SessionManager
    final documents = SessionManager.instance.documents;
    if (documents.containsKey(key)) {
      final doc = documents[key];
      if (doc is Map && doc['isComplete'] == true) {
        return true;
      }
    }

    // Then check explicit completion status in provider
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
    // Create a new UserData object with required fields
    final newDriver = UserData(
      firstName: "",
      lastName: "",
      phoneNumber: "",
      email: "",
      password: "",
      userType: "driver",
      regionId: 0
    );
    _driver = newDriver;
    _vehicle = Vehicle();
    _documents = {};
    _documentCompletionStatus = {};
    _completedDocuments = [];

    // Reset data in SessionManager
    SessionManager.instance.setUser(newDriver);
    SessionManager.instance.setVehicle(_vehicle);
    SessionManager.instance.clearDocuments();

    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
