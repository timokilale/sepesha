import 'package:latlong2/latlong.dart';
import 'package:sepesha_app/Driver/model/ride_model.dart';

class LiveRepository {
  Future<Ride> getActiveRideDetails(String rideId) async {
    await Future.delayed(const Duration(seconds: 1));
    return Ride(
      id: rideId,
      passengerName: 'Alice Smith',
      pickupAddress: '123 Main St, Cityville',
      destinationAddress: '456 Central Ave, Townsville',
      fare: 15.50,
      distance: 5.2,
      requestTime: DateTime.now().subtract(const Duration(minutes: 20)),
      status: RideStatus.inProgress,
      passengerPhone: '+1234567890',
    );
  }

  Future<void> updateDriverLocation(LatLng position) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> completeRide(String rideId) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> cancelRide(String rideId) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Stream<LatLng> getPassengerLocation(String rideId) async* {
    // Simulate passenger moving towards destination
    final positions = [
      const LatLng(37.7749, -122.4194), // Pickup
      const LatLng(37.7759, -122.4184),
      const LatLng(37.7769, -122.4174),
      const LatLng(37.7779, -122.4164),
      const LatLng(37.3352, -122.0324), // Dropoff
    ];

    for (final position in positions) {
      await Future.delayed(const Duration(seconds: 5));
      yield position;
    }
  }
}
