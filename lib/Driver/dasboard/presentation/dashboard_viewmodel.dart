import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sepesha_app/Driver/dasboard/presentation/data/dashboard_repository.dart';
import 'package:sepesha_app/Driver/model/ride_model.dart';
import 'package:sepesha_app/Driver/model/user_model.dart';
import 'package:sepesha_app/services/location_service.dart';

class DashboardViewModel with ChangeNotifier {
  final DashboardRepository _repository = DashboardRepository();
  final LocationService _locationService = LocationService();

  bool _isLoading = true;
  bool _isOnline = false;
  bool _hasLocationPermission = false;
  bool _isLocationServiceEnabled = false;
  User? _driver;
  List<Ride> _pendingRides = [];
  Ride? _currentRide;
  String? _locationError;
  LatLng? _currentLocation;

  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;
  bool get hasLocationPermission => _hasLocationPermission;
  bool get isLocationServiceEnabled => _isLocationServiceEnabled;
  User? get driver => _driver;
  List<Ride> get pendingRides => _pendingRides;
  Ride? get currentRide => _currentRide;
  String? get locationError => _locationError;
  LatLng? get currentLocation => _currentLocation;

  DashboardViewModel() {
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.wait([
      _loadDriverData(),
      _checkLocationPermissions(),
      if (_isOnline) _loadPendingRides()
    ]);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadDriverData() async {
    // _driver = await _repository.getDriverData();
    notifyListeners();
  }

  Future<void> _loadPendingRides() async {
    _pendingRides = await _repository.getPendingRides();
    notifyListeners();
  }

  Future<void> _checkLocationPermissions() async {
  try {
    // Check if location services are enabled
    _isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!_isLocationServiceEnabled) {
      _locationError = 'Location services are disabled. Please enable them in device settings.';
      _hasLocationPermission = false;
      return;
    }

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      _locationError = 'Location permissions are permanently denied. Please enable them in device settings.';
      _hasLocationPermission = false;
      return;
    }

    if (permission == LocationPermission.denied) {
      _locationError = 'Location permissions are required to go online.';
      _hasLocationPermission = false;
      return;
    }

    // Permissions granted - now get current location
    _hasLocationPermission = true;
    _locationError = null;
    
    // Get current location
    await _getCurrentLocation();

  } catch (e) {
    _locationError = 'Error checking location permissions: $e';
    _hasLocationPermission = false;
  }
}

  Future<bool> toggleOnlineStatus() async {
    // If trying to go online, check location permissions first
    if (!_isOnline) {
      await _checkLocationPermissions();

      if (!_hasLocationPermission || !_isLocationServiceEnabled) {
        // Don't allow going online without location permissions
        return false;
      }
    }

    _isOnline = !_isOnline;
    if (_isOnline) {
      _loadPendingRides();
    } else {
      _pendingRides = [];
      _currentRide = null;
    }
    notifyListeners();
    return true;
  }

  Future<void> requestLocationPermissions() async {
  await _checkLocationPermissions();
  notifyListeners();
}

  /// Check if the driver can go online (has all required permissions)
  bool get canGoOnline => _hasLocationPermission && _isLocationServiceEnabled;

  /// Force refresh of all permission statuses
  Future<void> refreshPermissionStatus() async {
    await _checkLocationPermissions();
    notifyListeners();
  }

  Future<void> acceptRide(Ride ride) async {
    await _repository.acceptRide(ride.id);
    _pendingRides.removeWhere((r) => r.id == ride.id);
    _currentRide = ride;
    notifyListeners();
  }

  Future<void> rejectRide(Ride ride) async {
    await _repository.rejectRide(ride.id);
    _pendingRides.removeWhere((r) => r.id == ride.id);
    notifyListeners();
  }

  Future<void> completeRide() async {
    if (_currentRide != null) {
      await _repository.completeRide(_currentRide!.id);
      _currentRide = null;
      if (_isOnline) {
        await _loadPendingRides();
      }
      notifyListeners();
    }
  }

  Future<void> _getCurrentLocation() async {
  try {
    print('Attempting to get current location...');
    if (_hasLocationPermission && _isLocationServiceEnabled) {
      print('Permissions granted, getting position...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentLocation = LatLng(position.latitude, position.longitude);
      print('Current location obtained: ${_currentLocation?.latitude}, ${_currentLocation?.longitude}');
      notifyListeners();
    } else {
      print('Location permissions not granted: hasPermission=$_hasLocationPermission, serviceEnabled=$_isLocationServiceEnabled');
    }
  } catch (e) {
    print('Error getting current location: $e');
  }
}
}
