import 'package:flutter/material.dart';
import 'package:sepesha_app/Utilities/app_color.dart';

class ContinueButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String text;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? foregroundColor;
  final Color? loadingIndicatorColor;
  final double? elevation;
  final double? borderRadius;
  final Color? textColor;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  const ContinueButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    this.text = 'CONTINUE',
    this.backgroundColor,
    this.foregroundColor,
    this.loadingIndicatorColor,
    this.elevation,
    this.borderRadius,
    this.textColor,
    this.borderColor,
    this.padding,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            isLoading
                ? () {
                  print("isLoading: $isLoading");
                }
                : onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: foregroundColor ?? AppColor.white,
          backgroundColor: backgroundColor ?? AppColor.primary,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
            side: BorderSide(color: borderColor ?? AppColor.primary, width: 1),
          ),
          elevation: elevation ?? 0,
          disabledBackgroundColor: backgroundColor ?? AppColor.lightGrey,
        ),
        child:
            isLoading
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: loadingIndicatorColor ?? AppColor.primary,
                    strokeWidth: 2,
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    if (icon != null) Icon(icon),
                    SizedBox(width: 4),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor ?? AppColor.white,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
