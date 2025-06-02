import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sepesha_app/Driver/live/data/live_repository.dart';
import 'package:sepesha_app/Driver/model/ride_model.dart';

class LiveViewModel with ChangeNotifier {
  final LiveRepository _repository = LiveRepository();

  Ride? _currentRide;
  bool _isLoading = true;
  LatLng? _driverPosition;
  LatLng? _passengerPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  StreamSubscription? _passengerLocationSubscription;

  Ride? get currentRide => _currentRide;
  bool get isLoading => _isLoading;
  LatLng? get driverPosition => _driverPosition;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;

  LiveViewModel(String rideId) {
    _loadRideDetails(rideId);
    _startLocationUpdates();
  }

  Future<void> _loadRideDetails(String rideId) async {
    _currentRide = await _repository.getActiveRideDetails(rideId);
    _isLoading = false;
    notifyListeners();
  }

  void _startLocationUpdates() {
    // Initialize with a non-null value since we're sure it's not null here
    _driverPosition = const LatLng(37.7749, -122.4194); // Initial position

    if (_currentRide != null) {
      _passengerLocationSubscription = _repository
          .getPassengerLocation(_currentRide!.id)
          .listen((position) {
            //  _passengerPosition = position;
            _updateMarkersAndRoute();
          });
    }

    notifyListeners();
  }

  void _updateMarkersAndRoute() {
    // Add null checks since we're using nullable variables
    if (_driverPosition == null || _passengerPosition == null) return;

    _markers = {
      Marker(
        markerId: const MarkerId('driver'),
        position: _driverPosition!, // Using ! since we checked for null above
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
      Marker(
        markerId: const MarkerId('passenger'),
        position:
            _passengerPosition!, // Using ! since we checked for null above
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Passenger: ${_currentRide?.passengerName}',
        ),
      ),
      if (_currentRide != null)
        Marker(
          markerId: const MarkerId('destination'),
          position: const LatLng(
            37.3352,
            -122.0324,
          ), // Would come from ride data
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Destination'),
        ),
    };

    _polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: [
          _driverPosition!, // Using ! since we checked for null above
          _passengerPosition!, // Using ! since we checked for null above
          const LatLng(37.3352, -122.0324), // Destination
        ],
        color: Colors.blue,
        width: 4,
      ),
    };

    notifyListeners();
  }

  Future<void> updateDriverPosition(LatLng newPosition) async {
    _driverPosition = newPosition; // This is fine as newPosition is LatLng
    // await _repository.updateDriverLocation(newPosition);
    _updateMarkersAndRoute();
  }

  Future<void> completeRide() async {
    if (_currentRide != null) {
      await _repository.completeRide(_currentRide!.id);
      _passengerLocationSubscription?.cancel();
    }
  }

  Future<void> cancelRide() async {
    if (_currentRide != null) {
      await _repository.cancelRide(_currentRide!.id);
      _passengerLocationSubscription?.cancel();
    }
  }

  @override
  void dispose() {
    _passengerLocationSubscription?.cancel();
    super.dispose();
  }
}
