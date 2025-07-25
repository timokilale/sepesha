import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:sepesha_app/models/payment_method.dart';
import 'package:sepesha_app/services/preferences.dart';
import 'package:sepesha_app/services/session_manager.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();
  static PaymentService get instance => _instance;
  final String _baseUrl = dotenv.env['BASE_URL'] ?? '';

  List<PaymentMethod> getAvailablePaymentMethods() {
    debugPrint('=== GET AVAILABLE PAYMENT METHODS ===');
    final methods = [
      PaymentMethod.fromType(PaymentMethodType.cash, isEnabled: true),
      PaymentMethod.fromType(PaymentMethodType.wallet, isEnabled: true),
      PaymentMethod.fromType(PaymentMethodType.card, isEnabled: true),
      PaymentMethod.fromType(PaymentMethodType.bank, isEnabled: true),
    ];
    debugPrint('Available Payment Methods: $methods');
    debugPrint('====================================');
    return methods;
  }

  Future<PaymentMethod?> getUserPreferredPaymentMethod() async {
    debugPrint('=== GET USER PREFERRED PAYMENT METHOD ===');
    try {
      final token = await Preferences.instance.apiToken;
      if (token == null) {
        debugPrint('No API token available');
        return null;
      }

      debugPrint('Calling _getUserProfile()...');
      final userProfile = await getUserProfile();
      debugPrint('User profile result: $userProfile');

      if (userProfile != null &&
          userProfile['preferred_payment_method'] != null) {
        debugPrint(
          'Found preferred payment method in profile: ${userProfile['preferred_payment_method']}',
        );
        final preferredType = PaymentMethodTypeExtension.fromString(
          userProfile['preferred_payment_method'],
        );

        Map<String, dynamic>? metadata;
        if (preferredType == PaymentMethodType.wallet) {
          metadata = {
            'wallet_balance': WalletBalance.fromJson(userProfile).toJson(),
          };
          debugPrint('Added wallet metadata: $metadata');
        }

        final method = PaymentMethod.fromType(
          preferredType,
          isDefault: true,
          metadata: metadata,
        );
        debugPrint('Preferred Payment Method: $method');
        debugPrint('====================================');
        return method;
      }

      debugPrint(
        'No preferred payment method found in profile, using default cash',
      );
      final defaultMethod = PaymentMethod.fromType(
        PaymentMethodType.cash,
        isDefault: true,
      );
      debugPrint('Default Payment Method: $defaultMethod');
      debugPrint('====================================');
      return defaultMethod;
    } catch (e) {
      debugPrint('Error getting user preferred payment method: $e');
      return PaymentMethod.fromType(PaymentMethodType.cash, isDefault: true);
    }
  }

  Future<void> syncWithSession() async {
    debugPrint('=== SYNC WITH SESSION ===');
    try {
      final preferredMethod = await getUserPreferredPaymentMethod();
      final walletBalance = await getWalletBalance();

      if (preferredMethod != null) {
        SessionManager.instance.setPreferredPaymentMethod(
          preferredMethod.type.value,
        );
        debugPrint(
          'Synced Preferred Payment Method: ${preferredMethod.type.value}',
        );
      }

      if (walletBalance != null) {
        SessionManager.instance.setWalletBalance(walletBalance);
        debugPrint('Synced Wallet Balance: $walletBalance');
      }
    } catch (e) {
      debugPrint('Error syncing with session: $e');
    }
    debugPrint('========================');
  }

  Future<bool> updateUserPreferredPaymentMethod(
    PaymentMethodType paymentMethod,
  ) async {
    debugPrint('=== UPDATE USER PREFERRED PAYMENT METHOD ===');
    try {
      final token = await Preferences.instance.apiToken;
      if (token == null) {
        debugPrint('No API token available');
        return false;
      }

      final userId = await _getUserId();
      if (userId == null) {
        debugPrint('No user ID available');
        return false;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/user/update-profile/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'preferred_payment_method': paymentMethod.value}),
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          debugPrint('Payment method updated successfully');
          debugPrint('====================================');
          return true;
        }
      }

      debugPrint('Failed to update payment method: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error updating preferred payment method: $e');
      return false;
    }
  }

  Future<WalletBalance?> getWalletBalance() async {
    debugPrint('=== GET WALLET BALANCE ===');
    try {
      final userProfile = await getUserProfile();
      if (userProfile != null) {
        final walletBalance = WalletBalance.fromJson(userProfile);
        debugPrint('Wallet Balance: $walletBalance');
        debugPrint('========================');
        return walletBalance;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting wallet balance: $e');
      return null;
    }
  }

  Future<bool> validatePaymentMethod(
    PaymentMethodType paymentMethod, {
    double? amount,
  }) async {
    debugPrint('=== VALIDATE PAYMENT METHOD ===');
    try {
      switch (paymentMethod) {
        case PaymentMethodType.cash:
          debugPrint('Cash payment method is always valid');
          debugPrint('===============================');
          return true;
        case PaymentMethodType.wallet:
          if (amount != null) {
            final walletBalance = await getWalletBalance();
            if (walletBalance != null) {
              final isValid = walletBalance.hasSufficientBalance(amount);
              debugPrint('Wallet has sufficient balance: $isValid');
              debugPrint('===============================');
              return isValid;
            }
          }
          debugPrint('Wallet payment method is valid');
          debugPrint('===============================');
          return true;
        case PaymentMethodType.card:
        case PaymentMethodType.bank:
          debugPrint('Card/Bank payment method is valid');
          debugPrint('===============================');
          return true;
      }
    } catch (e) {
      debugPrint('Error validating payment method: $e');
      return false;
    }
  }

  PaymentMethod? getPaymentMethodByType(PaymentMethodType type) {
    debugPrint('=== GET PAYMENT METHOD BY TYPE ===');
    final availableMethods = getAvailablePaymentMethods();
    try {
      final method = availableMethods.firstWhere(
        (method) => method.type == type,
      );
      debugPrint('Found Payment Method: $method');
      debugPrint('===============================');
      return method;
    } catch (e) {
      debugPrint('Payment method not found for type: $type');
      return null;
    }
  }

  bool requiresSetup(PaymentMethodType paymentMethod) {
    debugPrint('=== CHECK IF PAYMENT METHOD REQUIRES SETUP ===');
    final requiresSetup = switch (paymentMethod) {
      PaymentMethodType.cash || PaymentMethodType.wallet => false,
      PaymentMethodType.card || PaymentMethodType.bank => true,
    };
    debugPrint('Payment method requires setup: $requiresSetup');
    debugPrint('============================================');
    return requiresSetup;
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    debugPrint('=== GET USER PROFILE ===');
    debugPrint('Using UserData from Preferences');

    try {
      final userData = await Preferences.instance.userDataObject;
      if (userData != null) {
        debugPrint(
          'Found user data: ${userData.firstName} ${userData.lastName}',
        );

        final profileData = {
          'user': userData,
          'profile_photo_url': userData.profilePhotoUrl,
          'wallet_balance_tzs': userData.walletBalanceTzs,
          'wallet_balance_usd': userData.walletBalanceUsd,
          'preferred_payment_method': userData.preferredPaymentMethod,
          'is_verified': userData.isVerified,
          'total_rides': userData.totalRides,
          'average_rating': userData.averageRating,
        };

        debugPrint('User Profile Data: $profileData');
        debugPrint('============================');
        return profileData;
      }

      debugPrint('No user data found in preferences');
      debugPrint('============================');
      return null;
    } catch (e) {
      debugPrint('Exception getting user profile: $e');
      debugPrint('============================');
      return null;
    }
  }

  Future<String?> _getUserId() async {
    debugPrint('=== GET USER ID ===');
    try {
      // Use auth key (uid) from preferences as the primary user ID
      final authKey = await Preferences.instance.authKey;
      if (authKey != null && authKey.isNotEmpty) {
        debugPrint('User ID from auth key: $authKey');
        debugPrint('==================');
        return authKey;
      }

      debugPrint('No user ID found');
      debugPrint('==================');
      return null;
    } catch (e) {
      debugPrint('Error getting user ID: $e');
      return null;
    }
  }

  static String formatCurrency(double amount, [String currency = 'TZS']) {
    debugPrint('=== FORMAT CURRENCY ===');
    final formattedCurrency =
        currency.toUpperCase() == 'USD'
            ? '\$${amount.toStringAsFixed(2)}'
            : 'TZS ${amount.toStringAsFixed(0)}';
    debugPrint('Formatted Currency: $formattedCurrency');
    debugPrint('======================');
    return formattedCurrency;
  }

  static double parseCurrencyAmount(String amountString) {
    debugPrint('=== PARSE CURRENCY AMOUNT ===');
    final cleanAmount = amountString.replaceAll(RegExp(r'[^\d.]'), '').trim();
    final parsedAmount = double.tryParse(cleanAmount) ?? 0.0;
    debugPrint('Parsed Amount: $parsedAmount');
    debugPrint('============================');
    return parsedAmount;
  }
}
