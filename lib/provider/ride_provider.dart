import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sepesha_app/models/ride_option.dart';
import 'package:sepesha_app/provider/payment_provider.dart';
import 'package:sepesha_app/services/preferences.dart';

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
  PaymentProvider? _paymentProvider;

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

  // Real API data
  Map<String, dynamic>? _fareData;
  List<Map<String, dynamic>> _availableDrivers = [];
  Map<String, dynamic>? _selectedDriver;
  String? _currentBookingId;

  // Categories data
  List<Map<String, dynamic>> _categories = [];
  bool _categoriesLoading = false;
  String? _selectedCategoryId;

  // Filter related
  String _filterType = '4 Wheeler';

  // Getters
  List<Map<String, dynamic>> get categories => _categories;
  bool get categoriesLoading => _categoriesLoading;
  String? get selectedCategoryId => _selectedCategoryId;
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
  String? get currentBookingId => _currentBookingId;
  String? get currentDriverId => _selectedDriver?['driver_id'];
  String get driverName =>
      _selectedDriver?['driver_name'] ?? 'Finding driver...';
  String get driverRating =>
      _selectedDriver != null
          ? '${_selectedDriver!['rating']?.toStringAsFixed(1)} (${_selectedDriver!['total_trips']} trips)'
          : 'No rating';
  String get carDetails => _buildCarDetails();
  double get estimatedFare => _getEstimatedFare();
  String get filterType => _filterType;
  List<LatLng> get polylineCoordinates => _polylineCoordinates; // Added getter

  List<RideOption> get filteredRideOptions =>
      rideOptions.where((option) => option.vehicleType == _filterType).toList();
  String get paymentMethod {
    if (_paymentProvider?.selectedPaymentMethod != null) {
      return _paymentProvider!.selectedPaymentMethodName;
    }
    return 'Cash'; // Default fallback
  }

  void setPaymentProvider(PaymentProvider paymentProvider) {
    _paymentProvider = paymentProvider;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    debugPrint('=== FETCH CATEGORIES REQUEST ===');
    _categoriesLoading = true;
    notifyListeners();

    try {
      final token = await Preferences.instance.apiToken;
      final url = '${dotenv.env['BASE_URL']}/categories';
      debugPrint('URL: $url');
      debugPrint(
        'Headers: {Content-Type: application/json, Authorization: Bearer $token}',
      );

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Categories Response Status: ${response.statusCode}');
      debugPrint('Categories Response Body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('Categories details: $_categories');
        final data = jsonDecode(response.body);
        if (data['status']) {
          _categories = List<Map<String, dynamic>>.from(data['data']);
          debugPrint('Categories loaded: ${_categories.length} items');
        }
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      _categoriesLoading = false;
      notifyListeners();
    }
    debugPrint('=== FETCH CATEGORIES COMPLETED ===');
  }

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

  String _buildCarDetails() {
    if (_selectedDriver?['vehicle_info'] != null) {
      final vehicle = _selectedDriver!['vehicle_info'];
      return '${vehicle['make']} ${vehicle['model']} • ${vehicle['plate_number']}';
    }
    return 'Vehicle details loading...';
  }

  double _getEstimatedFare() {
    if (_fareData?['fare_estimates'] != null) {
      final estimates = _fareData!['fare_estimates'] as List;
      // Find fare for selected vehicle type
      for (var estimate in estimates) {
        if (estimate['vehicle_type'].toString().toLowerCase().contains(
          _filterType.toLowerCase(),
        )) {
          return estimate['total_fare']?.toDouble() ?? 0.0;
        }
      }
      // Fallback to first estimate
      return estimates.isNotEmpty
          ? estimates.first['total_fare']?.toDouble() ?? 0.0
          : 0.0;
    }
    return 0.0;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> calculateFare() async {
    if (_pickupLocation == null || _destinationLocation == null) {
      debugPrint('Error: Missing pickup or destination location');
      return;
    }

    debugPrint('=== CALCULATE FARE REQUEST ===');
    _setLoading(true);
    try {
      final token = await Preferences.instance.apiToken;
      final url = '${dotenv.env['BASE_URL']}/calculate-fare';
      final requestBody = {
        'pickup_latitude': _pickupLocation!.latitude,
        'pickup_longitude': _pickupLocation!.longitude,
        'delivery_latitude': _destinationLocation!.latitude,
        'delivery_longitude': _destinationLocation!.longitude,
      };

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      debugPrint('URL: $url');
      debugPrint('Headers: $headers');
      debugPrint('Request Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Headers: ${response.headers}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status']) {
          _fareData = data['data'];
          debugPrint('Fare data saved: $_fareData');
          notifyListeners();
        } else {
          debugPrint('API returned status false: ${data['message']}');
          _setMockFareData();
        }
      } else {
        debugPrint('HTTP Error: ${response.statusCode}');
        _setMockFareData();
      }
    } catch (e) {
      debugPrint('Exception calculating fare: $e');
      _setMockFareData();
    } finally {
      _setLoading(false);
    }
    debugPrint('=== CALCULATE FARE COMPLETED ===');
  }

  void _setMockFareData() {
    debugPrint('Setting mock fare data for testing');
    _fareData = {
      'distance_km': 5.2,
      'estimated_duration_minutes': 15,
      'fare_estimates': [
        {
          'vehicle_type': '2 Wheeler',
          'base_fare': 2000.0,
          'distance_fare': 1500.0,
          'total_fare': 3500.0,
        },
        {
          'vehicle_type': '4 Wheeler',
          'base_fare': 3000.0,
          'distance_fare': 2500.0,
          'total_fare': 5500.0,
        },
      ],
    };
    notifyListeners();
  }

  Future<void> findAvailableDrivers() async {
    if (_pickupLocation == null) {
      debugPrint('Error: No pickup location set');
      return;
    }

    debugPrint('=== FIND AVAILABLE DRIVERS REQUEST ===');
    _setLoading(true);
    try {
      final token = await Preferences.instance.apiToken;
      final url = '${dotenv.env['BASE_URL']}/find-drivers';
      // Find the matching vehicle type ID from fare data
      // Use the selected category ID directly
      String? feeCategoryId = _selectedCategoryId;

      final requestBody = {
        'pickup_latitude': _pickupLocation!.latitude,
        'pickup_longitude': _pickupLocation!.longitude,
        'vehicle_type': _filterType.toLowerCase(),
        'radius_km': 5,
        'fee_category_id': feeCategoryId,
      };
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      debugPrint('URL: $url');
      debugPrint('Headers: $headers');
      debugPrint('Request Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Headers: ${response.headers}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status']) {
          _availableDrivers = List<Map<String, dynamic>>.from(
            data['data']['available_drivers'] ?? [],
          );
          debugPrint('Available drivers parsed: $_availableDrivers');
          notifyListeners();
        } else {
          debugPrint('API returned status false: ${data['message']}');
        }
      } else {
        debugPrint('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception finding drivers: $e');
    } finally {
      _setLoading(false);
    }
    debugPrint('=== FIND AVAILABLE DRIVERS COMPLETED ===');
  }

  Future<void> createBooking() async {
    if (_pickupLocation == null || _destinationLocation == null) {
      debugPrint('Error: Missing pickup or destination location');
      return;
    }

    debugPrint('=== CREATE RIDE BOOKING REQUEST ===');
    _setLoading(true);
    try {
      final token = await Preferences.instance.apiToken;
      final url = '${dotenv.env['BASE_URL']}/create-ride-booking';
      final requestBody = {
        'pickup_latitude': _pickupLocation!.latitude,
        'pickup_longitude': _pickupLocation!.longitude,
        'delivery_latitude': _destinationLocation!.latitude,
        'delivery_longitude': _destinationLocation!.longitude,
        'pickup_location': _pickupAddress,
        'delivery_location': _destinationAddress,
        'distance_km': _fareData?['distance_km'] ?? 0,
        'estimated_fare': estimatedFare,
        'payment_method':
            _paymentProvider?.selectedPaymentMethod?.type.name ?? 'cash',
        'customer_id': await Preferences.instance.authKey,
        'fee_category_id': _selectedCategoryId,
      };
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      debugPrint('URL: $url');
      debugPrint('Headers: $headers');
      debugPrint('Request Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Headers: ${response.headers}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status']) {
          _currentBookingId = data['data']['booking_id'];
          debugPrint('Booking ID saved: $_currentBookingId');
          notifyListeners();
        } else {
          debugPrint('API returned status false: ${data['message']}');
        }
      } else {
        debugPrint('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception creating booking: $e');
    } finally {
      _setLoading(false);
    }
    debugPrint('=== CREATE RIDE BOOKING COMPLETED ===');
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
      debugPrint("Error getting location: $e");
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

  void selectRideType(String rideType, {String? categoryId}) {
    _selectedRideType = rideType;
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  Future<void> startSearching() async {
    if (_destinationLocation == null) {
      debugPrint('Error: No destination location set');
      return;
    }

    debugPrint('=== STARTING RIDE SEARCH ===');
    _currentState = RideFlowState.searching;
    notifyListeners();

    try {
      // Step 1: Calculate fare
      debugPrint('Step 1: Calculating fare...');
      await calculateFare();
      debugPrint('Fare calculation completed. Fare data: $_fareData');

      // Step 2: Find available drivers
      debugPrint('Step 2: Finding available drivers...');
      await findAvailableDrivers();
      debugPrint(
        'Driver search completed. Found ${_availableDrivers.length} drivers',
      );

      // Step 3: Create booking
      debugPrint('Step 3: Creating booking...');
      await createBooking();
      debugPrint('Booking creation completed. Booking ID: $_currentBookingId');

      // Step 4: Assign driver (simulate or use first available)
      if (_availableDrivers.isNotEmpty) {
        _selectedDriver = _availableDrivers.first;
        debugPrint('Driver assigned: ${_selectedDriver?['name']}');
        _currentState = RideFlowState.driverAssigned;
        _startArrivalTimer();
      } else {
        // No drivers available - use mock driver for testing
        debugPrint(
          'No drivers available from API, using mock driver for testing',
        );
        _selectedDriver = {
          'driver_id': 'mock_driver_1',
          'driver_name': 'John Doe',
          'phone': '+255123456789',
          'rating': 4.5,
          'total_trips': 150,
          'estimated_arrival_minutes': 5,
          'distance_km': 2.5,
          'vehicle_info': {
            'make': 'Toyota',
            'model': 'Corolla',
            'plate_number': 'T123ABC',
            'vehicle_type': _filterType,
          },
        };
        _currentState = RideFlowState.driverAssigned;
        _startArrivalTimer();
      }
    } catch (e) {
      debugPrint('Error in startSearching: $e');
      _currentState = RideFlowState.idle;
    }

    debugPrint('=== RIDE SEARCH COMPLETED ===');
    notifyListeners();
  }

  void _startArrivalTimer() {
    _arrivalTimer?.cancel();

    // Use real ETA from driver data
    int estimatedArrival = _selectedDriver?['estimated_arrival_minutes'] ?? 180;
    _secondsToArrival = estimatedArrival * 60; // Convert to seconds

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
    _loadingController = null;
    _arrivalTimer?.cancel();
    _arrivalTimer = null;
  }

  List<RideOption> get rideOptions => [
    RideOption(
      'Rideway',
      'TZS 10.99',
      Icons.directions_car,
      'Affordable rides, all to yourself',
      Colors.grey,
      '4 Wheeler',
      null,
    ),
    RideOption(
      'Rideway SUV',
      'TZS 32.86',
      Icons.directions_car,
      'Luxury rides',
      Colors.grey,
      '4 Wheeler',
      null,
    ),
    RideOption(
      'Rideway Bike',
      'TZS 10.99',
      Icons.directions_bike,
      'Affordable rides, all to yourself',
      Colors.grey,
      '2 Wheeler',
      null,
    ),
    RideOption(
      'Rideway Bike SUV',
      'TZS 32.86',
      Icons.directions_bike,
      'Luxury rides',
      Colors.grey,
      '2 Wheeler',
      null,
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
