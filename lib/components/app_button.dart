import 'package:flutter/material.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';

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
        onPressed: isLoading ? null : onPressed,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading) ...[
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: loadingIndicatorColor ?? AppColor.white,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (icon != null && !isLoading) ...[
              Icon(icon),
              const SizedBox(width: 4),
            ],
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

// Generic AppButton class for general use
class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? elevation;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.elevation,
    this.borderRadius,
    this.padding,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: foregroundColor ?? AppColor.white,
          backgroundColor: backgroundColor ?? AppColor.primary,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
            side: BorderSide(
              color: borderColor ?? backgroundColor ?? AppColor.primary,
              width: 1,
            ),
          ),
          elevation: elevation ?? 0,
          disabledBackgroundColor: AppColor.lightGrey,
        ),
        child:
            isLoading
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: foregroundColor ?? AppColor.white,
                    strokeWidth: 2,
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: foregroundColor ?? AppColor.white,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}

// Utility class for showing consistent loading modals
class LoadingModal {
  static void show(BuildContext context, {String message = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: AppTextStyle.paragraph1(AppColor.blackText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
