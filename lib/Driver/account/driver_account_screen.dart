import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/Driver/profile/driver_profile_screen.dart';
import 'package:sepesha_app/Driver/wallet/presentation/wallet_screen.dart';
import 'package:sepesha_app/screens/payment_methods_screen.dart';
import 'package:sepesha_app/screens/auth/support/support_screen.dart';
import 'package:sepesha_app/screens/auth/auth_screen.dart';
import 'package:sepesha_app/services/auth_services.dart';
import 'package:sepesha_app/Driver/dasboard/presentation/data/dashboard_repository.dart';
import 'package:sepesha_app/Driver/model/user_model.dart';
import 'package:sepesha_app/provider/payment_provider.dart';

class DriverAccountScreen extends StatefulWidget {
  const DriverAccountScreen({super.key});

  @override
  State<DriverAccountScreen> createState() => _DriverAccountScreenState();
}

class _DriverAccountScreenState extends State<DriverAccountScreen> {
  User? driverData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDriverData();
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
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver Profile Header
            _buildDriverProfileHeader(),
            const SizedBox(height: 24),

            // Vehicle Information Card
            _buildVehicleInfoCard(),
            const SizedBox(height: 24),

            // Payment Preference Card
            _buildPaymentPreferenceCard(),
            const SizedBox(height: 32),

            // Profile & Settings Section
            _buildSectionTitle('Profile & Settings'),
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Driver Profile',
              subtitle: 'Manage your driver profile',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DriverProfileScreen()),
              ),
            ),
            _buildMenuItem(
              icon: Icons.account_balance_wallet,
              title: 'Wallet',
              subtitle: 'View wallet balance and transactions',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WalletScreen()),
              ),
            ),
            _buildMenuItem(
              icon: Icons.payment,
              title: 'Payment Methods',
              subtitle: 'Manage payment options',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()),
              ),
            ),
            _buildMenuItem(
              icon: Icons.settings,
              title: 'Settings',
              subtitle: 'App preferences and settings',
              onTap: () {
                // Navigate to settings when implemented
              },
            ),

            const SizedBox(height: 24),

            // Support Section
            _buildSectionTitle('Support'),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get help and support',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SupportScreen()),
              ),
            ),

            const SizedBox(height: 32),

            // Logout Section
            _buildMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              onTap: () => _showLogoutDialog(),
              isDestructive: true,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.primary, AppColor.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Driver Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: AppColor.white,
              child: Icon(
                Icons.person_rounded,
                size: 35,
                color: AppColor.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Driver Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driverData?.name ?? 'Driver',
                  style: AppTextStyle.heading2(AppColor.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  driverData?.email ?? 'driver@sepesha.com',
                  style: AppTextStyle.subtext1(AppColor.white.withOpacity(0.9)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColor.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'DRIVER',
                        style: AppTextStyle.paragraph4(AppColor.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.star, color: Colors.yellow, size: 16),
                    Text(
                      ' ${driverData?.rating.toStringAsFixed(1) ?? '0.0'}',
                      style: AppTextStyle.paragraph4(AppColor.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Edit Profile Button
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DriverProfileScreen()),
            ),
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColor.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_car, color: Colors.green, size: 24),
              const SizedBox(width: 12),
              Text(
                'Vehicle Information',
                style: AppTextStyle.heading3(Colors.green[800]!),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vehicle Type',
                    style: AppTextStyle.paragraph4(AppColor.grey),
                  ),
                  Text(
                    driverData?.vehicleType ?? 'N/A',
                    style: AppTextStyle.paragraph1(AppColor.blackText),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Plate Number',
                    style: AppTextStyle.paragraph4(AppColor.grey),
                  ),
                  Text(
                    driverData?.vehicleNumber ?? 'N/A',
                    style: AppTextStyle.paragraph1(AppColor.blackText),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${driverData?.totalRides ?? 0} rides completed',
            style: AppTextStyle.subtext1(AppColor.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentPreferenceCard() {
    return Consumer<PaymentProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.payment, color: Colors.blue, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Payment Preference',
                    style: AppTextStyle.heading3(Colors.blue[800]!),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                provider.selectedPaymentMethodName,
                style: AppTextStyle.paragraph1(AppColor.blackText),
              ),
              if (provider.selectedPaymentMethod?.type.name == 'wallet') ...[
                const SizedBox(height: 4),
                Text(
                  'Balance: ${provider.getFormattedWalletBalance()}',
                  style: AppTextStyle.subtext1(Colors.green[700]!),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTextStyle.heading3(AppColor.blackText),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.lightGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive 
                ? Colors.red.withOpacity(0.1) 
                : AppColor.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : AppColor.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyle.paragraph1(
            isDestructive ? Colors.red : AppColor.blackText,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyle.subtext1(AppColor.grey),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColor.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Logout',
            style: AppTextStyle.heading3(AppColor.blackText),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: AppTextStyle.paragraph1(AppColor.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTextStyle.paragraph1(AppColor.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await AuthServices.logout(context);
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: AppColor.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}