import 'package:flutter/material.dart';
import 'package:sepesha_app/models/driver_review.dart';
import 'package:sepesha_app/services/rating_service.dart';

class RatingProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> submitRating({
    required String driverId,
    required int rating,
    required String review,
  }) async {
    _setLoading(true);

    try {
      final result = await RatingService.createDriverReview(
        driverId: driverId,
        rating: rating,
        review: review,
      );

      _setLoading(false);
      return result != null;
    } catch (e) {
      _setError('Failed to submit rating: $e');
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
