import 'package:flutter/material.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';

class DrawerTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool showBadge;
  final String? badgeText;
  final bool isDestructive;
  final int animationDelay;

  const DrawerTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.iconColor,
    this.showBadge = false,
    this.badgeText,
    this.isDestructive = false,
    this.animationDelay = 0,
  });

  @override
  State<DrawerTile> createState() => _DrawerTileState();
}

class _DrawerTileState extends State<DrawerTile> with SingleTickerProviderStateMixin {
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
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + widget.animationDelay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: widget.onTap,
                        onTapDown: _handleTapDown,
                        onTapUp: _handleTapUp,
                        onTapCancel: _handleTapCancel,
                        splashColor: (widget.iconColor ?? AppColor.primary).withOpacity(0.1),
                        highlightColor: (widget.iconColor ?? AppColor.primary).withOpacity(0.05),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: _isPressed
                                ? (widget.iconColor ?? AppColor.primary).withOpacity(0.05)
                                : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              // Enhanced icon with background
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: widget.isDestructive
                                      ? AppColor.primary.withOpacity(0.1)
                                      : (widget.iconColor ?? AppColor.primary).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (widget.iconColor ?? AppColor.primary).withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Icon(
                                        widget.icon,
                                        color: widget.iconColor ?? AppColor.primary,
                                        size: 24,
                                      ),
                                    ),
                                    if (widget.showBadge && widget.badgeText != null)
                                      Positioned(
                                        right: 2,
                                        top: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppColor.primary,
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColor.primary.withOpacity(0.3),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 18,
                                            minHeight: 18,
                                          ),
                                          child: Text(
                                            widget.badgeText!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 16),

                              // Enhanced text content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.title,
                                      style: AppTextStyle.paragraph1(AppColor.blackText).copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (widget.subtitle != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.subtitle!,
                                        style: AppTextStyle.subtext1(AppColor.grey),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Enhanced arrow icon
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: AppColor.grey.withOpacity(0.6),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
