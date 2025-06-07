// import 'dart:io';

// class UserData {
//   final String? firstName;
//   final String? middleName;
//   final String? lastName;
//   final String? phonecode;
//   final String? phoneNumber;
//   final String? email;
//   final File? profilePhoto;
//   final String? drivingLicence;
//   final String? latraStricker;
//   final String? registrationCard;
//   final String? plateNumber;
//   final String? userType;
//   final int? regionId;
//   final String? referralCode;
//   final String? password;
//   final int? isVerified;
//   final String? uid;
//   final String? otp;
//   final String? otpExpiresAt;

//   UserData({
//     this.firstName,
//     this.middleName,
//     this.lastName,
//     this.phonecode,
//     this.phoneNumber,
//     this.email,
//     this.profilePhoto,
//     this.drivingLicence,
//     this.latraStricker,
//     this.registrationCard,
//     this.plateNumber,
//     this.userType,
//     this.isVerified,
//     this.uid,
//     this.otp,
//     this.otpExpiresAt,
//     this.regionId,
//     this.referralCode,
//     this.password,
//   });

//   factory UserData.fromJson(Map<String, dynamic> json) {
//     return UserData(
//       firstName: json['first_name'] as String?,
//       middleName: json['middle_name'] as String?,
//       lastName: json['last_name'] as String?,
//       phonecode: json['phonecode'] as String?,
//       phoneNumber: json['phone_number'] as String?,
//       email: json['email'] as String?,
//       profilePhoto: json['profile_photo'] as File?,
//       drivingLicence: json['driving_licence'] as String?,
//       latraStricker: json['latra_stricker'] as String?,
//       registrationCard: json['registration_card'] as String?,
//       plateNumber: json['plate_number'] as String?,
//       userType: json['user_type'] as String?,
//       isVerified: json['is_verified'] as int?,
//       uid: json['uid'] as String?,
//       otp: json['otp'] as String?,
//       otpExpiresAt: json['otp_expires_at'] as String?,
//       regionId: json['region_id'] as int?,
//       referralCode: json['referral_code'] as String?,
//       // password: json['password'] as String?,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'first_name': firstName,
//       'middle_name': middleName,
//       'last_name': lastName,
//       'phonecode': phonecode,
//       'phone_number': phoneNumber,
//       'email': email,
//       'profile_photo': profilePhoto,
//       'driving_licence': drivingLicence,
//       'latra_stricker': latraStricker,
//       'registration_card': registrationCard,
//       'plate_number': plateNumber,
//       'user_type': userType,
//       'is_verified': isVerified,
//       'uid': uid,
//       'otp': otp,
//       'otp_expires_at': otpExpiresAt,
//     };
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class UserData {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final String password;
  final String userType;
  final int regionId;
  final String? middleName;
  final String? referralCode;
  final File? profilePhoto;
  final String? drivingLicence;
  final String? latraSticker;
  final String? registrationCard;
  final String? plateNumber;
  final String? licenceExpiry;
  final String? businessDescription;
  final String? businessName;
  final String? businessType;

  const UserData({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.userType,
    required this.regionId,
    this.middleName,
    this.referralCode,
    this.profilePhoto,
    this.drivingLicence,
    this.latraSticker,
    this.registrationCard,
    this.plateNumber,
    this.licenceExpiry,
    this.businessDescription,
    this.businessName,
    this.businessType
  });

  // Convert to API-ready JSON
  Future<Map<String, dynamic>> toApiJson() async {
    final json = {
      'first_name': firstName,
      'last_name': lastName,
      'phonecode': '255', // Fixed for Tanzania
      'phone': phoneNumber,
      'email': email,
      'password': password,
      'password_confirmation': password,
      'user_type': userType,
      'region_id': regionId,
      'privacy_checked': '1',
      if (middleName != null) 'middle_name': middleName,
      if (referralCode != null) 'referal_code': referralCode,
      if (drivingLicence != null) 'driving_licence': drivingLicence,
      if (latraSticker != null) 'latra_sticker': latraSticker,
      if (registrationCard != null) 'registration_card': registrationCard,
      if (plateNumber != null) 'plate_number': plateNumber,
      if (licenceExpiry != null) 'licence_expiry': licenceExpiry,
      if (businessDescription != null)
        'business_description': businessDescription,
    };

    // Handle file uploads if present
    if (profilePhoto != null) {
      final photoBytes = await profilePhoto!.readAsBytes();
      json['profile_photo'] = base64Encode(photoBytes);
    }

    return json;
  }

  // Factory constructor from JSON
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      userType: json['user_type'] as String,
      regionId: json['region_id'] as int,
      middleName: json['middle_name'] as String?,
      referralCode: json['referral_code'] as String?,
      drivingLicence: json['driving_licence'] as String?,
      latraSticker: json['latra_sticker'] as String?,
      registrationCard: json['registration_card'] as String?,
      plateNumber: json['plate_number'] as String?,
      licenceExpiry: json['licence_expiry'] as String?,
      businessDescription: json['business_description'] as String?,
    );
  }

  // Copy with method for immutability
  UserData copyWith({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
    String? password,
    String? userType,
    int? regionId,
    String? middleName,
    String? referralCode,
    File? profilePhoto,
    String? drivingLicence,
    String? latraSticker,
    String? registrationCard,
    String? plateNumber,
    String? licenceExpiry,
    String? businessDescription,
  }) {
    return UserData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      password: password ?? this.password,
      userType: userType ?? this.userType,
      regionId: regionId ?? this.regionId,
      middleName: middleName ?? this.middleName,
      referralCode: referralCode ?? this.referralCode,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      drivingLicence: drivingLicence ?? this.drivingLicence,
      latraSticker: latraSticker ?? this.latraSticker,
      registrationCard: registrationCard ?? this.registrationCard,
      plateNumber: plateNumber ?? this.plateNumber,
      licenceExpiry: licenceExpiry ?? this.licenceExpiry,
      businessDescription: businessDescription ?? this.businessDescription,
    );
  }
}
