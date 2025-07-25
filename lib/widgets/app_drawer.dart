import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/Driver/wallet/presentation/wallet_screen.dart';
import 'package:sepesha_app/screens/about_screen.dart';
import 'package:sepesha_app/screens/auth/auth_screen.dart';
import 'package:sepesha_app/screens/auth/support/support_screen.dart';
import 'package:sepesha_app/widgets/app_drawer_header.dart';
import 'package:sepesha_app/screens/payment_methods_screen.dart';
import 'package:sepesha_app/screens/conversation_list_screen.dart';
import 'package:sepesha_app/screens/dashboard/rides_screen.dart';
import 'package:sepesha_app/provider/customer_history_provider.dart';
import 'package:sepesha_app/services/auth_services.dart';
import 'package:sepesha_app/services/session_manager.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/provider/message_provider.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> with TickerProviderStateMixin {
  String? userType;
  int unreadMessages = 0;
  late AnimationController _animationController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserType();
    _loadUnreadCount();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _animationController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _loadUserType() {
    final sessionUser = SessionManager.instance.user;
    if (sessionUser != null) {
      userType = sessionUser.userType;
      setState(() {});
    }
  }

  void _loadUnreadCount() async {
    try {
      final messageProvider = Provider.of<MessageProvider>(context, listen: false);
      final sessionUser = SessionManager.instance.user;
      if (sessionUser != null && sessionUser.phoneNumber != null) {
        await messageProvider.initialize(sessionUser.phoneNumber!);
      }

      if (mounted) {
        setState(() {
          unreadMessages = messageProvider.unreadCount;
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading unread count: $e');
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColor.white,
              AppColor.white2.withOpacity(0.3),
            ],
          ),
        ),
        child: Column(
          children: [
            // Enhanced Header
            const AppDrawerHeader(),

            // Navigation Section
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      // Main Actions Section
                      _buildSectionHeader('Main'),
                      _buildAnimatedTile(
                        icon: Icons.payment_rounded,
                        title: 'Payment Methods',
                        subtitle: 'Manage your payment options',
                        delay: 0,
                        onTap: () => _navigateWithAnimation(
                          () => const PaymentMethodsScreen(),
                        ),
                      ),

                      _buildAnimatedTile(
                        icon: Icons.chat_bubble_rounded,
                        title: 'Messages',
                        subtitle: userType?.toLowerCase() == 'customer'
                            ? 'Chat with driver'
                            : 'Chat with customers',
                        delay: 100,
                        showBadge: unreadMessages > 0,
                        badgeText: unreadMessages > 0 ? unreadMessages.toString() : null,
                        onTap: () => _navigateWithAnimation(
                          () => const ConversationsScreen(),
                        ),
                      ),

                      if (userType?.toLowerCase() == 'vendor')
                        _buildAnimatedTile(
                          icon: Icons.history_rounded,
                          title: 'Wallet',
                          subtitle: 'Manage your wallet balance',
                          delay: 200,
                          onTap: () => _navigateToWallet(),
                        ),

                      const SizedBox(height: 16),

                      // Support Section
                      _buildSectionHeader('Support'),
                      _buildAnimatedTile(
                        icon: Icons.info_outline_rounded,
                        title: 'About',
                        subtitle: 'App information',
                        delay: 300,
                        onTap: () => _showAboutDialog(),
                      ),

                      _buildAnimatedTile(
                        icon: Icons.support_agent_rounded,
                        title: 'Support',
                        subtitle: 'Get help and support',
                        delay: 400,
                        onTap: () => _navigateToSupport(context),
                      ),

                      const SizedBox(height: 24),

                      // Logout Section
                      _buildAnimatedTile(
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        subtitle: 'Sign out of your account',
                        delay: 500,
                        iconColor: AppColor.primary,
                        isDestructive: true,
                        onTap: () => _showLogoutDialog(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer with app version
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // Enhanced UI Helper Methods
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyle.smallText(AppColor.grey).copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildAnimatedTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required int delay,
    required VoidCallback onTap,
    Color? iconColor,
    bool showBadge = false,
    String? badgeText,
    bool isDestructive = false,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.transparent,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onTap,
                  splashColor: AppColor.primary.withOpacity(0.1),
                  highlightColor: AppColor.primary.withOpacity(0.05),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        // Icon with background
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isDestructive
                                ? AppColor.primary.withOpacity(0.1)
                                : AppColor.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Icon(
                                  icon,
                                  color: iconColor ?? AppColor.primary,
                                  size: 24,
                                ),
                              ),
                              if (showBadge && badgeText != null)
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
                                      badgeText,
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

                        // Text content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: AppTextStyle.paragraph1(AppColor.blackText).copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: AppTextStyle.subtext1(AppColor.grey),
                              ),
                            ],
                          ),
                        ),

                        // Arrow icon
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Divider(color: AppColor.lightGrey.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(
            'Sepesha v1.0.0',
            style: AppTextStyle.smallText2(AppColor.grey.withOpacity(0.7)),
          ),
          const SizedBox(height: 4),
          Text(
            '© ${DateTime.now().year} Sepesha. All rights reserved.',
            style: AppTextStyle.smallText2(AppColor.grey.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  void _navigateWithAnimation(Widget Function() screenBuilder) {
    final navigator = Navigator.of(context);
    navigator.pop();
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        navigator.push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => screenBuilder(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;

              var tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve),
              );

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    });
  }

  void _navigateToHistory() {
    final navigator = Navigator.of(context);
    navigator.pop();
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        navigator.push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
              ChangeNotifierProvider(
                create: (_) => CustomerHistoryProvider(),
                child: RidesScreen(),
              ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;

              var tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve),
              );

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    });
  }

  void _navigateToSupport(BuildContext context) {
    final navigator = Navigator.of(context);
    navigator.pop();
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        navigator.push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const SupportScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;

              var tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve),
              );

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    });
  }

  void _showAboutDialog() {
    final navigator = Navigator.of(context);
    navigator.pop();
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        navigator.push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const AboutScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;

              var tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve),
              );

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    });
  }

  void _showLogoutDialog() {
    Navigator.pop(context); // Close drawer first

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        backgroundColor: AppColor.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: AppColor.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Logout',
              style: AppTextStyle.paragraph3(AppColor.blackText),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to logout?',
              style: AppTextStyle.paragraph1(AppColor.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'You will need to sign in again to access your account.',
              style: AppTextStyle.subtext1(AppColor.grey.withOpacity(0.8)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancel',
              style: AppTextStyle.paragraph1(AppColor.grey),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Show loading indicator
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
                          'Signing out...',
                          style: AppTextStyle.paragraph1(AppColor.blackText),
                        ),
                      ],
                    ),
                  ),
                ),
              );

              try {
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const AuthScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOutCubic;

                        var tween = Tween(begin: begin, end: end).chain(
                          CurveTween(curve: curve),
                        );

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                    (route) => false,
                  );
                }
                AuthServices.logout(context);
                
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Close loading dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error signing out: $e'),
                      backgroundColor: AppColor.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: AppColor.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Logout',
              style: AppTextStyle.paragraph1(AppColor.white).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToWallet() {
    final navigator = Navigator.of(context);
    navigator.pop();
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        navigator.push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const WalletScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;

              var tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve),
              );

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    });
  }
}
