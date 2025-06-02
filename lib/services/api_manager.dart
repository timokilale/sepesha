import 'package:ipf_flutter_starter_pack/bases.dart';
import 'package:sepesha_app/services/preferences.dart';
import 'package:flutter/foundation.dart';

class APIManager extends BaseAPIManager {
	APIManager._(): super(_currentURL, _authorization);
	static APIManager get instance => APIManager._();

	static const String _localURL = "http://127.0.0.1:8000/api/v1";
	static const String _baseURL = "<Insert URL Here>/api/v1";
	static const String _releaseURL = "<Insert URL Here>/api/v1";
	static const String _currentURL = kDebugMode ? _localURL : _releaseURL;

	static Future<Map<String, String>?> get _authorization async {
		Preferences preferences = Preferences.instance;
		String? token = await preferences.fetch(PrefKeys.apiToken);
		if (token == null) return null;
		return {"Authorization": "Bearer $token"};
	}
}