import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionSubscription;
  Stream<LatLng>? _locationStream;

  // Start tracking location
  Stream<LatLng> startLocationTracking() {
    if (_locationStream != null) return _locationStream!;

    _locationStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).map((position) => LatLng(position.latitude, position.longitude));

    return _locationStream!;
  }

  // Stop tracking location
  void stopLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _locationStream = null;
  }

  // Get current location once
  Future<LatLng?> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  // Check and request permissions
  Future<bool> checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    return permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always;
  }
}