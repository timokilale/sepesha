import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sepesha_app/components/success_toast.dart';

/// Manages silent feedback mechanisms for button actions
class FeedbackManager {
  FeedbackManager._();
  static final FeedbackManager _instance = FeedbackManager._();
  static FeedbackManager get instance => _instance;

  /// Show success feedback with optional toast
  void showSuccess({
    required BuildContext context,
    String? title,
    String? description,
    bool silent = false,
    bool haptic = true,
  }) {
    // Haptic feedback for success
    if (haptic) {
      HapticFeedback.lightImpact();
    }

    // Show toast if not silent
    if (!silent && title != null && description != null) {
      _showToast(
        context,
        Toast.success(
          title: title,
          description: description,
        ),
      );
    }
  }

  /// Show error feedback with optional toast
  void showError({
    required BuildContext context,
    String? title,
    String? description,
    bool silent = false,
    bool haptic = true,
  }) {
    // Haptic feedback for error
    if (haptic) {
      HapticFeedback.mediumImpact();
    }

    // Show toast if not silent
    if (!silent && title != null && description != null) {
      _showToast(
        context,
        Toast.error(
          title: title,
          description: description,
        ),
      );
    }
  }

  /// Show warning feedback with optional toast
  void showWarning({
    required BuildContext context,
    String? title,
    String? description,
    bool silent = false,
    bool haptic = true,
  }) {
    // Haptic feedback for warning
    if (haptic) {
      HapticFeedback.mediumImpact();
    }

    // Show toast if not silent
    if (!silent && title != null && description != null) {
      _showToast(
        context,
        Toast.warning(
          title: title,
          description: description,
        ),
      );
    }
  }

  /// Show button press feedback (silent by default)
  void showButtonPress({
    bool haptic = true,
  }) {
    if (haptic) {
      HapticFeedback.selectionClick();
    }
  }

  /// Show loading feedback (silent)
  void showLoading({
    bool haptic = true,
  }) {
    if (haptic) {
      HapticFeedback.lightImpact();
    }
  }

  /// Private method to show toast with animation
  void _showToast(BuildContext context, Toast toast) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 100 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: toast,
              ),
            );
          },
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Auto-remove after duration
    Future.delayed(toast.duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

/// Extension to easily access FeedbackManager from any widget
extension FeedbackExtension on BuildContext {
  FeedbackManager get feedback => FeedbackManager.instance;
}
