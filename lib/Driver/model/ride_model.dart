class Ride {
  final String id;
  final String customerId;
  final String passengerName;
  final String pickupAddress;
  final String destinationAddress;
  final double fare;
  final double distance;
  final DateTime requestTime;
  final RideStatus status;
  final double? rating;
  final String? passengerPhone;
  final String? vehicleTypeRequested;
  // Add coordinate fields
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? destinationLatitude;
  final double? destinationLongitude;

  Ride({
    required this.id,
    required this.customerId,
    required this.passengerName,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.fare,
    required this.distance,
    required this.requestTime,
    required this.status,
    this.rating,
    this.passengerPhone,
    this.vehicleTypeRequested,
    this.pickupLatitude,
    this.pickupLongitude,
    this.destinationLatitude,
    this.destinationLongitude,
  });
}

enum RideStatus { requested, accepted, inProgress, completed, cancelled }
