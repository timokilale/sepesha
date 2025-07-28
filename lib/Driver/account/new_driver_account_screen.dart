import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/Driver/profile/driver_profile_screen.dart';
import 'package:sepesha_app/Driver/wallet/presentation/wallet_screen.dart';
import 'package:sepesha_app/screens/payment_methods_screen.dart';
import 'package:sepesha_app/screens/auth/support/support_screen.dart';
import 'package:sepesha_app/screens/auth/auth_screen.dart';
import 'package:sepesha_app/screens/settings_screen.dart';
import 'package:sepesha_app/services/auth_services.dart';
import 'package:sepesha_app/Driver/dasboard/presentation/data/dashboard_repository.dart';
import 'package:sepesha_app/Driver/model/user_model.dart';
import 'package:sepesha_app/provider/payment_provider.dart';

class NewDriverAccountScreen extends StatefulWidget {
  const NewDriverAccountScreen({super.key});

  @override
  State<NewDriverAccountScreen> createState() => _NewDriverAccountScreenState();
}

class _NewDriverAccountScreenState extends State<NewDriverAccountScreen> with TickerProviderStateMixin {
  User? driverData;
  bool isLoading = true;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDriverData();
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

  Future<void> _loadDriverData() async {
    try {
      final data = await DashboardRepository().getUserData();
      setState(() {
        driverData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        driverData = User(
          id: 'fallback',
          name: 'Driver',
          email: 'driver@sepesha.com',
          phone: '+255000000000',
          vehicleNumber: 'N/A',
          vehicleType: 'Car',
          walletBalance: 0.0,
          rating: 0.0,
          totalRides: 0,
        );
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColor.white2,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColor.white2,
      body: RefreshIndicator(
        onRefresh: _loadDriverData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Enhanced Driver Profile Header
                  _buildEnhancedDriverProfileHeader(),
                  
                  // Content Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /*// Driver Stats Section
                        _buildDriverStatsSection(),
                        const SizedBox(height: 24),

                        // Vehicle Information Card
                        _buildVehicleInfoCard(),
                        const SizedBox(height: 24),

                        // Payment Preference Card
                        _buildPaymentPreferenceCard(),
                        const SizedBox(height: 32),*/

                        // Profile & Settings Section
                        _buildEnhancedMenuItem(
                          icon: Icons.person_outline_rounded,
                          title: 'Driver Profile',
                          subtitle: 'Manage your driver profile',
                          color: AppColor.primary,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DriverProfileScreen()),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildEnhancedMenuItem(
                          icon: Icons.account_balance_wallet_rounded,
                          title: 'Wallet',
                          subtitle: 'View wallet balance and transactions',
                          color: Colors.green,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const WalletScreen()),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildEnhancedMenuItem(
                          icon: Icons.payment_rounded,
                          title: 'Payment Methods',
                          subtitle: 'Manage payment options',
                          color: Colors.blue,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildEnhancedMenuItem(
                          icon: Icons.settings_rounded,
                          title: 'Settings',
                          subtitle: 'App preferences and settings',
                          color: Colors.grey,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SettingsScreen()),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildEnhancedMenuItem(
                          icon: Icons.help_outline_rounded,
                          title: 'Help & Support',
                          subtitle: 'Get help and support',
                          color: Colors.orange,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SupportScreen()),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildEnhancedMenuItem(
                          icon: Icons.logout_rounded,
                          title: 'Logout',
                          subtitle: 'Sign out of your account',
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

  Widget _buildEnhancedDriverProfileHeader() {
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
                    tag: 'driver_profile_avatar',
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
                          child: Icon(
                            Icons.person_rounded,
                            size: 45,
                            color: AppColor.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Driver Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driverData?.name ?? 'Driver',
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
                        Text(
                          driverData?.email ?? 'driver@sepesha.com',
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
                        // Driver Badge and Rating
                        Row(
                          children: [
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
                                'DRIVER',
                                style: AppTextStyle.caption(AppColor.white).copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Rating
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    driverData?.rating.toStringAsFixed(1) ?? '0.0',
                                    style: AppTextStyle.caption(AppColor.white).copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DriverProfileScreen()),
                      ),
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

  Widget _buildDriverStatsSection() {
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
                  '${driverData?.totalRides ?? 0}',
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
                Text(
                  'TZS ${driverData?.walletBalance.toStringAsFixed(0) ?? '0'}',
                  style: AppTextStyle.heading3(Colors.green).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Wallet Balance',
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
                      driverData?.rating.toStringAsFixed(1) ?? '0.0',
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

  Widget _buildVehicleInfoCard() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.directions_car_rounded, color: Colors.green, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                'Vehicle Information',
                style: AppTextStyle.heading3(AppColor.blackText).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vehicle Type',
                    style: AppTextStyle.subtext1(AppColor.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    driverData?.vehicleType ?? 'N/A',
                    style: AppTextStyle.paragraph2(AppColor.blackText).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Plate Number',
                    style: AppTextStyle.subtext1(AppColor.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    driverData?.vehicleNumber ?? 'N/A',
                    style: AppTextStyle.paragraph2(AppColor.blackText).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentPreferenceCard() {
    return Consumer<PaymentProvider>(
      builder: (context, provider, child) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.payment_rounded, color: Colors.blue, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Payment Preference',
                    style: AppTextStyle.heading3(AppColor.blackText).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                provider.selectedPaymentMethodName,
                style: AppTextStyle.paragraph2(AppColor.blackText).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (provider.selectedPaymentMethod?.type.name == 'wallet') ...[
                const SizedBox(height: 8),
                Text(
                  'Balance: ${provider.getFormattedWalletBalance()}',
                  style: AppTextStyle.subtext1(Colors.green).copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        );
      },
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.red, size: 28),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: AppTextStyle.heading3(AppColor.blackText),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout from your account?',
            style: AppTextStyle.paragraph1(AppColor.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
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
                'Logout',
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
