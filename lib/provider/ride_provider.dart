import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:sepesha_app/models/ride_option.dart';

enum RideFlowState {
  idle,
  loadedLocation,
  searching,
  driverAssigned,
  arrived,
  onTrip,
}

class RideProvider with ChangeNotifier {
  RideFlowState? _currentState = RideFlowState.idle;
  String? _selectedRideType = 'Rideway';
  int _secondsToArrival = 180;
  Timer? _arrivalTimer;
  AnimationController? _loadingController;

  // Location related
  LatLng? _currentLocation;
  LatLng? _pickupLocation;
  LatLng? _destinationLocation;
  String _pickupAddress = 'Current location';
  String _destinationAddress = 'Where to?';
  String _distanceCovered = ''; // Added to store distance
  final bool _isLocationLoading = true;
  bool _isLoading = false;
  final bool _showRideResults = false;
  final bool _hideLocationCard = false;
  List<LatLng> _polylineCoordinates = []; // Added for polyline storage

  // Map controller
  final Completer<GoogleMapController> _mapController = Completer();

  // Ride details
  final String _driverName = 'John D.';
  final String _driverRating = '4.9 (256 rides)';
  final String _carDetails = 'Toyota Prius • Green • ABC-1234';
  final String _paymentMethod = 'Cash';

  // Filter related
  String _filterType = '4 Wheeler';

  // Getters
  RideFlowState get currentState => _currentState!;
  String get selectedRideType => _selectedRideType!;
  int get secondsToArrival => _secondsToArrival;
  AnimationController? get loadingController => _loadingController;
  LatLng? get currentLocation => _currentLocation;
  LatLng? get pickupLocation => _pickupLocation;
  LatLng? get destinationLocation => _destinationLocation;
  String get pickupAddress => _pickupAddress;
  String get destinationAddress => _destinationAddress;
  String get distanceCovered => _distanceCovered; // Added getter for distance
  bool get isLocationLoading => _isLocationLoading;
  bool get isLoading => _isLoading;
  bool get showRideResults => _showRideResults;
  bool get hideLocationCard => _hideLocationCard;
  Completer<GoogleMapController> get mapController => _mapController;
  String get driverName => _driverName;
  String get driverRating => _driverRating;
  String get carDetails => _carDetails;
  String get paymentMethod => _paymentMethod;
  String get filterType => _filterType;
  List<LatLng> get polylineCoordinates => _polylineCoordinates; // Added getter

  List<RideOption> get filteredRideOptions =>
      rideOptions.where((option) => option.vehicleType == _filterType).toList();

  // Methods
  void setIsLOading() {
    _isLoading = !_isLoading;
    notifyListeners();
  }

  void changeAppState(RideFlowState state) {
    _currentState = state;
    notifyListeners();
  }

  void filterRideType(String filterType) {
    _filterType = filterType;
    notifyListeners();
  }

  void setLoadingController(TickerProvider vsync) {
    _loadingController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  // In your RideProvider class
  Future<void> initializeLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Handle case when location services are disabled
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Handle case when permissions are denied
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Handle case when permissions are permanently denied
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      _currentLocation = LatLng(position.latitude, position.longitude);

      // Update the camera position
      if (mapController.isCompleted) {
        final controller = await mapController.future;
        controller.animateCamera(
          CameraUpdate.newLatLngZoom(currentLocation!, 14.5),
        );
      }

      notifyListeners();
    } catch (e) {
      // Handle errors
      print("Error getting location: $e");
    }
  }

  void setPickupLocation(LatLng location, String address) {
    _pickupLocation = location;
    _pickupAddress = address;
    notifyListeners();
  }

  Future<void> setDestination(LatLng destination, String address) async {
    _destinationLocation = destination;
    _destinationAddress = address;
    notifyListeners();

    // Move camera to show both locations
    if (_pickupLocation != null && _mapController.isCompleted) {
      final controller = await _mapController.future;
      final bounds = LatLngBounds(
        southwest: LatLng(
          min(_pickupLocation!.latitude, destination.latitude),
          min(_pickupLocation!.longitude, destination.longitude),
        ),
        northeast: LatLng(
          max(_pickupLocation!.latitude, destination.latitude),
          max(_pickupLocation!.longitude, destination.longitude),
        ),
      );
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    }
  }

  void updatePolylines(List<LatLng> coordinates) {
    _polylineCoordinates = coordinates;
    notifyListeners();
  }

  void selectRideType(String type) {
    _selectedRideType = type;
    notifyListeners();
  }

  Future<void> startSearching() async {
    if (_destinationLocation == null) return;

    _currentState = RideFlowState.searching;
    notifyListeners();

    // Simulate driver search
    await Future.delayed(const Duration(seconds: 3));

    _currentState = RideFlowState.driverAssigned;
    _startArrivalTimer();
    notifyListeners();

    // Move camera to pickup location
    if (_mapController.isCompleted) {
      final controller = await _mapController.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_pickupLocation!, 14.5),
      );
    }
  }

  void _startArrivalTimer() {
    _arrivalTimer?.cancel();
    _secondsToArrival = 180;
    _arrivalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentState == RideFlowState.driverAssigned &&
          _secondsToArrival > 0) {
        _secondsToArrival--;
        notifyListeners();

        if (_secondsToArrival % 30 == 0) {
          _updateDriverLocation();
        }
      }
    });
  }

  void _updateDriverLocation() {
    notifyListeners();
  }

  void driverArrived() {
    _currentState = RideFlowState.arrived;
    _arrivalTimer?.cancel();
    notifyListeners();
  }

  void startTrip() {
    _currentState = RideFlowState.onTrip;
    notifyListeners();
  }

  void resetToInitialState() {
    _currentState = RideFlowState.idle;
    _secondsToArrival = 180;
    _polylineCoordinates = []; // Clear polylines
    _destinationLocation = null;
    _destinationAddress = 'Where to?';
    _arrivalTimer?.cancel();
    notifyListeners();
  }

  void disposeResources() {
    _loadingController?.dispose();
    _arrivalTimer?.cancel();
  }

  List<RideOption> get rideOptions => [
    RideOption(
      'Rideway',
      'TZS 10.99',
      Icons.directions_car,
      'Affordable rides, all to yourself',
      Colors.grey,
      '4 Wheeler',
    ),
    RideOption(
      'Rideway SUV',
      'TZS 32.86',
      Icons.directions_car,
      'Luxury rides',
      Colors.grey,
      '4 Wheeler',
    ),
    RideOption(
      'Rideway Bike',
      'TZS 10.99',
      Icons.directions_bike,
      'Affordable rides, all to yourself',
      Colors.grey,
      '2 Wheeler',
    ),
    RideOption(
      'Rideway Bike SUV',
      'TZS 32.86',
      Icons.directions_bike,
      'Luxury rides',
      Colors.grey,
      '2 Wheeler',
    ),
  ];

  /// Calculates the total distance covered between pickup and destination using Google Directions API.
  /// Returns the distance as a string (e.g., '5.2 km') or an error message.
  Future<String> calculateDistanceCovered(String mapKey) async {
    if (_pickupLocation == null || _destinationLocation == null) {
      return "Location(s) not set";
    }
    final origin = _pickupLocation!;
    final destination = _destinationLocation!;
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$mapKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        return "Could not get distance";
      }
      final data = jsonDecode(response.body);
      if (data["status"] != "OK") {
        return "Could not get distance";
      }
      final distanceText = data["routes"][0]["legs"][0]["distance"]["text"];
      // Store in provider for UI access
      _distanceCovered = distanceText;
      notifyListeners();
      return distanceText;
    } catch (e) {
      return "Could not get distance";
    }
  }
}
