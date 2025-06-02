import 'package:flutter/foundation.dart';
import 'package:sepesha_app/Driver/dasboard/presentation/data/dashboard_repository.dart';
import 'package:sepesha_app/Driver/model/ride_model.dart';
import 'package:sepesha_app/Driver/model/user_model.dart';

class DashboardViewModel with ChangeNotifier {
  final DashboardRepository _repository = DashboardRepository();

  bool _isLoading = true;
  bool _isOnline = false;
  Driver? _driver;
  List<Ride> _pendingRides = [];
  Ride? _currentRide;

  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;
  Driver? get driver => _driver;
  List<Ride> get pendingRides => _pendingRides;
  Ride? get currentRide => _currentRide;

  DashboardViewModel() {
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.wait([_loadDriverData(), if (_isOnline) _loadPendingRides()]);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadDriverData() async {
    _driver = await _repository.getDriverData();
    notifyListeners();
  }

  Future<void> _loadPendingRides() async {
    _pendingRides = await _repository.getPendingRides();
    notifyListeners();
  }

  void toggleOnlineStatus() {
    _isOnline = !_isOnline;
    if (_isOnline) {
      _loadPendingRides();
    } else {
      _pendingRides = [];
      _currentRide = null;
    }
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
}
