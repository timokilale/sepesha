import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyle {
  AppTextStyle._();

  // Font sizes - optimized for better hierarchy
  static const double _paragraph1 = 14.0;
  static const double _paragraph2 = 16.0;
  static const double _paragraph3 = 18.0;
  static const double _paragraph4 = 20.0;
  static const double _paragraph5 = 24.0;
  static const double _paragraph6 = 22.0;

  static const double _smallText = 11.0;
  static const double _smallText2 = 10.0;
  static const double _smallText3 = 9.0;

  static const double _subtext1 = 12.0;
  static const double _subtext2 = 13.0;
  static const double _subtext3 = 14.0;
  static const double _heading1 = 28.0;
  static const double _heading2 = 24.0;
  static const double _heading3 = 20.0;
  static const double _caption = 11.0;

  // Use Google Fonts Poppins
  static TextStyle _baseStyle = GoogleFonts.poppins();

  // Static text styles for common use cases
  static TextStyle get bodyTextStyle => _baseStyle.copyWith(
    fontSize: _paragraph1,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
  );

  static TextStyle get headingTextStyle => _baseStyle.copyWith(
    fontSize: _paragraph3,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static TextStyle get subheadingTextStyle => _baseStyle.copyWith(
    fontSize: _paragraph2,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  static TextStyle get captionTextStyle => _baseStyle.copyWith(
    fontSize: _subtext1,
    fontWeight: FontWeight.w400,
    color: Colors.black54,
  );

  static TextStyle get smallTextStyle => _baseStyle.copyWith(
    fontSize: _smallText,
    fontWeight: FontWeight.w400,
    color: Colors.black54,
  );

  // Enhanced methods with proper typography hierarchy
  static TextStyle paragraph1(Color color) => _baseStyle.copyWith(
    fontSize: _paragraph1,
    fontWeight: FontWeight.w400,
    color: color,
  );

  static TextStyle fontWeightparagraph1(Color color, FontWeight fontweight) => _baseStyle.copyWith(
    fontSize: _paragraph1,
    color: color,
    fontWeight: fontweight,
  );

  static TextStyle paragraph2(Color color) => _baseStyle.copyWith(
    fontSize: _paragraph2,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle paragraph3(Color color) => _baseStyle.copyWith(
    fontSize: _paragraph3,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle paragraph4(Color color) => _baseStyle.copyWith(
    fontSize: _paragraph4,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle paragraph5(Color color) => _baseStyle.copyWith(
    fontSize: _paragraph5,
    fontWeight: FontWeight.w700,
    color: color,
  );

  static TextStyle paragraph6(Color color) => _baseStyle.copyWith(
    fontSize: _paragraph6,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle heading1(Color color) => _baseStyle.copyWith(
    fontSize: _heading1,
    fontWeight: FontWeight.w700,
    color: color,
  );

  static TextStyle heading2(Color color) => _baseStyle.copyWith(
    fontSize: _heading2,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle heading3(Color color) => _baseStyle.copyWith(
    fontSize: _heading3,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle subtext1(Color color) => _baseStyle.copyWith(
    fontSize: _subtext1,
    fontWeight: FontWeight.w400,
    color: color,
  );

  static TextStyle subtext2(Color color) => _baseStyle.copyWith(
    fontSize: _subtext2,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle subtext3(Color color) => _baseStyle.copyWith(
    fontSize: _subtext2,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle subtext4(Color color) => _baseStyle.copyWith(
    fontSize: _subtext3,
    fontWeight: FontWeight.w400,
    color: color,
  );

  static TextStyle subtext5(Color color) => _baseStyle.copyWith(
    fontSize: _subtext3,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle smallText(Color color) => _baseStyle.copyWith(
    fontSize: _smallText,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle smallText2(Color color) => _baseStyle.copyWith(
    fontSize: _smallText2,
    fontWeight: FontWeight.w400,
    color: color,
  );

  static TextStyle smallText3(Color color) => _baseStyle.copyWith(
    fontSize: _smallText2,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle smallText4(Color color) => _baseStyle.copyWith(
    fontSize: _smallText3,
    fontWeight: FontWeight.w400,
    color: color,
  );

  // Additional helper methods for better typography
  static TextStyle caption(Color color) => _baseStyle.copyWith(
    fontSize: _caption,
    fontWeight: FontWeight.w400,
    color: color,
  );

  static TextStyle captionBold(Color color) => _baseStyle.copyWith(
    fontSize: _caption,
    fontWeight: FontWeight.w600,
    color: color,
  );
}
