import 'package:flutter/material.dart';
import 'package:sepesha_app/Utilities/app_color.dart';

/// A handle widget for draggable bottom sheets
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColor.lightGrey,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}