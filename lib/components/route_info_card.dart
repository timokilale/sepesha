import 'package:flutter/material.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';

class RouteInfoCard extends StatelessWidget {
  final String startLocation;
  final String endLocation;
  final double topPosition;

  const RouteInfoCard({
    super.key,
    required this.startLocation,
    required this.endLocation,
    this.topPosition = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: topPosition,
      left: 10,
      right: 10,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                startLocation,
                style: AppTextStyle.paragraph1(AppColor.blackText),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColor.grey,
                size: 16,
              ),
              Text(
                endLocation,
                style: AppTextStyle.paragraph1(AppColor.blackText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}