import 'package:flutter/material.dart';

/// Enum for different payment method types
enum PaymentMethodType {
  cash,
  wallet,
  card,
  bank,
}

/// Extension to get string values and display names for payment method types
extension PaymentMethodTypeExtension on PaymentMethodType {
  String get value {
    switch (this) {
      case PaymentMethodType.cash:
        return 'cash';
      case PaymentMethodType.wallet:
        return 'wallet';
      case PaymentMethodType.card:
        return 'card';
      case PaymentMethodType.bank:
        return 'bank';
    }
  }

  String get displayName {
    switch (this) {
      case PaymentMethodType.cash:
        return 'Cash';
      case PaymentMethodType.wallet:
        return 'Sepesha Wallet';
      case PaymentMethodType.card:
        return 'Credit/Debit Card';
      case PaymentMethodType.bank:
        return 'Bank Transfer';
    }
  }

  String get description {
    switch (this) {
      case PaymentMethodType.cash:
        return 'Pay with cash on delivery';
      case PaymentMethodType.wallet:
        return 'Pay using your Sepesha wallet balance';
      case PaymentMethodType.card:
        return 'Pay with credit or debit card';
      case PaymentMethodType.bank:
        return 'Pay via bank transfer';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethodType.cash:
        return Icons.money;
      case PaymentMethodType.wallet:
        return Icons.account_balance_wallet;
      case PaymentMethodType.card:
        return Icons.credit_card;
      case PaymentMethodType.bank:
        return Icons.account_balance;
    }
  }

  Color get color {
    switch (this) {
      case PaymentMethodType.cash:
        return Colors.green;
      case PaymentMethodType.wallet:
        return Colors.blue;
      case PaymentMethodType.card:
        return Colors.purple;
      case PaymentMethodType.bank:
        return Colors.orange;
    }
  }

  /// Create PaymentMethodType from string value
  static PaymentMethodType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'cash':
        return PaymentMethodType.cash;
      case 'wallet':
        return PaymentMethodType.wallet;
      case 'card':
        return PaymentMethodType.card;
      case 'bank':
        return PaymentMethodType.bank;
      default:
        return PaymentMethodType.cash; // Default fallback
    }
  }
}

/// Model class for payment methods
class PaymentMethod {
  final String id;
  final PaymentMethodType type;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool isDefault;
  final bool isEnabled;
  final Map<String, dynamic>? metadata; // For additional data like wallet balance

  PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.isDefault = false,
    this.isEnabled = true,
    this.metadata,
  });

  /// Factory constructor to create PaymentMethod from PaymentMethodType
  factory PaymentMethod.fromType(
    PaymentMethodType type, {
    bool isDefault = false,
    bool isEnabled = true,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentMethod(
      id: type.value,
      type: type,
      name: type.displayName,
      description: type.description,
      icon: type.icon,
      color: type.color,
      isDefault: isDefault,
      isEnabled: isEnabled,
      metadata: metadata,
    );
  }

  /// Factory constructor to create PaymentMethod from API response
  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    final type = PaymentMethodTypeExtension.fromString(json['type'] ?? 'cash');
    return PaymentMethod(
      id: json['id']?.toString() ?? type.value,
      type: type,
      name: json['name'] ?? type.displayName,
      description: json['description'] ?? type.description,
      icon: type.icon,
      color: type.color,
      isDefault: json['is_default'] ?? false,
      isEnabled: json['is_enabled'] ?? true,
      metadata: json['metadata'],
    );
  }

  /// Convert PaymentMethod to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'name': name,
      'description': description,
      'is_default': isDefault,
      'is_enabled': isEnabled,
      'metadata': metadata,
    };
  }

  /// Create a copy of PaymentMethod with updated fields
  PaymentMethod copyWith({
    String? id,
    PaymentMethodType? type,
    String? name,
    String? description,
    IconData? icon,
    Color? color,
    bool? isDefault,
    bool? isEnabled,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      isEnabled: isEnabled ?? this.isEnabled,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentMethod && other.id == id && other.type == type;
  }

  @override
  int get hashCode => id.hashCode ^ type.hashCode;

  @override
  String toString() {
    return 'PaymentMethod(id: $id, type: ${type.value}, name: $name, isDefault: $isDefault)';
  }
}

/// Wallet balance model
class WalletBalance {
  final double balanceTzs;
  final double balanceUsd;
  final String currency;

  WalletBalance({
    required this.balanceTzs,
    required this.balanceUsd,
    this.currency = 'TZS',
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      balanceTzs: double.tryParse(json['wallet_balance_tzs']?.toString() ?? '0') ?? 0.0,
      balanceUsd: double.tryParse(json['wallet_balance_usd']?.toString() ?? '0') ?? 0.0,
      currency: json['currency'] ?? 'TZS',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wallet_balance_tzs': balanceTzs.toString(),
      'wallet_balance_usd': balanceUsd.toString(),
      'currency': currency,
    };
  }

  /// Get balance in the specified currency
  double getBalance([String? currencyCode]) {
    if (currencyCode?.toUpperCase() == 'USD') {
      return balanceUsd;
    }
    return balanceTzs; // Default to TZS
  }

  /// Check if wallet has sufficient balance for a given amount
  bool hasSufficientBalance(double amount, [String? currencyCode]) {
    return getBalance(currencyCode) >= amount;
  }

  @override
  String toString() {
    return 'WalletBalance(TZS: $balanceTzs, USD: $balanceUsd)';
  }
}
