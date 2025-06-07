import 'dart:io';

class Driver {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? city;
  final String? licenseNumber;
  final String? licenseExpiry;
  final String? password;
  final String? userType;
  final File? profileImage;

  Driver({
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.city,
    this.licenseNumber,
    this.licenseExpiry,
    this.password,
    this.userType,
    this.profileImage,
  });
}