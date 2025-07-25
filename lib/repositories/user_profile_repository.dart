import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:sepesha_app/models/user_data.dart';
import 'package:sepesha_app/services/preferences.dart';

class UserProfileRepository {
  static final String apiBaseUrl = dotenv.env['BASE_URL']!;

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

  /// Fetch fresh user profile data from API
  Future<Map<String, dynamic>?> getUserProfileFromAPI() async {
    debugPrint('=== GET USER PROFILE FROM API ===');
    try {
      final token = await Preferences.instance.apiToken;
      if (token == null) {
        debugPrint('No auth token found');
        return null;
      }

      final url = Uri.parse('$apiBaseUrl/user/profile');
      debugPrint('Request URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final userData = data['data'];
          debugPrint('Fresh user data from API: $userData');
          debugPrint('============================');
          return userData;
        }
      }
    } catch (e) {
      debugPrint('Exception fetching user profile from API: $e');
    }
    debugPrint('============================');
    return null;
  }

  Future<bool> updateUserProfile({
    String? firstName,
    String? lastName,
    String? middleName,
    String? email,
    String? preferredPaymentMethod,
    File? profilePhoto,
  }) async {
    debugPrint('=== UPDATE USER PROFILE ===');
    try {
      final token = await Preferences.instance.apiToken;
      final userId = await _getCurrentUserId();

      if (userId == null) {
        debugPrint('No user ID found');
        return false;
      }

      final url = Uri.parse('$apiBaseUrl/user/update-profile/$userId');
      debugPrint('Request URL: $url');

      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

      if (firstName != null) request.fields['first_name'] = firstName;
      if (lastName != null) request.fields['last_name'] = lastName;
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

      debugPrint('Request Fields: ${request.fields}');
      debugPrint(
        'Request Files: ${request.files.map((f) => f.field).toList()}',
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final success = data['status'] == true;
        debugPrint('Update successful: $success');
        debugPrint('====================');
        return success;
      } else {
        debugPrint('Error updating profile: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception updating profile: $e');
    }
    return false;
  }

  Future<String?> _getCurrentUserId() async {
    debugPrint('=== GET CURRENT USER ID ===');
    try {
      // Use auth key (uid) from preferences as the primary user ID
      final authKey = await Preferences.instance.authKey;
      if (authKey != null && authKey.isNotEmpty) {
        debugPrint('User ID from auth key: $authKey');
        debugPrint('=======================');
        return authKey;
      }

      debugPrint('No user ID found - returning null');
      return null;
    } catch (e) {
      debugPrint('Error getting user ID: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserStatistics() async {
    debugPrint('=== GET USER STATISTICS ===');
    try {
      final token = await Preferences.instance.apiToken;
      final userId = await _getCurrentUserId();

      if (userId == null) {
        debugPrint('No user ID found');
        return null;
      }

      final url = Uri.parse('$apiBaseUrl/user/statistics/$userId');
      debugPrint('Request URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] && data['data'] != null) {
          debugPrint('User Statistics: ${data['data']}');
          debugPrint('=================');
          return data['data'];
        }
      }
    } catch (e) {
      debugPrint('Exception fetching user statistics: $e');
    }
    return null;
  }
}
