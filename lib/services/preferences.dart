import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sepesha_app/models/user_data.dart';
import 'package:sepesha_app/services/base_preference.dart';

class PrefKeys {
  PrefKeys._();

  static const String apiToken = "api_token";
  static const String language = "language";
  static const String darkMode = "dark_mode";

  static const String refreshToken = "refreshToken";
  static const String tokenExpiry = "tokenExpiry";

  //user info
  static const String authKey = "auth_key";
  static const String firstName = "first_name";
  static const String lastName = "last_name";
  static const String email = "email";
  static const String middleName = "middle_name";
  static const String phoneNumber = "phone";
}

class Preferences extends BasePreferences {
  Preferences._();
  static final Preferences _instance = Preferences._();
  static Preferences get instance => _instance;

  Future<String?> get apiToken async => await fetch<String?>(PrefKeys.apiToken);
  Future<String?> get refreshToken async =>
      await fetch<String?>(PrefKeys.refreshToken);
  Future<String?> get tokenExpiry async =>
      await fetch<String?>(PrefKeys.tokenExpiry);
  Future<String?> get phoneNumber async =>
      await fetch<String?>(PrefKeys.phoneNumber);

  Future<String?> get language async => await fetch<String?>(PrefKeys.language);

  Future<bool?> get darkMode async => await fetch<bool?>(PrefKeys.darkMode);

  //UserInfo
  Future<String?> get authKey async => await fetch<String?>(PrefKeys.authKey);
  Future<String?> get firstName async =>
      await fetch<String?>(PrefKeys.firstName);
  Future<String?> get lastName async => await fetch<String?>(PrefKeys.lastName);
  Future<String?> get email async => await fetch<String?>(PrefKeys.email);
  Future<String?> get middleName async =>
      await fetch<String?>(PrefKeys.middleName);

  // User type getter
  Future<String?> get selectedUserType async =>
      await fetch<String?>('selected_user_type');

  // Generic getString method for accessing any string preference
  Future<String?> getString(String key) async => await fetch<String?>(key);

  // UserData object storage
  static const String userData = "user_data";

  Future<UserData?> get userDataObject async {
    final userDataJson = await fetch<String?>(userData);
    if (userDataJson != null) {
      try {
        final Map<String, dynamic> userMap = jsonDecode(userDataJson);
        return UserData.fromJson(userMap);
      } catch (e) {
        debugPrint('Error parsing user data: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> saveUserData(UserData user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      save(userData, userJson);
      debugPrint('User data saved to preferences');
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }

  Future<void> clearUserData() async {
    remove(userData);
    debugPrint('User data cleared from preferences');
  }

  Future<void> clear() async {
    clearAll();
    debugPrint('All preferences cleared');
  }
}
