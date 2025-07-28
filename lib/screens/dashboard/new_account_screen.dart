import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/provider/user_profile_provider.dart';
import 'package:sepesha_app/screens/about_screen.dart';
import 'package:sepesha_app/screens/auth/auth_screen.dart';
import 'package:sepesha_app/screens/auth/support/support_screen.dart';
import 'package:sepesha_app/screens/customer_profile_screen.dart';
import 'package:sepesha_app/screens/payment_methods_screen.dart';
import 'package:sepesha_app/l10n/app_localizations.dart';
import 'package:sepesha_app/screens/conversation_list_screen.dart';
import 'package:sepesha_app/screens/settings_screen.dart';
import 'package:sepesha_app/services/auth_services.dart';
import 'package:sepesha_app/services/preferences.dart';
import 'package:sepesha_app/services/session_manager.dart';
import 'package:sepesha_app/Driver/profile/driver_profile_screen.dart';

class NewAccountScreen extends StatefulWidget {
  const NewAccountScreen({super.key});

  @override
  State<NewAccountScreen> createState() => _NewAccountScreenState();
}

class _NewAccountScreenState extends State<NewAccountScreen> with TickerProviderStateMixin {
  String? firstName;
  String? lastName;
  String? email;
  String? profilePhotoUrl;
  String? userType;
  double? userRating;
  int? totalRides;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  Future<void> _loadUserData() async {
    try {
      firstName = await Preferences.instance.firstName;
      lastName = await Preferences.instance.lastName;
      email = await Preferences.instance.email;
      userType = await Preferences.instance.getString('selected_user_type');

      final sessionUser = SessionManager.instance.user;
      if (sessionUser != null) {
        profilePhotoUrl = sessionUser.profilePhotoUrl;
        userRating = sessionUser.averageRating;
        totalRides = sessionUser.totalRides;
      }

      setState(() {});
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColor.white2,
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Enhanced Profile Header
                  _buildEnhancedProfileHeader(),
                  
                  // Content Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick Stats Section
                        if (userType == 'customer' && totalRides != null && totalRides! > 0)
                          _buildQuickStatsSection(),
                        if (userType == 'customer' && totalRides != null && totalRides! > 0)
                          const SizedBox(height: 12),

                        // Main Actions Section
                        _buildEnhancedMenuItem(
                          icon: Icons.person_outline_rounded,
                          title: localizations.personalInformation,
                          subtitle: localizations.manageProfileDetails,
                          color: AppColor.primary,
                          onTap: () => _navigateToProfile(),
                        ),
                        const SizedBox(height: 12),
                        _buildEnhancedMenuItem(
                          icon: Icons.payment_rounded,
                          title: localizations.paymentMethods,
                          subtitle: localizations.managePaymentOptions,
                          color: Colors.green,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildEnhancedMenuItem(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: localizations.messages,
                          subtitle: localizations.viewConversations,
                          color: Colors.blue,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ConversationsScreen()),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildEnhancedMenuItem(
                          icon: Icons.settings_rounded,
                          title: localizations.settings,
                          subtitle: localizations.appPreferencesSettings,
                          color: Colors.grey,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SettingsScreen()),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildEnhancedMenuItem(
                          icon: Icons.help_outline_rounded,
                          title: localizations.helpSupport,
                          subtitle: localizations.getHelpSupport,
                          color: Colors.orange,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SupportScreen()),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildEnhancedMenuItem(
                          icon: Icons.info_outline_rounded,
                          title: localizations.about,
                          subtitle: localizations.appInformationVersion,
                          color: Colors.purple,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AboutScreen()),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildEnhancedMenuItem(
                          icon: Icons.logout_rounded,
                          title: localizations.logout,
                          subtitle: localizations.signOutAccount,
                          color: Colors.red,
                          onTap: () => _showLogoutDialog(),
                          isDestructive: true,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedProfileHeader() {
    final localizations = AppLocalizations.of(context)!;
    final fullName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    final displayName = fullName.isNotEmpty ? fullName : localizations.user;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.primary,
            AppColor.primary.withValues(alpha: 0.8),
            AppColor.primary.withValues(alpha: 0.9),
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            children: [
              // Profile Avatar and Info
              Row(
                children: [
                  // Enhanced Avatar with Animation
                  Hero(
                    tag: 'profile_avatar',
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 42,
                        backgroundColor: AppColor.white,
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor: AppColor.white,
                          backgroundImage: profilePhotoUrl != null
                              ? NetworkImage(profilePhotoUrl!)
                              : null,
                          child: profilePhotoUrl == null
                              ? Icon(
                                  Icons.person_rounded,
                                  size: 45,
                                  color: AppColor.primary,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: AppTextStyle.heading2(AppColor.white).copyWith(
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        if (email != null)
                          Text(
                            email!,
                            style: AppTextStyle.paragraph2(
                              AppColor.white.withValues(alpha: 0.9),
                            ).copyWith(
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  offset: const Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 8),
                        // User Type Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColor.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColor.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            userType?.toUpperCase() ?? 'USER',
                            style: AppTextStyle.caption(AppColor.white).copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /*// Edit Profile Button
                  Container(
                    decoration: BoxDecoration(
                      color: AppColor.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => _navigateToProfile(),
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: AppColor.white,
                        size: 22,
                      ),
                    ),
                  ),*/
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  '${totalRides ?? 0}',
                  style: AppTextStyle.heading2(AppColor.primary).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total Rides',
                  style: AppTextStyle.subtext1(AppColor.grey),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColor.lightGrey,
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      userRating?.toStringAsFixed(1) ?? '0.0',
                      style: AppTextStyle.heading3(AppColor.blackText).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Rating',
                  style: AppTextStyle.subtext1(AppColor.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyle.heading3(AppColor.blackText).copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildEnhancedMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyle.paragraph2(
                          isDestructive ? Colors.red : AppColor.blackText,
                        ).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyle.subtext1(AppColor.grey),
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColor.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToProfile() {
    Widget profileScreen;

    switch (userType?.toLowerCase()) {
      case 'driver':
        profileScreen = const DriverProfileScreen();
        break;
      case 'vendor':
        profileScreen = const CustomerProfileScreen(); // Replace with VendorProfileScreen when created
        break;
      case 'customer':
      default:
        profileScreen = const CustomerProfileScreen();
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => profileScreen),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final localizations = AppLocalizations.of(context)!;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.red, size: 28),
              const SizedBox(width: 12),
              Text(
                localizations.logout,
                style: AppTextStyle.heading3(AppColor.blackText),
              ),
            ],
          ),
          content: Text(
            localizations.logoutConfirmation,
            style: AppTextStyle.paragraph1(AppColor.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                localizations.cancel,
                style: AppTextStyle.paragraph2(AppColor.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                    (route) => false,
                  );
                }
                AuthServices.logout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: AppColor.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                localizations.logout,
                style: AppTextStyle.paragraph2(AppColor.white).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
