import 'package:flutter/material.dart';
import 'package:sepesha_app/models/booking.dart';
import 'package:sepesha_app/services/ride_services.dart';

class RidesProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';

  // Ride history lists
  List<Booking> _activeRides = [];
  List<Booking> _completedRides = [];
  List<Booking> _canceledRides = [];

  // Getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<Booking> get activeRides => _activeRides;
  List<Booking> get completedRides => _completedRides;
  List<Booking> get canceledRides => _canceledRides;

  // Load all rides
  Future<void> loadAllRides() async {
    await Future.wait([
      loadActiveRides(),
      loadCompletedRides(),
      loadCanceledRides(),
    ]);
  }

  // Load active rides
  Future<void> loadActiveRides() async {
    _setLoading(true);
    try {
      final rides = await RideServices.getBookings(status: 'active');
      _activeRides = rides.map((json) => Booking.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load active rides: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load completed rides
  Future<void> loadCompletedRides() async {
    _setLoading(true);
    try {
      final rides = await RideServices.getBookings(status: 'completed');
      _completedRides = rides.map((json) => Booking.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load completed rides: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load canceled rides
  Future<void> loadCanceledRides() async {
    _setLoading(true);
    try {
      final rides = await RideServices.getBookings(status: 'canceled');
      _canceledRides = rides.map((json) => Booking.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load canceled rides: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Cancel a ride
  Future<bool> cancelRide(String bookingId, String reason) async {
    _setLoading(true);
    try {
      final success = await RideServices.cancelBooking(
        bookingId: bookingId,
        reason: reason,
      );
      if (success) {
        // Move the ride from active to canceled
        final canceledRide = _activeRides.firstWhere(
          (ride) => ride.id == bookingId,
        );
        _activeRides.removeWhere((ride) => ride.id == bookingId);
        canceledRide.status = BookingStatus.canceled;
        _canceledRides.add(canceledRide);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Failed to cancel ride: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Rate a driver
  Future<bool> rateDriver(String driverId, int rating, String review) async {
    _setLoading(true);
    try {
      final success = await RideServices.rateDriver(
        driverId: driverId,
        rating: rating,
        review: review,
      );
      return success;
    } catch (e) {
      _setError('Failed to rate driver: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
