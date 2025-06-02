import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:sepesha_app/screens/auth/auth_screen.dart';
import 'package:sepesha_app/screens/dashboard/dashboard.dart';
import 'package:sepesha_app/services/preferences.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import 'package:sepesha_app/services/session_manager.dart';

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
      'privacy_checked': privacyChecked ? '1' : '0',
      if (userType == 'vendor')
        'business_description': businessDescription ?? '',
      if (userType == 'driver') 'licence_number': licenceNumber ?? '',
      if (userType == 'driver') 'licence_expiry': licenceExpiry ?? '',
    });

    // Add files only if required
    if (userType == 'driver' && profilePhoto != null) {
      request.files.add(
        await http.MultipartFile.fromPath('profile_photo', profilePhoto.path),
      );
    }

    if (userType == 'driver' && attachment != null) {
      request.files.add(
        await http.MultipartFile.fromPath('attachment', attachment.path),
      );
    }

    final response = await request.send();

    if (response.statusCode == 201) {
      final respStr = await response.stream.bytesToString();
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
  }) async {
    final url = Uri.parse('$apiBaseUrl/login');
    final body = {"phone": phoneNumber, "user_type": "customer"};

    final response = await http.post(
      url,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    final data = jsonDecode(response.body);
    // if (!data['status']) {
    //   throw Exception('Login failed: ${data['message']}');
    // }
    if (data['code'] == 404) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(data['message'])));
    }

    print(
      "The response code is ${response.statusCode} with body ${response.body}",
    );

    final phone = data['data']['phone_number'];
    Preferences.instance.save(PrefKeys.phoneNumber, phone);
  }

  static Future<void> verifyOtp({
    required int phoneNumber,
    required int otp,
    required BuildContext context,
  }) async {
    final url = Uri.parse('$apiBaseUrl/verify-otp');
    final body = {"phone": phoneNumber, "otp": otp, "user_type": "customer"};

    final response = await http.post(
      url,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    final data = jsonDecode(response.body);
    if (!data['status']) {
      throw Exception('OTP verification failed: ${data['message']}');
    }

    // print(
    //   "The response code is ${response.statusCode} with body ${response.body}",
    // );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Save the important fields to preferences
      Preferences.instance.save(PrefKeys.apiToken, data['access_token']);
      Preferences.instance.save(PrefKeys.refreshToken, data['refresh_token']);

      if (data['user_data'] != null) {
        final userData = data['user_data'];

        Preferences.instance.save(
          PrefKeys.firstName,
          userData['first_name'] ?? '',
        );
        SessionManager.instance.setFirstname(userData['first_name']);

        if (userData['middle_name'] != null) {
          Preferences.instance.save(
            PrefKeys.middleName,
            userData['middle_name'] ?? '',
          );
          SessionManager.instance.setMiddlename(userData['middle_name']);
        }

        Preferences.instance.save(
          PrefKeys.lastName,
          userData['last_name'] ?? '',
        );
        SessionManager.instance.setLastname(userData['last_name']);
        Preferences.instance.save(
          PrefKeys.phoneNumber,
          userData['phone_number'] ?? '',
        );
        SessionManager.instance.setPhone(int.parse(userData['phone_number']));
        Preferences.instance.save(PrefKeys.email, userData['email'] ?? '');
        SessionManager.instance.setEmail(userData['email']);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    }
  }

  static Future<void> resendOtp({
    required int phoneNumber,
    required BuildContext context,
  }) async {
    final url = Uri.parse('$apiBaseUrl/resend-otp');
    final body = {"phone": phoneNumber, "user_type": "customer"};

    final response = await http.post(
      url,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    final data = jsonDecode(response.body);
    // if (!data['status']) {
    //   throw Exception('Login failed: ${data['message']}');
    // }
    if (data['code'] == 404) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(data['message'])));
    }

    print(
      "The response code is ${response.statusCode} with body ${response.body}",
    );

    final phone = data['data']['phone_number'];
    Preferences.instance.save(PrefKeys.phoneNumber, phone);
  }

  static Future<void> logout(BuildContext context) async {
    final url = Uri.parse('$apiBaseUrl/logout');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${await Preferences.instance.apiToken}',
      },
      body: jsonEncode({
        'refresh_token': await Preferences.instance.refreshToken,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final message = data['message'];
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AuthScreen()),
      );
    }
  }

  static Future<dynamic> getNewAccessToken() async {
    try {
      final refreshToken = await Preferences.instance.refreshToken;
      final url = Uri.parse('$apiBaseUrl/refresh-token');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'refresh_token': refreshToken,
          "user_type": "customer",
        }),
      );

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
}
