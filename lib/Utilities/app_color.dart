import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppColor {
  AppColor._();

  // Environment-based colors with fallbacks
  static Color get primary => _parseColor(dotenv.env['PRIMARY_COLOR']) ?? _ConstColors.primary;
  static Color get secondary => _parseColor(dotenv.env['SECONDARY_COLOR']) ?? _ConstColors.secondary;
  static Color get background => _parseColor(dotenv.env['BACKGROUND_COLOR']) ?? _ConstColors.background;
  static Color get textColor => _parseColor(dotenv.env['TEXT_COLOR']) ?? _ConstColors.textColor;
  static Color get greyColor => _parseColor(dotenv.env['GREY_COLOR']) ?? _ConstColors.greyColor;

  // Alert colors from environment
  static Color get successColor => _parseColor(dotenv.env['SUCCESS_COLOR']) ?? _ConstColors.successColor;
  static Color get warningColor => _parseColor(dotenv.env['WARNING_COLOR']) ?? _ConstColors.warningColor;

  // Alias for primaryColor (commonly used in UI components)
  static Color get primaryColor => primary;

  //white
  static const Color white = Colors.white;
  static Color get white2 => background;

  //black
  static const Color black = Colors.black;
  static Color get blackText => textColor;
  static const Color lightBlack = Colors.black87;
  static const Color blackSubtext = Color(0xFF363C3C);

  //grey
  static Color get grey => greyColor;
  static const Color lightGrey = Color(0xFFE7E7E7);

  //green
  static Color get greenBullet => secondary;
  static const Color lightGreen = Color(0xFF7BC778);

  //light_red
  static const Color lightred = Color(0xFFFEE2E2);

  //blue
  static const Color blue1 = Color(0xFFDAEDFF);
  static const Color blue2 = Color(0xFF0A51BC);

  //orange
  static const Color orange = Color(0xFFE5BA23);
  static const Color lightOrange = Color(0xFFF9F4C8);

  // Helper method to parse hex color strings from environment
  static Color? _parseColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return null;

    // Remove # if present
    hexString = hexString.replaceAll('#', '');

    // Add alpha if not present (assuming full opacity)
    if (hexString.length == 6) {
      hexString = 'FF$hexString';
    }

    try {
      return Color(int.parse(hexString, radix: 16));
    } catch (e) {
      return null;
    }
  }
}

// Const colors for use in const contexts
class _ConstColors {
  static const Color primary = Color(0xFFE53935);
  static const Color secondary = Color(0xFF009959);
  static const Color background = Color(0xFFF1F5EC);
  static const Color textColor = Color(0XFF002106);
  static const Color greyColor = Color(0xFF585C5C);
  static const Color successColor = Color(0xFF008000);
  static const Color warningColor = Color(0xFFFF0000);
}
