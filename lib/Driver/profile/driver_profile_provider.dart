import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sepesha_app/Driver/model/user_model.dart';
import 'package:sepesha_app/repositories/user_profile_repository.dart';
import 'package:sepesha_app/Driver/dasboard/presentation/data/dashboard_repository.dart';

class DriverProfileProvider extends ChangeNotifier {
  final UserProfileRepository _userRepository = UserProfileRepository();
  final DashboardRepository _dashboardRepository = DashboardRepository();

  bool _isLoading = false;
  bool _isUpdating = false;
  String? _errorMessage;
  User? _driverData;

  // Getters
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;
  User? get driverData => _driverData;

  /// Load driver profile data
  Future<void> loadDriverProfile() async {
    _setLoading(true);
    _clearError();

    try {
      _driverData = await _dashboardRepository.getUserData();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load driver profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update driver profile using the same endpoint as regular users
  Future<bool> updateDriverProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    File? profilePhoto,
  }) async {
    _setUpdating(true);
    _clearError();

    try {
      // Split the name if it's provided as a single field
      String? fName = firstName;
      String? lName = lastName;
      
      if (firstName != null && firstName.contains(' ') && lastName == null) {
        final nameParts = firstName.split(' ');
        fName = nameParts.first;
        lName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      }

      final success = await _userRepository.updateUserProfile(
        firstName: fName,
        lastName: lName,
        email: email,
        profilePhoto: profilePhoto,
        // Note: Phone number updates might not be allowed by the API
      );

      if (success) {
        // Reload driver data to get updated information
        await loadDriverProfile();
        return true;
      } else {
        _setError('Failed to update driver profile');
        return false;
      }
    } catch (e) {
      _setError('Error updating driver profile: $e');
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setUpdating(bool updating) {
    _isUpdating = updating;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear all data (for logout)
  void clearData() {
    _driverData = null;
    _isLoading = false;
    _isUpdating = false;
    _errorMessage = null;
    notifyListeners();
  }
}