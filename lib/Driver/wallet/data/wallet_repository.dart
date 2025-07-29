import 'package:sepesha_app/Driver/model/user_model.dart';
import 'package:sepesha_app/repositories/user_profile_repository.dart';
import 'package:sepesha_app/services/preferences.dart';
import 'package:sepesha_app/services/rating_service.dart';
import 'package:sepesha_app/services/session_manager.dart';

class WalletRepository {
  Future<User> getDriverData() async {
    try {
      // Get user profile data from API
      final userProfileData = await UserProfileRepository().getUserProfile();
      if (userProfileData == null) {
        return _getDefaultUser();
      }

      final userData = userProfileData['user'];
      if (userData == null) {
        return _getDefaultUser();
      }

      // Get driver ID for rating lookup
      final driverId = await _getCurrentDriverId();

      // Get driver rating data from API
      final driverRating =
          driverId != null
              ? await RatingService.getDriverReviews(driverId)
              : null;

      // Get vehicle info from session or API
      final vehicleInfo = await _getDriverVehicle();

      return User(
        id: driverId ?? 'unknown',
        name: '${userData.firstName} ${userData.lastName}',
        email: userData.email,
        phone: userData.phoneNumber,
        vehicleNumber: vehicleInfo['plateNumber'] ?? 'N/A',
        vehicleType: vehicleInfo['vehicleType'] ?? 'N/A',
        walletBalance:
            userProfileData['wallet_balance_tzs'] != null
                ? double.tryParse(
                      userProfileData['wallet_balance_tzs'].toString(),
                    ) ??
                    0.0
                : 0.0,
        rating: driverRating?.averageRating ?? 0.0,
        totalRides: driverRating?.totalReviews ?? 0,
        isVerified: userData.isVerified ?? false,
      );
    } catch (e) {
      print('Error getting driver data: $e');
      return _getDefaultUser();
    }
  }

  Future<String?> _getCurrentDriverId() async {
    try {
      final userData = SessionManager.instance.user;
      if (userData != null) {
        return 'driver_${userData.phoneNumber}';
      }
      final phone = await Preferences.instance.phoneNumber;
      return phone != null ? 'driver_$phone' : null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, String>> _getDriverVehicle() async {
    try {
      // Try session first
      final sessionVehicle = SessionManager.instance.vehicle;
      if (sessionVehicle != null) {
        return {
          'plateNumber': sessionVehicle.plateNumber ?? 'N/A',
          'vehicleType':
              '${sessionVehicle.manufacturer ?? ''} ${sessionVehicle.model ?? ''}'
                  .trim(),
        };
      }
      return {'plateNumber': 'N/A', 'vehicleType': 'N/A'};
    } catch (e) {
      return {'plateNumber': 'N/A', 'vehicleType': 'N/A'};
    }
  }

  User _getDefaultUser() {
    return User(
      id: 'unknown',
      name: 'Driver',
      email: 'driver@sepesha.com',
      phone: 'N/A',
      vehicleNumber: 'N/A',
      vehicleType: 'N/A',
      walletBalance: 0.0,
      rating: 0.0,
      totalRides: 0,
      isVerified: false,
    );
  }
}
