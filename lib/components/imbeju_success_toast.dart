import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';

/// A customizable toast notification widget with built-in success, error, and warning variants.
class ImbejuToast extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Duration duration;
  final VoidCallback? onDismiss;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign descriptionTextAlign;
  final List<BoxShadow>? boxShadow;

  const ImbejuToast({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor = AppColor.black,
    this.backgroundColor = AppColor.white,
    this.duration = const Duration(seconds: 4),
    this.onDismiss,
    this.margin = const EdgeInsets.only(bottom: 60, left: 20, right: 20),
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(16),
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.descriptionTextAlign = TextAlign.start,
    this.boxShadow,
  });

  /// Creates a success toast with predefined icon and color
  factory ImbejuToast.success({
    Key? key,
    required String title,
    required String description,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onDismiss,
    EdgeInsetsGeometry? margin,
  }) {
    return ImbejuToast(
      key: key,
      title: title,
      description: description,
      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
      iconColor: AppColor.successColor,
      duration: duration,
      onDismiss: onDismiss,
      margin: margin ?? const EdgeInsets.only(bottom: 60, left: 20, right: 20),
    );
  }

  /// Creates an error toast with predefined icon and color
  factory ImbejuToast.error({
    Key? key,
    required String title,
    required String description,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onDismiss,
    EdgeInsetsGeometry? margin,
  }) {
    return ImbejuToast(
      key: key,
      title: title,
      description: description,
      icon: HugeIcons.strokeRoundedCancel01,
      iconColor: AppColor.warningColor,
      duration: duration,
      onDismiss: onDismiss,
      margin: margin ?? const EdgeInsets.only(bottom: 60, left: 20, right: 20),
    );
  }

  /// Creates a warning toast with predefined icon and color
  factory ImbejuToast.warning({
    Key? key,
    required String title,
    required String description,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onDismiss,
    EdgeInsetsGeometry? margin,
  }) {
    return ImbejuToast(
      key: key,
      title: title,
      description: description,
      icon: HugeIcons.strokeRoundedAlertCircle,
      iconColor: AppColor.warningColor,
      duration: duration,
      onDismiss: onDismiss,
      margin: margin ?? const EdgeInsets.only(bottom: 60, left: 20, right: 20),
    );
  }

  /// Displays the toast notification
  void show(BuildContext context) {
    // Get the navigator state to ensure we have valid context
    final navigator = Navigator.of(context, rootNavigator: true);
    final overlayState = navigator.overlay;

    if (overlayState == null) {
      debugPrint('ImbejuToast: Could not find Overlay in context');
      return;
    }

    late final OverlayEntry overlayEntry;

    void removeOverlay() {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
        onDismiss?.call();
      }
    }

    overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: margin.resolve(TextDirection.ltr).bottom,
            left: margin.resolve(TextDirection.ltr).left,
            right: margin.resolve(TextDirection.ltr).right,
            child: Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.down,
              onDismissed: (_) => removeOverlay(),
              child: this,
            ),
          ),
    );

    overlayState.insert(overlayEntry);
    Future.delayed(duration, removeOverlay);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: iconColor, width: 1),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: boxShadow ?? _defaultBoxShadow(),
        ),
        child: Row(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            HugeIcon(icon: icon, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyle.subtext5(AppColor.black),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyle.subtext4(AppColor.lightGreen),
                    textAlign: descriptionTextAlign,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BoxShadow> _defaultBoxShadow() {
    return [
      BoxShadow(
        color: iconColor.withAlpha(25),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];
  }
}
