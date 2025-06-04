import 'package:google_maps_flutter/google_maps_flutter.dart';

class Driver {
  final String id;
  final String authKey;
  final String name;
  final String phone;
  final double rating;
  final LatLng location;
  final Vehicle vehicle;

  Driver({
    required this.id,
    required this.authKey,
    required this.name,
    required this.phone,
    required this.rating,
    required this.location,
    required this.vehicle,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] ?? '',
      authKey: json['auth_key'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      location: LatLng(
        (json['latitude'] ?? 0.0).toDouble(),
        (json['longitude'] ?? 0.0).toDouble(),
      ),
      vehicle: Vehicle.fromJson(json['vehicle'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'auth_key': authKey,
      'name': name,
      'phone': phone,
      'rating': rating,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'vehicle': vehicle.toJson(),
    };
  }

  String getVehicleDetails() {
    return '${vehicle.make} ${vehicle.model} • ${vehicle.color} • ${vehicle.plateNumber}';
  }
}

class Vehicle {
  final String id;
  final String plateNumber;
  final String make;
  final String model;
  final String year;
  final String color;
  final String feeCategoryId;

  Vehicle({
    required this.id,
    required this.plateNumber,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.feeCategoryId,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] ?? '',
      plateNumber: json['plate_number'] ?? '',
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? '',
      color: json['color'] ?? '',
      feeCategoryId: json['fee_category_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plate_number': plateNumber,
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'fee_category_id': feeCategoryId,
    };
  }
}