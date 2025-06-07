


import 'package:sepesha_app/Driver/model/user_model.dart';

class WalletRepository {
  Future<User> getDriverData() async {
    await Future.delayed(const Duration(seconds: 1));
    return User(
      id: 'driver123',
      name: 'John Driver',
      email: 'john.driver@example.com',
      phone: '+1234567890',
      vehicleNumber: 'ABC123',
      vehicleType: 'Sedan',
      walletBalance: 1250.75,
      rating: 4.8,
      totalRides: 245,
    );
  }
}