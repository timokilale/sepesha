import '../../../model/ride_model.dart' show Ride, RideStatus;
import '../../../model/user_model.dart' show User;

class DashboardRepository {
  Future<User> getUserData() async {
    await Future.delayed(const Duration(seconds: 1));
    return User(
      id: 'User123',
      name: 'John User',
      email: 'john.User@example.com',
      phone: '+1234567890',
      vehicleNumber: 'ABC123',
      vehicleType: 'Sedan',
      walletBalance: 1250.75,
      rating: 4.8,
      totalRides: 245,
    );
  }

  Future<List<Ride>> getPendingRides() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Ride(
        id: 'ride1',
        passengerName: 'Alice Smith',
        pickupAddress: '123 Main St, Cityville',
        destinationAddress: '456 Central Ave, Townsville',
        fare: 15.50,
        distance: 5.2,
        requestTime: DateTime.now().subtract(const Duration(minutes: 5)),
        status: RideStatus.requested,
      ),
      // Ride(
      //   id: 'ride2',
      //   passengerName: 'Bob Johnson',
      //   pickupAddress: '789 Park Rd, Villagetown',
      //   destinationAddress: '321 Market St, Cityville',
      //   fare: 22.75,
      //   distance: 8.7,
      //   requestTime: DateTime.now().subtract(const Duration(minutes: 2)),
      //   status: RideStatus.requested,
      // ),
      // Ride(
      //   id: 'ride2',
      //   passengerName: 'Bob Johnson',
      //   pickupAddress: '789 Park Rd, Villagetown',
      //   destinationAddress: '321 Market St, Cityville',
      //   fare: 22.75,
      //   distance: 8.7,
      //   requestTime: DateTime.now().subtract(const Duration(minutes: 2)),
      //   status: RideStatus.requested,
      // ),
      // Ride(
      //   id: 'ride2',
      //   passengerName: 'Bob Johnson',
      //   pickupAddress: '789 Park Rd, Villagetown',
      //   destinationAddress: '321 Market St, Cityville',
      //   fare: 22.75,
      //   distance: 8.7,
      //   requestTime: DateTime.now().subtract(const Duration(minutes: 2)),
      //   status: RideStatus.requested,
      // ),
      // Ride(
      //   id: 'ride2',
      //   passengerName: 'Bob Johnson',
      //   pickupAddress: '789 Park Rd, Villagetown',
      //   destinationAddress: '321 Market St, Cityville',
      //   fare: 22.75,
      //   distance: 8.7,
      //   requestTime: DateTime.now().subtract(const Duration(minutes: 2)),
      //   status: RideStatus.requested,
      // ),
      // Ride(
      //   id: 'ride2',
      //   passengerName: 'Bob Johnson',
      //   pickupAddress: '789 Park Rd, Villagetown',
      //   destinationAddress: '321 Market St, Cityville',
      //   fare: 22.75,
      //   distance: 8.7,
      //   requestTime: DateTime.now().subtract(const Duration(minutes: 2)),
      //   status: RideStatus.requested,
      // ),
    ];
  }

  Future<void> acceptRide(String rideId) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> rejectRide(String rideId) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> completeRide(String rideId) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
