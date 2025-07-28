import 'package:flutter/material.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/Utilities/app_button_config.dart';
import 'package:sepesha_app/Utilities/feedback_manager.dart';

class ContinueButton extends StatefulWidget {
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
  State<ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<ContinueButton> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isLoading) {
      setState(() => _isPressed = true);
      _animationController.forward();
      FeedbackManager.instance.showButtonPress();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isLoading) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (!widget.isLoading) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : widget.onPressed,
                style: ElevatedButton.styleFrom(
                  foregroundColor: widget.foregroundColor ?? AppColor.white,
                  backgroundColor: widget.backgroundColor ?? AppColor.primary,
                  padding: widget.padding ?? AppButtonConfig.padding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius ?? AppButtonConfig.borderRadius),
                    side: BorderSide(color: widget.borderColor ?? AppColor.primary, width: 1),
                  ),
                  elevation: widget.elevation ?? 0,
                  disabledBackgroundColor: widget.backgroundColor ?? AppColor.lightGrey,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.isLoading) ...[
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: widget.loadingIndicatorColor ?? AppColor.white,
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (widget.icon != null && !widget.isLoading) ...[
                      Icon(widget.icon),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: AppButtonConfig.fontSize,
                        fontWeight: FontWeight.bold,
                        color: widget.textColor ?? AppColor.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AppButton extends StatefulWidget {
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
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isLoading) {
      setState(() => _isPressed = true);
      _animationController.forward();
      FeedbackManager.instance.showButtonPress();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isLoading) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (!widget.isLoading) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : widget.onPressed,
                style: ElevatedButton.styleFrom(
                  foregroundColor: widget.foregroundColor ?? AppColor.white,
                  backgroundColor: widget.backgroundColor ?? AppColor.primary,
                  padding: widget.padding ?? AppButtonConfig.padding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius ?? AppButtonConfig.borderRadius),
                    side: BorderSide(
                      color: widget.borderColor ?? widget.backgroundColor ?? AppColor.primary,
                      width: 1,
                    ),
                  ),
                  elevation: widget.elevation ?? 0,
                  disabledBackgroundColor: AppColor.lightGrey,
                ),
                child: widget.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: widget.foregroundColor ?? AppColor.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, size: 18),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: TextStyle(
                              fontSize: AppButtonConfig.fontSize,
                              fontWeight: FontWeight.w600,
                              color: widget.foregroundColor ?? AppColor.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

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
