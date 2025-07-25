import 'package:flutter/material.dart';
import 'package:sepesha_app/models/booking.dart';
import 'package:sepesha_app/repositories/customer_history_repository.dart';

class CustomerHistoryProvider extends ChangeNotifier {
  final CustomerHistoryRepository _repository = CustomerHistoryRepository();

  List<Booking> _activeRides = [];
  List<Booking> _completedRides = [];
  List<Booking> _canceledRides = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Booking> get activeRides => _activeRides;
  List<Booking> get completedRides => _completedRides;
  List<Booking> get canceledRides => _canceledRides;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load all ride history
  Future<void> loadRideHistory() async {
    _setLoading(true);
    _clearError();

    try {
      // Load all categories in parallel
      final results = await Future.wait([
        _repository.getActiveRides(),
        _repository.getCompletedRides(),
        _repository.getCanceledRides(),
      ]);

      _activeRides = results[0];
      _completedRides = results[1];
      _canceledRides = results[2];

      notifyListeners();
    } catch (e) {
      _setError('Failed to load ride history: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh ride history
  Future<void> refreshRideHistory() async {
    await loadRideHistory();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
