import 'package:flutter/material.dart';
import 'package:sepesha_app/Utilities/app_color.dart';

/// A custom divider widget for separating content
class CustomDivider extends StatelessWidget {
  const CustomDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppColor.lightGrey,
    );
  }
}