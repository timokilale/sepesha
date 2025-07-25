import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:sepesha_app/Driver/driver_home_screen.dart';
import 'package:sepesha_app/screens/auth/auth_screen.dart';
import 'package:sepesha_app/screens/dashboard/dashboard.dart';
import 'package:sepesha_app/services/preferences.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import 'package:sepesha_app/services/session_manager.dart';
import 'package:sepesha_app/models/payment_method.dart';
import 'package:sepesha_app/models/user_data.dart';
import 'package:sepesha_app/Driver/dasboard/driver_dashboard.dart';
import 'package:sepesha_app/screens/auth/driver_verification_waiting_screen.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class AuthServices {
  AuthServices._();
  static final String apiBaseUrl = dotenv.env['BASE_URL']!;

  static Future<dynamic> registerUser({
    required BuildContext context,
    required String firstName,
    String? middleName,
    required String lastName,
    required String email,
    required String phone,
    required String phoneCode,
    required int regionId,
    required String userType,
    String? businessDescription,
    required String password,
    required String passwordConfirmation,
    required bool privacyChecked,
    String? licenceNumber,
    String? licenceExpiry,
    File? profilePhoto,
    File? attachment,
  }) async {
    final uri = Uri.parse('$apiBaseUrl/register');
    final request = http.MultipartRequest('POST', uri);

    request.fields.addAll({
      'first_name': firstName,
      'middle_name': middleName ?? '',
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'phonecode': phoneCode,
      'region_id': regionId.toString(),
      'user_type': userType,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'privacy_checked': '1',
      'referal_code': '',
    });

    if (profilePhoto != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_photo',
          profilePhoto.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    if (attachment != null) {
      final mimeType = lookupMimeType(attachment.path)?.split('/');
      request.files.add(
        await http.MultipartFile.fromPath(
          'attachment',
          attachment.path,
          contentType:
              mimeType != null
                  ? MediaType(mimeType[0], mimeType[1])
                  : MediaType('application', 'octet-stream'),
        ),
      );
    }

    print('=== REGISTER USER REQUEST ===');
    print('URL: ${uri.toString()}');
    print('Fields: ${request.fields}');
    print('Files: ${request.files.map((f) => '${f.field}: ${f.filename}')}');
    print('============================');

    final response = await request.send();

    print('=== REGISTER USER RESPONSE ===');
    print('Status Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');

    if (response.statusCode == 201) {
      final respStr = await response.stream.bytesToString();
      print('Response Body: $respStr');
      print('==============================');
      final data = jsonDecode(respStr);
      return data;
    } else {
      final respStr = await response.stream.bytesToString();
      print('Error: ${response.statusCode}, $respStr');
      final json = jsonDecode(respStr);
      final message = json['message'];
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      throw message;
    }
  }

  static Future<dynamic> registerDriver({
    required BuildContext context,
    required String firstName,
    String? middleName,
    required String lastName,
    required String email,
    required String phone,
    required String phoneCode,
    required int regionId,
    required String userType,
    required String password,
    required String passwordConfirmation,
    required bool privacyChecked,
    required String licenceNumber,
    required String licenceExpiry,
    required File profilePhoto,
    required File attachment,
  }) async {
    final uri = Uri.parse('$apiBaseUrl/register');
    final request = http.MultipartRequest('POST', uri);

    request.fields.addAll({
      'first_name': firstName,
      'middle_name': middleName ?? '',
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'phonecode': phoneCode,
      'region_id': regionId.toString(),
      'user_type': userType,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'privacy_checked': '1',
      'referal_code': '',
      'licence_number': licenceNumber,
      'licence_expiry': licenceExpiry ?? '',
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'profile_photo',
        profilePhoto.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final mimeType = lookupMimeType(attachment.path)?.split('/');
    request.files.add(
      await http.MultipartFile.fromPath(
        'attachment',
        attachment.path,
        contentType:
            mimeType != null
                ? MediaType(mimeType[0], mimeType[1])
                : MediaType('application', 'octet-stream'),
      ),
    );

    print('=== REGISTER DRIVER REQUEST ===');
    print('URL: ${uri.toString()}');
    print('Fields: ${request.fields}');
    print('Files: ${request.files.map((f) => '${f.field}: ${f.filename}')}');
    print('============================');

    final response = await request.send();

    print('=== REGISTER DRIVER RESPONSE ===');
    print('Status Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');

    if (response.statusCode == 201) {
      final respStr = await response.stream.bytesToString();
      print('Response Body: $respStr');
      final data = jsonDecode(respStr);
      return data;
    } else {
      final respStr = await response.stream.bytesToString();
      print('Error: ${response.statusCode}, $respStr');
      final json = jsonDecode(respStr);
      final message = json['message'];
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      throw message;
    }
  }

  static Future<dynamic> registerVendor({
    required BuildContext context,
    required String firstName,
    String? middleName,
    required String lastName,
    required String email,
    required String phone,
    required String phoneCode,
    required int regionId,
    required String userType,
    required String businessDescription,
    required String password,
    required String passwordConfirmation,
    required bool privacyChecked,
    String? licenceNumber,
    String? licenceExpiry,
    File? profilePhoto,
    File? attachment,
  }) async {
    final uri = Uri.parse('$apiBaseUrl/register');
    final request = http.MultipartRequest('POST', uri);

    request.fields.addAll({
      'first_name': firstName,
      'middle_name': middleName ?? '',
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'phonecode': phoneCode,
      'region_id': regionId.toString(),
      'user_type': userType,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'privacy_checked': '1',
      'referal_code': '',
      'business_description': businessDescription,
    });

    if (profilePhoto != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_photo',
          profilePhoto.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    if (attachment != null) {
      final mimeType = lookupMimeType(attachment.path)?.split('/');
      request.files.add(
        await http.MultipartFile.fromPath(
          'attachment',
          attachment.path,
          contentType:
              mimeType != null
                  ? MediaType(mimeType[0], mimeType[1])
                  : MediaType('application', 'octet-stream'),
        ),
      );
    }

    print('=== REGISTER VENDOR REQUEST ===');
    print('URL: ${uri.toString()}');
    print('Fields: ${request.fields}');
    print('Files: ${request.files.map((f) => '${f.field}: ${f.filename}')}');
    print('============================');

    final response = await request.send();

    print('=== REGISTER VENDOR RESPONSE ===');
    print('Status Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');

    if (response.statusCode == 201) {
      final respStr = await response.stream.bytesToString();
      print('Response Body: $respStr');
      final data = jsonDecode(respStr);
      return data;
    } else {
      final respStr = await response.stream.bytesToString();
      print('Error: ${response.statusCode}, $respStr');
      final json = jsonDecode(respStr);
      final message = json['message'];
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      throw message;
    }
  }

  static Future<void> login({
    required int phoneNumber,
    required BuildContext context,
    String? userType,
  }) async {
    final url = Uri.parse('$apiBaseUrl/login');
    final body = {"phone": phoneNumber, "user_type": userType ?? "customer"};

    print('=== LOGIN REQUEST ===');
    print('URL: ${url.toString()}');
    print('Headers: ${{'Content-Type': 'application/json'}}');
    print('Body: ${jsonEncode(body)}');
    print('==================');

    try {
      final response = await http
          .post(
            url,
            body: jsonEncode(body),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(Duration(seconds: 30));

      print('=== LOGIN RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');
      print('==================');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          // Login successful
          return;
        } else {
          throw Exception(data['message'] ?? 'Login failed');
        }
      } else if (response.statusCode == 404) {
        throw Exception('User not found. Please register first.');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Invalid phone number format');
      } else {
        throw Exception('Server error. Please try again later.');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout. Please check your connection.');
      } else if (e.toString().contains('SocketException')) {
        throw Exception(
          'Network error. Please check your internet connection.',
        );
      } else {
        rethrow;
      }
    }
  }

  static Future<void> verifyOtp({
    required int phoneNumber,
    required int otp,
    required BuildContext context,
    String? userType,
  }) async {
    final url = Uri.parse('$apiBaseUrl/verify-otp');
    final body = {
      "phone": phoneNumber,
      "otp": otp,
      "user_type": userType ?? "customer",
    };

    print('=== VERIFY OTP REQUEST ===');
    print('URL: ${url.toString()}');
    print('Headers: ${{'Content-Type': 'application/json'}}');
    print('Body: ${jsonEncode(body)}');
    print('==================');

    final response = await http.post(
      url,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    print('=== VERIFY OTP RESPONSE ===');
    print('Status Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    print('Response Body: ${response.body}');
    print('===================');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Save access token directly from response root
      Preferences.instance.save(PrefKeys.apiToken, data['access_token']);
      final expiryTime =
          DateTime.now().add(Duration(hours: 1)).toIso8601String();
      Preferences.instance.save(PrefKeys.tokenExpiry, expiryTime);

      // Save refresh token if available
      if (data['refresh_token'] != null) {
        Preferences.instance.save(PrefKeys.refreshToken, data['refresh_token']);
      }

      // Parse user data from user object
      if (data['user_data'] != null) {
        final userData = data['user_data'];
        Preferences.instance.save(PrefKeys.authKey, userData['uid'] ?? '');
        Preferences.instance.save('role', userData['user_type'] ?? 'customer');
        Preferences.instance.save(
          PrefKeys.firstName,
          userData['first_name'] ?? '',
        );
        SessionManager.instance.setFirstname(userData['first_name']);
        Preferences.instance.save(
          PrefKeys.lastName,
          userData['last_name'] ?? '',
        );
        SessionManager.instance.setLastname(userData['last_name']);
        // Store phone number as string to match UserData model
        final phoneNumber = userData['phone_number'] ?? '';
        if (phoneNumber.isNotEmpty) {
          SessionManager.instance.setPhoneFromString(phoneNumber.toString());
        }
        Preferences.instance.save(PrefKeys.email, userData['email'] ?? '');
        SessionManager.instance.setEmail(userData['email']);

        if (userData['wallet_balance_tzs'] != null) {
          SessionManager.instance.setWalletBalance(
            WalletBalance(
              balanceTzs:
                  double.tryParse(userData['wallet_balance_tzs'].toString()) ??
                  0.0,
              balanceUsd:
                  double.tryParse(userData['wallet_balance_usd'].toString()) ??
                  0.0,
            ),
          );
        }

        if (userData['preferred_payment_method'] != null) {
          SessionManager.instance.setPreferredPaymentMethod(
            userData['preferred_payment_method'],
          );
        }

        // Create and set UserData object in SessionManager
        final userDataObject = UserData(
          firstName: userData['first_name'] ?? '',
          lastName: userData['last_name'] ?? '',
          phoneNumber: userData['phone_number'] ?? '',
          email: userData['email'] ?? '',
          password: '', // Don't store password
          userType: userData['user_type'] ?? 'customer',
          regionId: 1, // Default region
          middleName: userData['middle_name'],
          profilePhotoUrl: userData['profile_photo_url'],
          walletBalanceTzs:
              double.tryParse(
                userData['wallet_balance_tzs']?.toString() ?? '0',
              ) ??
              0.0,
          walletBalanceUsd:
              double.tryParse(
                userData['wallet_balance_usd']?.toString() ?? '0',
              ) ??
              0.0,
          preferredPaymentMethod: userData['preferred_payment_method'],
          isVerified:
              userData['is_verified'] == 1 || userData['is_verified'] == true,
          totalRides: userData['total_rides'] ?? 0,
          averageRating:
              double.tryParse(userData['average_rating']?.toString() ?? '0') ??
              0.0,
        );

        SessionManager.instance.setUser(userDataObject);
        await Preferences.instance.saveUserData(userDataObject);
      }

      // Navigate based on user type
      final userType = data['user_data']?['user_type'] ?? 'customer';
      final isVerified =
          data['user_data']?['is_verified'] == 1 ||
          data['user_data']?['is_verified'] == true;

      if (userType == 'driver') {
        // Drivers always go to MainLayout (which contains DashboardScreen)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainLayout()),
        );
      } else {
        // Vendors and customers go to Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Dashboard()),
        );
      }
    } else {
      // Handle error responses
      final data = jsonDecode(response.body);
      final errorMessage = data['message'] ?? 'OTP verification failed';

      // Throw an exception with the error message so the OTP provider can handle it
      throw Exception(errorMessage);
    }
  }

  static Future<void> resendOtp({
    required int phoneNumber,
    required BuildContext context,
    String? userType,
  }) async {
    final url = Uri.parse('$apiBaseUrl/resend-otp');
    final body = {"phone": phoneNumber, "user_type": userType ?? "customer"};

    print('=== RESEND OTP REQUEST ===');
    print('URL: ${url.toString()}');
    print('Headers: ${{'Content-Type': 'application/json'}}');
    print('Body: ${jsonEncode(body)}');
    print('==================');

    final response = await http.post(
      url,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    print('=== RESEND OTP RESPONSE ===');
    print('Status Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    print('Response Body: ${response.body}');
    print('===================');

    final data = jsonDecode(response.body);
    if (data['code'] == 404) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(data['message'])));
    }

    final phone = data['data']['phone'];
    // Store phone number as string to match UserData model
    if (phone != null && phone.toString().isNotEmpty) {
      SessionManager.instance.setPhoneFromString(phone.toString());
    }
  }

  static Future<void> logout(BuildContext context) async {
    try {
      final url = Uri.parse('$apiBaseUrl/logout');

      print('=== LOGOUT REQUEST ===');
      print('URL: ${url.toString()}');
      print('Headers: Bearer ${await Preferences.instance.apiToken}');
      print(
        'Body: ${jsonEncode({'refresh_token': await Preferences.instance.refreshToken})}',
      );
      print('==================');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${await Preferences.instance.apiToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refresh_token': await Preferences.instance.refreshToken,
        }),
      );

      print('=== LOGOUT RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');
      print('===================');

      // Always clear session and preferences regardless of server response
      SessionManager.instance.clearSession();
      await Preferences.instance.clear();
      print('All preferences cleared');

      // Log success message if server responded successfully
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          final message = data['message'] ?? 'Logged out successfully';
          print('Logout successful: $message');
        } catch (e) {
          print('Error parsing logout response: $e');
        }
      }
    } catch (e) {
      print('Logout error: $e');
      // Still clear session even if network request fails
      SessionManager.instance.clearSession();
      await Preferences.instance.clear();
      print('All preferences cleared after error');
    }

    // Navigation removed - will be handled by calling buttons
  }

  static Future<dynamic> getNewAccessToken() async {
    try {
      final refreshToken = await Preferences.instance.refreshToken;
      final userType =
          await Preferences.instance.selectedUserType ?? 'customer';
      final url = Uri.parse('$apiBaseUrl/refresh-token');

      print('=== REFRESH TOKEN REQUEST ===');
      print('URL: ${url.toString()}');
      print('Headers: ${{'Content-Type': 'application/json'}}');
      print(
        'Body: ${jsonEncode({'refresh_token': refreshToken, "role": userType})}',
      );
      print('==================');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken, "role": userType}),
      );

      print('=== REFRESH TOKEN RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');
      print('===================');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access_token'];
        Preferences.instance.save(PrefKeys.apiToken, newAccessToken);
        return newAccessToken;
      } else {
        final data = jsonDecode(response.body);
        print('Error from refresh token: $data');
      }
    } catch (e) {
      print('Something wrong $e');
    }
  }

  static Future<bool> updateProfile({
    required BuildContext context,
    required String userId,
    String? firstName,
    String? lastName,
    String? middleName,
    String? email,
    String? preferredPaymentMethod,
    File? profilePhoto,
  }) async {
    try {
      final token = await Preferences.instance.apiToken;
      final uri = Uri.parse('$apiBaseUrl/user/update-profile/$userId');
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';

      if (firstName != null) request.fields['name'] = firstName;
      if (lastName != null) request.fields['sname'] = lastName;
      if (middleName != null) request.fields['middle_name'] = middleName;
      if (email != null) request.fields['email'] = email;
      if (preferredPaymentMethod != null) {
        request.fields['preferred_payment_method'] = preferredPaymentMethod;
      }

      if (profilePhoto != null) {
        final multipartFile = await http.MultipartFile.fromPath(
          'profile_photo',
          profilePhoto.path,
        );
        request.files.add(multipartFile);
      }

      print('=== UPDATE PROFILE REQUEST ===');
      print('URL: ${uri.toString()}');
      print('Headers: ${request.headers}');
      print('Fields: ${request.fields}');
      print('Files: ${request.files.map((f) => f.field).toList()}');
      print('==============================');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('=== UPDATE PROFILE RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('===============================');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          return true;
        } else {
          print('Update profile failed: ${data['message']}');
          return false;
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception updating profile: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    debugPrint('=== GET USER PROFILE ===');
    debugPrint('Using UserData from Preferences');

    try {
      final userData = await Preferences.instance.userDataObject;
      if (userData != null) {
        debugPrint(
          'Found user data: ${userData.firstName} ${userData.lastName}',
        );

        final profileData = {
          'user': userData,
          'profile_photo_url': userData.profilePhotoUrl,
          'wallet_balance_tzs': userData.walletBalanceTzs,
          'wallet_balance_usd': userData.walletBalanceUsd,
          'preferred_payment_method': userData.preferredPaymentMethod,
          'is_verified': userData.isVerified,
          'total_rides': userData.totalRides,
          'average_rating': userData.averageRating,
        };

        debugPrint('User Profile Data: $profileData');
        debugPrint('============================');
        return profileData;
      }

      debugPrint('No user data found in preferences');
      debugPrint('============================');
      return null;
    } catch (e) {
      debugPrint('Exception getting user profile: $e');
      debugPrint('============================');
      return null;
    }
  }
}
