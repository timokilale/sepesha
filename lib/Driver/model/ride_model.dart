class Ride {
  final String id;
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

  Ride({
    required this.id,
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
  });
}

enum RideStatus { requested, accepted, inProgress, completed, cancelled }
