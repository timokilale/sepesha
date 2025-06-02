
import 'package:sepesha_app/Driver/model/ride_model.dart';

class HistoryRepository {
  Future<List<Ride>> getRideHistory() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Ride(
        id: 'past1',
        passengerName: 'Sarah Williams',
        pickupAddress: '123 Main St, Cityville',
        destinationAddress: '456 Central Ave, Townsville',
        fare: 18.50,
        distance: 6.2,
        requestTime: DateTime.now().subtract(const Duration(days: 1)),
        status: RideStatus.completed,
        rating: 5.0,
      ),
      Ride(
        id: 'past2',
        passengerName: 'Michael Brown',
        pickupAddress: '789 Park Rd, Villagetown',
        destinationAddress: '321 Market St, Cityville',
        fare: 25.75,
        distance: 9.7,
        requestTime: DateTime.now().subtract(const Duration(days: 2)),
        status: RideStatus.completed,
        rating: 4.0,
      ),
      Ride(
        id: 'past3',
        passengerName: 'Emily Davis',
        pickupAddress: '101 Oak Lane, Forestville',
        destinationAddress: '202 Pine St, Mountainview',
        fare: 32.00,
        distance: 12.5,
        requestTime: DateTime.now().subtract(const Duration(days: 3)),
        status: RideStatus.completed,
        rating: 4.5,
      ),
    ];
  }
}