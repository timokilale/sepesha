import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sepesha_app/Driver/live/data/live_repository.dart';
import 'package:sepesha_app/Driver/model/ride_model.dart';
import 'package:sepesha_app/services/websocket_service.dart';
import 'package:sepesha_app/services/location_service.dart';
import 'package:sepesha_app/models/location_update.dart';
import 'package:sepesha_app/services/session_manager.dart';
import 'package:sepesha_app/services/navigation_service.dart';

class LiveViewModel with ChangeNotifier {
  final LiveRepository _repository = LiveRepository();

  Ride? _currentRide;
  bool _isLoading = true;
  LatLng? _driverPosition;
  LatLng? _passengerPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  StreamSubscription? _passengerLocationSubscription;
  final WebSocketService _webSocketService = WebSocketService();
final LocationService _locationService = LocationService();
StreamSubscription<LatLng>? _locationSubscription;
StreamSubscription<LocationUpdate>? _webSocketLocationSubscription;

  Ride? get currentRide => _currentRide;
  bool get isLoading => _isLoading;
  LatLng? get driverPosition => _driverPosition;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;

  LiveViewModel(String rideId) {
  _loadRideDetails(rideId);
  _startLocationUpdates();
  _loadRideDetails(rideId).then((_) {
    _initializeWebSocket();
  });
}

  Future<void> _initializeWebSocket() async {
  try {
    final userId = await _getCurrentUserId();
    _webSocketService.connect(userId);

    
    if (_currentRide != null) {
  _webSocketService.subscribeToBooking(_currentRide!.id);
}
    
    // Listen for location updates from other users (passengers)
    _webSocketLocationSubscription = _webSocketService.locationUpdateStream.listen((locationUpdate) {
      if (locationUpdate.userType == 'customer' && locationUpdate.bookingId == _currentRide?.id) {
        _passengerPosition = LatLng(locationUpdate.latitude, locationUpdate.longitude);
        _updateMarkersAndRoute();
      }
    });
  } catch (e) {
    print('Error initializing WebSocket: $e');
  }
}

void _startLocationUpdates() async {
  // Check location permissions
  final hasPermission = await _locationService.checkPermissions();
  if (!hasPermission) {
    print('Location permission denied');
    return;
  }

  // Start GPS tracking
  _locationSubscription = _locationService.startLocationTracking().listen((position) {
    _driverPosition = position;
    _sendLocationUpdate(position);
    _updateMarkersAndRoute();
  });

  notifyListeners();
}

Future<void> openNavigationToPickup() async {
  if (_currentRide?.pickupLatitude != null && _currentRide?.pickupLongitude != null) {
    await NavigationService.openNavigation(
      latitude: _currentRide!.pickupLatitude!,
      longitude: _currentRide!.pickupLongitude!,
      label: 'Pickup: ${_currentRide!.pickupAddress}',
    );
  } else {
    throw Exception('Pickup coordinates not available');
  }
}

Future<void> openNavigationToDestination() async {
  if (_currentRide?.destinationLatitude != null && _currentRide?.destinationLongitude != null) {
    await NavigationService.openNavigation(
      latitude: _currentRide!.destinationLatitude!,
      longitude: _currentRide!.destinationLongitude!,
      label: 'Destination: ${_currentRide!.destinationAddress}',
    );
  } else {
    throw Exception('Destination coordinates not available');
  }
}

Future<void> _sendLocationUpdate(LatLng position) async {
  try {
    final userId = await _getCurrentUserId();
    
    // Send via WebSocket for real-time updates
    _webSocketService.sendLocationUpdate(
      userId: userId,
      latitude: position.latitude,
      longitude: position.longitude,
      bookingId: _currentRide?.id,
    );
    
    // Also send via REST API as backup
    await _repository.updateDriverLocation(position, bookingId: _currentRide?.id);
  } catch (e) {
    print('Error sending location update: $e');
  }
}

Future<String> _getCurrentUserId() async {
  final sessionUser = SessionManager.instance.user;
  return sessionUser?.phoneNumber ?? 'unknown_driver';
}

  Future<void> _loadRideDetails(String rideId) async {
    _currentRide = await _repository.getActiveRideDetails(rideId);
    _isLoading = false;
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
    _locationSubscription?.cancel();
    _webSocketLocationSubscription?.cancel();
    _locationService.stopLocationTracking();
    _webSocketService.disconnect();
    super.dispose();
  }
}
