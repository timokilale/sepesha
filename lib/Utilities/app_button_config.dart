import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppButtonConfig {
  AppButtonConfig._();
  
  // Environment-based button configuration with fallbacks
  static double get height => _parseDouble(dotenv.env['BUTTON_HEIGHT']) ?? _ConstButtonConfig.height;
  static double get borderRadius => _parseDouble(dotenv.env['BUTTON_BORDER_RADIUS']) ?? _ConstButtonConfig.borderRadius;
  static double get fontSize => _parseDouble(dotenv.env['BUTTON_FONT_SIZE']) ?? _ConstButtonConfig.fontSize;
  
  // Standard button padding based on height
  static EdgeInsetsGeometry get padding => EdgeInsets.symmetric(
    vertical: (height - fontSize - 8) / 2, // Calculate padding to achieve desired height
    horizontal: 16,
  );
  
  // Helper method to parse double values from environment
  static double? _parseDouble(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return double.parse(value);
    } catch (e) {
      return null;
    }
  }
}

// Const button configuration for fallbacks
class _ConstButtonConfig {
  static const double height = 56.0;
  static const double borderRadius = 12.0;
  static const double fontSize = 16.0;
}
