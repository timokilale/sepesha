import 'package:ipf_flutter_starter_pack/bases.dart';

class PrefKeys {
  PrefKeys._();

  static const String apiToken = "api_token";
  static const String language = "language";
  static const String darkMode = "dark_mode";

  static const String refreshToken = "refreshToken";
    static const String tokenExpiry = "tokenExpiry";


  //user info
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
  Future<int?> get phoneNumber async => await fetch<int?>(PrefKeys.phoneNumber);

  Future<String?> get language async => await fetch<String?>(PrefKeys.language);

  Future<bool?> get darkMode async => await fetch<bool?>(PrefKeys.darkMode);

  //UserInfo
  Future<String?> get firstName async =>
      await fetch<String?>(PrefKeys.firstName);
  Future<String?> get lastName async => await fetch<String?>(PrefKeys.lastName);
  Future<String?> get email async => await fetch<String?>(PrefKeys.email);
  Future<String?> get middleName async =>
      await fetch<String?>(PrefKeys.middleName);
}
