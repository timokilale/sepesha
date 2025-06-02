// models/driver_data.dart
import 'dart:io';

class DriverData {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String licenseNumber;
  final String vehicleModel;
  final String licensePlate;
  final File? profileImage;
  final File? licenseImage;
  final File? vehicleImage;

  DriverData({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.licenseNumber,
    required this.vehicleModel,
    required this.licensePlate,
    this.profileImage,
    this.licenseImage,
    this.vehicleImage,
  });
}
