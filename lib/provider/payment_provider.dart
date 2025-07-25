import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sepesha_app/models/payment_method.dart';
import 'package:sepesha_app/services/payment_service.dart';
import 'package:sepesha_app/services/session_manager.dart';
import 'package:sepesha_app/services/preferences.dart';

class PaymentProvider with ChangeNotifier {
  // Private fields
  PaymentMethod? _selectedPaymentMethod;
  List<PaymentMethod> _availablePaymentMethods = [];
  WalletBalance? _walletBalance;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  PaymentMethod? get selectedPaymentMethod => _selectedPaymentMethod;
  List<PaymentMethod> get availablePaymentMethods => _availablePaymentMethods;
  WalletBalance? get walletBalance => _walletBalance;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Check if a payment method is selected
  bool get hasSelectedPaymentMethod => _selectedPaymentMethod != null;

  // Get selected payment method display name
  String get selectedPaymentMethodName =>
      _selectedPaymentMethod?.name ?? 'Select Payment Method';

  /// Initialize the provider with data
  /// Initialize the provider with data
  Future<void> initialize() async {
    setLoading(true);
    setError(null);

    try {
      debugPrint('=== PAYMENT PROVIDER INITIALIZE ===');

      // Debug: Check authentication status
      await _debugAuthStatus();

      // First: Load from session data (this should work)
      initializeFromSession();

      // Second: Load available payment methods (this is local, should work)
      await loadAvailablePaymentMethods();

      // Third: Try to get fresh data from server (may fail, but we have session fallback)
      try {
        await loadUserPreferredPaymentMethod();
        debugPrint('Successfully loaded preferred payment method from API');
      } catch (e) {
        debugPrint(
          'API call for preferred payment method failed (using session data): $e',
        );
      }

      // Fourth: Try to refresh wallet balance (may fail, but we have session fallback)
      try {
        await refreshWalletBalance();
        debugPrint('Successfully refreshed wallet balance from API');
      } catch (e) {
        debugPrint(
          'API call for wallet balance failed (using session data): $e',
        );
      }

      debugPrint('=== PAYMENT PROVIDER INITIALIZATION COMPLETE ===');
    } catch (e) {
      setError('Failed to initialize payment methods: $e');
      debugPrint('Error initializing payment provider: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Initialize from session data first
  /// Initialize from session data first
  void initializeFromSession() {
    try {
      final sessionUser = SessionManager.instance.user;
      if (sessionUser != null) {
        debugPrint('=== INITIALIZING PAYMENT FROM SESSION ===');

        // Set preferred payment method from session user
        if (sessionUser.preferredPaymentMethod != null) {
          final preferredType = PaymentMethodTypeExtension.fromString(
            sessionUser.preferredPaymentMethod!,
          );

          // Create metadata for wallet if needed
          Map<String, dynamic>? metadata;
          if (preferredType == PaymentMethodType.wallet &&
              sessionUser.walletBalanceTzs != null) {
            metadata = {
              'wallet_balance': {
                'balance_tzs': sessionUser.walletBalanceTzs,
                'balance_usd': sessionUser.walletBalanceUsd ?? 0.0,
              },
            };
          }

          _selectedPaymentMethod = PaymentMethod.fromType(
            preferredType,
            isDefault: true,
            metadata: metadata,
          );

          debugPrint(
            'Selected payment method from session: ${_selectedPaymentMethod?.name}',
          );
        }

        // Set wallet balance from session
        if (sessionUser.walletBalanceTzs != null) {
          _walletBalance = WalletBalance(
            balanceTzs: sessionUser.walletBalanceTzs!,
            balanceUsd: sessionUser.walletBalanceUsd ?? 0.0,
          );
          debugPrint(
            'Wallet balance from session: TZS ${_walletBalance?.balanceTzs}, USD ${_walletBalance?.balanceUsd}',
          );
        }
      }

      // Also check SessionManager direct properties as fallback
      final sessionPreferred = SessionManager.instance.preferredPaymentMethod;
      if (sessionPreferred != null && _selectedPaymentMethod == null) {
        final preferredType = PaymentMethodTypeExtension.fromString(
          sessionPreferred,
        );
        _selectedPaymentMethod = PaymentMethod.fromType(
          preferredType,
          isDefault: true,
        );
        debugPrint(
          'Fallback payment method from SessionManager: $sessionPreferred',
        );
      }

      final sessionWallet = SessionManager.instance.walletBalance;
      if (sessionWallet != null && _walletBalance == null) {
        _walletBalance = sessionWallet;
        debugPrint(
          'Fallback wallet from SessionManager: ${sessionWallet.balanceTzs}',
        );
      }

      debugPrint('=== SESSION INITIALIZATION COMPLETE ===');
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing payment from session: $e');
    }
  }

  /// Update user's preferred payment method via API
  Future<bool> updatePreferredPaymentMethod(PaymentMethod method) async {
    setLoading(true);
    setError(null);

    try {
      debugPrint('=== UPDATING PREFERRED PAYMENT METHOD ===');
      debugPrint('New method: ${method.name} (${method.type.value})');

      // Get user ID from auth key (uid from API response)
      final userId = await Preferences.instance.authKey;
      if (userId == null || userId.isEmpty) {
        setError('No user ID found');
        return false;
      }

      final token = await Preferences.instance.apiToken;
      if (token == null) {
        setError('No authentication token found');
        return false;
      }

      // Make API call to update profile
      // Make API call to update profile
      final url = Uri.parse(
        '${dotenv.env['BASE_URL']!}/user/update-profile/$userId',
      );

      final requestBody = {'preferred_payment_method': method.type.value};
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      debugPrint('=== UPDATE PREFERRED PAYMENT METHOD REQUEST ===');
      debugPrint('URL: $url');
      debugPrint('User ID: $userId');
      debugPrint('Headers: $headers');
      debugPrint('Request Body: ${jsonEncode(requestBody)}');
      debugPrint('Method Type: ${method.type.value}');
      debugPrint('Method Name: ${method.name}');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      debugPrint('=== UPDATE PREFERRED PAYMENT METHOD RESPONSE ===');
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Headers: ${response.headers}');
      debugPrint('Response Body: ${response.body}');
      debugPrint('================================================');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          // Update local state
          _selectedPaymentMethod = method;

          // Update session manager
          SessionManager.instance.setPreferredPaymentMethod(method.type.value);

          // Update user data in preferences
          final currentUserData = await Preferences.instance.userDataObject;
          if (currentUserData != null) {
            final updatedUser = currentUserData.copyWith(
              preferredPaymentMethod: method.type.value,
            );
            // Save updated user data back to preferences
            await Preferences.instance.saveUserData(updatedUser);
            // Also update session manager
            SessionManager.instance.setUser(updatedUser);
          }

          notifyListeners();
          debugPrint('Payment method updated successfully');
          return true;
        }
      }

      setError('Failed to update payment method');
      return false;
    } catch (e) {
      setError('Error updating payment method: $e');
      debugPrint('Error updating payment method: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Debug method to check authentication status
  Future<void> _debugAuthStatus() async {
    try {
      final token = await Preferences.instance.apiToken;
      final authKey = await Preferences.instance.authKey;
      final phone = await Preferences.instance.getString(PrefKeys.phoneNumber);

      debugPrint('=== PAYMENT PROVIDER DEBUG ===');
      debugPrint(
        'API Token: ${token != null ? "Present (${token.length} chars)" : "NULL"}',
      );
      debugPrint('Auth Key: ${authKey ?? "NULL"}');
      debugPrint('Phone: ${phone ?? "NULL"}');
      debugPrint('==============================');
    } catch (e) {
      debugPrint('Error in debug auth status: $e');
    }
  }

  /// Load all available payment methods
  Future<void> loadAvailablePaymentMethods() async {
    try {
      _availablePaymentMethods =
          PaymentService.instance.getAvailablePaymentMethods();
      notifyListeners();
    } catch (e) {
      setError('Failed to load payment methods');
      debugPrint('Error loading available payment methods: $e');
    }
  }

  /// Load user's preferred payment method from API
  Future<void> loadUserPreferredPaymentMethod() async {
    debugPrint('=== GET USER PREFERRED PAYMENT METHOD ===');
    try {
      debugPrint('Calling PaymentService.getUserPreferredPaymentMethod()...');
      final preferredMethod =
          await PaymentService.instance.getUserPreferredPaymentMethod();
      debugPrint('Received preferred method: $preferredMethod');

      if (preferredMethod != null) {
        _selectedPaymentMethod = preferredMethod;
        debugPrint(
          'Set selected payment method: ${_selectedPaymentMethod?.name}',
        );

        // Sync with session manager
        SessionManager.instance.setPreferredPaymentMethod(
          preferredMethod.type.value,
        );
        debugPrint(
          'Synced with session manager: ${preferredMethod.type.value}',
        );
        notifyListeners();
      } else {
        debugPrint('No preferred method returned from API');
      }
    } catch (e) {
      setError('Failed to load preferred payment method');
      debugPrint('Error loading user preferred payment method: $e');
    }
    debugPrint('====================================');
  }

  /// Select and update payment method
  /// Select and update payment method
  Future<void> selectPaymentMethod(PaymentMethod method) async {
    try {
      // Update via API
      final success = await updatePreferredPaymentMethod(method);

      if (!success && errorMessage == null) {
        // If API fails but no specific error, still update locally
        _selectedPaymentMethod = method;
        SessionManager.instance.setPreferredPaymentMethod(method.type.value);
        notifyListeners();
        debugPrint('Updated payment method locally only');
      }
    } catch (e) {
      setError('Failed to select payment method: $e');
      debugPrint('Error selecting payment method: $e');
    }
  }

  /// Refresh wallet balance from API
  Future<void> refreshWalletBalance() async {
    try {
      final balance = await PaymentService.instance.getWalletBalance();
      if (balance != null) {
        _walletBalance = balance;

        // Sync with session manager
        SessionManager.instance.setWalletBalance(balance);

        // Update wallet payment method metadata
        if (_selectedPaymentMethod?.type == PaymentMethodType.wallet) {
          _selectedPaymentMethod = _selectedPaymentMethod!.copyWith(
            metadata: {'wallet_balance': balance.toJson()},
          );
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing wallet balance: $e');
    }
  }

  /// Validate selected payment method for a given amount
  Future<bool> validateSelectedPaymentMethod(double amount) async {
    if (_selectedPaymentMethod == null) {
      setError('No payment method selected');
      return false;
    }

    try {
      final isValid = await PaymentService.instance.validatePaymentMethod(
        _selectedPaymentMethod!.type,
        amount: amount,
      );

      if (!isValid &&
          _selectedPaymentMethod!.type == PaymentMethodType.wallet) {
        setError('Insufficient wallet balance');
      }

      return isValid;
    } catch (e) {
      setError('Error validating payment method: $e');
      return false;
    }
  }

  /// Check if wallet has sufficient balance
  bool hasInsufficientWalletBalance(double amount) {
    if (_walletBalance == null ||
        _selectedPaymentMethod?.type != PaymentMethodType.wallet) {
      return false;
    }
    return !_walletBalance!.hasSufficientBalance(amount);
  }

  /// Get payment method by type
  PaymentMethod? getPaymentMethodByType(PaymentMethodType type) {
    try {
      return _availablePaymentMethods.firstWhere(
        (method) => method.type == type,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if payment method requires setup
  bool requiresSetup(PaymentMethodType type) {
    return PaymentService.instance.requiresSetup(type);
  }

  /// Set loading state
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Set error message
  void setError(String? error) {
    if (_errorMessage != error) {
      _errorMessage = error;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    setError(null);
  }

  /// Reset to default state
  void reset() {
    _selectedPaymentMethod = null;
    _availablePaymentMethods = [];
    _walletBalance = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Format wallet balance for display
  String getFormattedWalletBalance([String currency = 'TZS']) {
    if (_walletBalance == null) return 'TZS 0.00';

    final balance = _walletBalance!.getBalance(currency);
    return PaymentService.formatCurrency(balance, currency);
  }

  /// Check if wallet payment is available
  bool get isWalletPaymentAvailable {
    return _walletBalance != null && _walletBalance!.getBalance() > 0;
  }
}
