import 'package:flutter/material.dart';

class AppTextStyle {
  AppTextStyle._();

  static const double _paragraph1 = 14.0;
  static const double _paragraph2 = 18.0;
  static const double _paragraph3 = 20.0;
  static const double _paragraph4 = 24.0;
  static const double _paragraph5 = 28.0;
  static const double _paragraph6 = 22.0;

  static const double _smallText = 11.0;
  static const double _smallText2 = 10.0;
  static const double _smallText3 = 9.1;

  static const double _subtext1 = 12.0;
  static const double _subtext3 = 14.0;
  static const double _heading1 = 30.0;
  static const double _heading2 = 32.0;
  static const double _heading3 = 36.0;

  static const String _fontFamily = 'Poppins';

  // Static text styles for common use cases
  static const TextStyle bodyTextStyle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _paragraph1,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
  );

  static const TextStyle headingTextStyle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _paragraph3,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static const TextStyle subheadingTextStyle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _paragraph2,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  static const TextStyle captionTextStyle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _subtext1,
    fontWeight: FontWeight.w400,
    color: Colors.black54,
  );

  static const TextStyle smallTextStyle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _smallText,
    fontWeight: FontWeight.w400,
    color: Colors.black54,
  );

  // Existing methods that require Color parameter
  static TextStyle paragraph1(Color color) =>
      TextStyle(fontFamily: _fontFamily, fontSize: _paragraph1, color: color);
  static TextStyle fontWeightparagraph1(Color color, FontWeight fontweight) =>
      TextStyle(
        fontFamily: _fontFamily,
        fontSize: _paragraph1,
        color: color,
        fontWeight: fontweight,
      );

  static TextStyle paragraph2(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _paragraph2,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle paragraph3(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _paragraph3,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle paragraph5(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _paragraph5,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle paragraph4(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _paragraph4,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle paragraph6(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _paragraph6,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle heading1(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _heading1,
    fontWeight: FontWeight.w400,
    color: color,
  );
  static TextStyle heading2(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _heading2,
    fontWeight: FontWeight.w600,
    color: color,
  );
  static TextStyle heading3(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _heading3,
    fontWeight: FontWeight.w600,
    color: color,
  );
  static TextStyle subtext1(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _subtext1,
    fontWeight: FontWeight.w400,
    color: color,
  );
  static TextStyle subtext2(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _subtext1,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle subtext3(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _subtext1,
    fontWeight: FontWeight.w700,
    color: color,
  );

  static TextStyle subtext4(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _subtext3,
    fontWeight: FontWeight.w400,
    color: color,
  );

  static TextStyle subtext5(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _subtext3,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle smallText(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _smallText,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle smallText2(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _smallText2,
    fontWeight: FontWeight.w400,
    color: color,
  );
  static TextStyle smallText3(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _smallText2,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle smallText4(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: _smallText3,
    fontWeight: FontWeight.w400,
    color: color,
  );
}
