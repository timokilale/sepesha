import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sepesha_app/services/auth_services.dart';
import 'package:sepesha_app/services/preferences.dart';

class TokenManager {
  TokenManager._();
  static final TokenManager _instance = TokenManager._();
  static TokenManager get instance => _instance;

  Timer? _refreshTimer;
  bool _isRefreshing = false;

  // Initialize token refresh mechanism
  Future<void> initialize() async {
    await _scheduleTokenRefresh();
  }

  // Schedule token refresh based on expiration time
  Future<void> _scheduleTokenRefresh() async {
    // Cancel any existing timer
    _refreshTimer?.cancel();

    final expiryString = await Preferences.instance.tokenExpiry;
    final token = await Preferences.instance.apiToken;

    // If no token or expiry, don't schedule refresh
    if (token == null || expiryString == null) {
      return;
    }

    try {
      final expiry = DateTime.parse(expiryString);
      final now = DateTime.now();

      // If token is already expired, refresh immediately
      if (expiry.isBefore(now)) {
        await _refreshToken();
        return;
      }

      // Calculate time until refresh (5 minutes before expiration)
      final timeUntilRefresh = expiry.difference(now) - Duration(minutes: 5);

      // If less than 5 minutes until expiration, refresh now
      if (timeUntilRefresh.isNegative) {
        await _refreshToken();
        return;
      }

      // Schedule refresh
      _refreshTimer = Timer(timeUntilRefresh, () async {
        await _refreshToken();
      });

      if (kDebugMode) {
        print('Token refresh scheduled in ${timeUntilRefresh.inMinutes} minutes');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error scheduling token refresh: $e');
      }
    }
  }

  // Refresh the token
  Future<void> _refreshToken() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    try {
      final newToken = await AuthServices.getNewAccessToken();
      if (newToken != null) {
        // Update token expiration (assuming 1 hour validity)
        final newExpiry = DateTime.now().add(Duration(hours: 1)).toIso8601String();
         Preferences.instance.save(PrefKeys.tokenExpiry, newExpiry);

        if (kDebugMode) {
          print('Token refreshed successfully');
        }
      } else {
        if (kDebugMode) {
          print('Failed to refresh token');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing token: $e');
      }
    } finally {
      _isRefreshing = false;
      // Schedule next refresh
      await _scheduleTokenRefresh();
    }
  }

  // Force refresh token
  Future<bool> forceRefreshToken() async {
    try {
      final newToken = await AuthServices.getNewAccessToken();
      if (newToken != null) {
        // Update token expiration (assuming 1 hour validity)
        final newExpiry = DateTime.now().add(Duration(hours: 1)).toIso8601String();
         Preferences.instance.save(PrefKeys.tokenExpiry, newExpiry);
        await _scheduleTokenRefresh();
        return true;
      } else {
        // Token refresh failed, check if token exists
        final token = await Preferences.instance.apiToken;
        if (token == null) {
          // Token doesn't exist, user should be redirected to auth screen
          // This will be handled by the app's navigation logic
          if (kDebugMode) {
            print('Token refresh failed and no token exists. User should be redirected to auth screen.');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error forcing token refresh: $e');
      }
    }
    return false;
  }

  // Check if token exists and is valid
  Future<bool> isAuthenticated() async {
    final token = await Preferences.instance.apiToken;
    final expiryString = await Preferences.instance.tokenExpiry;

    if (token == null || expiryString == null) {
      return false;
    }

    try {
      final expiry = DateTime.parse(expiryString);
      final now = DateTime.now();

      // If token is expired, try to refresh it
      if (expiry.isBefore(now)) {
        return await forceRefreshToken();
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking authentication: $e');
      }
      return false;
    }
  }

  // Dispose timer
  void dispose() {
    _refreshTimer?.cancel();
  }
}
