import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sepesha_app/models/user_data.dart';
import 'package:sepesha_app/repositories/user_profile_repository.dart';
import 'package:sepesha_app/services/session_manager.dart';

class UserProfileProvider extends ChangeNotifier {
  final UserProfileRepository _repository = UserProfileRepository();

  // User profile data
  UserData? _userProfile;
  String? _profilePhotoUrl;
  double _walletBalanceTzs = 0.0;
  double _walletBalanceUsd = 0.0;
  String _preferredPaymentMethod = 'cash';
  bool _isVerified = false;
  int _totalRides = 0;
  double _averageRating = 0.0;

  // Loading and error states
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _errorMessage;

  // Getters
  UserData? get userProfile => _userProfile;
  String? get profilePhotoUrl => _profilePhotoUrl;
  double get walletBalanceTzs => _walletBalanceTzs;
  double get walletBalanceUsd => _walletBalanceUsd;
  String get preferredPaymentMethod => _preferredPaymentMethod;
  bool get isVerified => _isVerified;
  int get totalRides => _totalRides;
  double get averageRating => _averageRating;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;

  /// Load user profile from API
  Future<void> loadUserProfile() async {
    _setLoading(true);
    _clearError();

    try {
      final profileData = await _repository.getUserProfile();

      if (profileData != null) {
        _userProfile = profileData['user'];
        _profilePhotoUrl = profileData['profile_photo_url'];
        _walletBalanceTzs =
            double.tryParse(
              profileData['wallet_balance_tzs']?.toString() ?? '0',
            ) ??
            0.0;
        _walletBalanceUsd =
            double.tryParse(
              profileData['wallet_balance_usd']?.toString() ?? '0',
            ) ??
            0.0;
        _preferredPaymentMethod =
            profileData['preferred_payment_method'] ?? 'cash';
        _isVerified =
            profileData['is_verified'] == 1 ||
            profileData['is_verified'] == true;
        _totalRides = profileData['total_rides'] ?? 0;
        _averageRating =
            double.tryParse(profileData['average_rating']?.toString() ?? '0') ??
            0.0;

        // Update session manager with latest data
        if (_userProfile != null) {
          SessionManager.instance.setUser(_userProfile!);
        }
      }
    } catch (e) {
      _setError('Failed to load profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update user profile information
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? middleName,
    String? email,
    String? preferredPaymentMethod,
    File? profilePhoto,
  }) async {
    _setUpdating(true);
    _clearError();

    try {
      final success = await _repository.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        middleName: middleName,
        email: email,
        preferredPaymentMethod: preferredPaymentMethod,
        profilePhoto: profilePhoto,
      );

      if (success) {
        // Reload profile to get updated data
        await loadUserProfile();
        return true;
      } else {
        _setError('Failed to update profile');
        return false;
      }
    } catch (e) {
      _setError('Error updating profile: $e');
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  /// Update only the preferred payment method
  Future<bool> updatePaymentMethod(String paymentMethod) async {
    _setUpdating(true);
    _clearError();

    try {
      final success = await _repository.updateUserProfile(
        preferredPaymentMethod: paymentMethod,
      );

      if (success) {
        _preferredPaymentMethod = paymentMethod;
        notifyListeners();
        return true;
      } else {
        _setError('Failed to update payment method');
        return false;
      }
    } catch (e) {
      _setError('Error updating payment method: $e');
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  /// Refresh profile data
  Future<void> refreshProfile() async {
    await loadUserProfile();
  }

  /// Initialize profile from session data
  void initializeFromSession() {
    try {
      final sessionUser = SessionManager.instance.user;
      if (sessionUser != null) {
        _userProfile = sessionUser;
        notifyListeners();
      }
    } catch (e) {
      // Session might be empty, that's okay
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

  /// Clear all profile data (for logout)
  void clearProfile() {
    _userProfile = null;
    _profilePhotoUrl = null;
    _walletBalanceTzs = 0.0;
    _walletBalanceUsd = 0.0;
    _preferredPaymentMethod = 'cash';
    _isVerified = false;
    _totalRides = 0;
    _averageRating = 0.0;
    _isLoading = false;
    _isUpdating = false;
    _errorMessage = null;
    notifyListeners();
  }
}
