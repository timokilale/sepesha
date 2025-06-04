import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/models/direction_model.dart';
import 'package:sepesha_app/screens/info_handler/app_info.dart';
import 'package:sepesha_app/services/auth_services.dart';
import 'package:sepesha_app/services/request_assistance.dart';
import 'package:sepesha_app/services/preferences.dart';

class AssistanceService {
  AssistanceService._();
  static final String apiKey = dotenv.env['MAP_KEY']!;

  static Future<String> searchAddressForGeographicalCoordinated(
    Position position,
    context,
  ) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey";
    String humanReadableAddress = 'No address found';

    var requestResponse = await RequestAssistance.receiveRequest(apiUrl);

    if (requestResponse is String &&
        requestResponse == 'Error occured. Failed to receive request.') {
      return humanReadableAddress;
    }

    try {
      if (requestResponse['results'] != null &&
          requestResponse['results'].isNotEmpty) {
        humanReadableAddress =
            requestResponse['results'][0]['formatted_address'];
        DirectionModel _userPickupAddress = DirectionModel();

        _userPickupAddress.locationName = humanReadableAddress;
        _userPickupAddress.locationLatitude = position.latitude;
        _userPickupAddress.locationLongitude = position.longitude;

        Provider.of<AppInfo>(
          context,
          listen: false,
        ).updatePickupLocationAddress(_userPickupAddress);
      }
    } catch (e) {
      debugPrint('Error parsing address: $e');
    }

    return humanReadableAddress;
  }

  static Future<bool> checkTokenExpiration() async {
    final accessToken = await Preferences.instance.apiToken;
    final tokenStatus =
        accessToken != null ? JwtDecoder.isExpired(accessToken) : true;

    if (tokenStatus) {
      debugPrint(' Accessing new  token');
      await AuthServices.getNewAccessToken();
    } else {
      debugPrint('Token is still valid');
    }
    return tokenStatus;
  }
}
