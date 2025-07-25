import 'package:flutter/material.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_images.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/provider/user_profile_provider.dart';
import 'package:sepesha_app/screens/about_screen.dart';
import 'package:sepesha_app/screens/auth/auth_screen.dart';
import 'package:sepesha_app/screens/auth/support/support_screen.dart';
import 'package:sepesha_app/screens/customer_profile_screen.dart';
import 'package:sepesha_app/screens/payment_methods_screen.dart';
import 'package:sepesha_app/screens/user_profile_screen.dart';
import 'package:sepesha_app/services/auth_services.dart';
import 'package:sepesha_app/services/session_manager.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/provider/payment_provider.dart';

class AccountScreen extends StatefulWidget {
  AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUserProfile();
    });
  }

  void _initializeUserProfile() {
    final provider = context.read<UserProfileProvider>();
    provider.initializeFromSession();

    // Also initialize other session data
    final sessionUser = SessionManager.instance.user;
    if (sessionUser != null) {
      // The provider should now have the user data
      provider.notifyListeners();
    }
  }

  final List<Map<String, dynamic>> _settingsItems = [
    {
      'icon': Icons.person,
      'title': 'Personal Information',
      'subtitle': 'Manage your personal details',
    },
    {
      'icon': Icons.payment,
      'title': 'Payment Methods',
      'subtitle': 'Add or remove payment options',
    },
    {
      'icon': Icons.help,
      'title': 'Help & Support',
      'subtitle': 'Get help with your account',
    },
    {
      'icon': Icons.info,
      'title': 'About',
      'subtitle': 'Terms, Privacy, and App information',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white2,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   automaticallyImplyLeading: false,
      //   title: Text(
      //     'My Account',
      //     style: AppTextStyle.paragraph2(AppColor.blackText),
      //   ),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.settings),
      //       onPressed: () {},
      //     ),
      //   ],
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSection(),
              const SizedBox(height: 24),
              _buildAccountStats(),
              const SizedBox(height: 24),
              _buildSettingsList(),
              const SizedBox(height: 24),
              ContinueButton(
                onPressed: () async {
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthScreen()),
                      (route) => false,
                    );
                  }
                  AuthServices.logout(context);
                },
                isLoading: false,
                text: 'LOGOUT',
                backgroundColor: AppColor.primary,
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    // Handle delete account
                  },
                  child: Text(
                    'Delete Account',
                    style: AppTextStyle.paragraph1(AppColor.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, child) {
        final user = profileProvider.userProfile;
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColor.primary.withOpacity(0.1),
                  backgroundImage:
                      profileProvider.profilePhotoUrl != null
                          ? NetworkImage(profileProvider.profilePhotoUrl!)
                          : null,
                  child:
                      profileProvider.profilePhotoUrl == null
                          ? Text(
                            _getInitials(user),
                            style: AppTextStyle.paragraph3(AppColor.primary),
                          )
                          : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getFullName(user),
                        style: AppTextStyle.paragraph2(AppColor.blackText),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'No email',
                        style: AppTextStyle.subtext1(AppColor.grey),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _getPaymentIcon(
                              profileProvider.preferredPaymentMethod,
                            ),
                            size: 16,
                            color: AppColor.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Preferred payment: ${_getPaymentLabel(profileProvider.preferredPaymentMethod)}',
                            style: AppTextStyle.subtext1(AppColor.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: AppColor.primary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserProfileScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getFullName(dynamic user) {
    if (user == null) return 'User Name';
    final firstName = user.firstName ?? '';
    final lastName = user.lastName ?? '';
    final middleName = user.middleName ?? '';

    if (middleName.isNotEmpty) {
      return '$firstName $middleName $lastName';
    }
    return '$firstName $lastName';
  }

  String _getInitials(dynamic user) {
    if (user == null) return 'UN';
    final firstName = user.firstName ?? '';
    final lastName = user.lastName ?? '';

    String initials = '';
    if (firstName.isNotEmpty) initials += firstName[0];
    if (lastName.isNotEmpty) initials += lastName[0];

    return initials.isEmpty ? 'UN' : initials.toUpperCase();
  }

  IconData _getPaymentIcon(String paymentMethod) {
    switch (paymentMethod) {
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'card':
        return Icons.credit_card;
      case 'bank':
        return Icons.account_balance;
      default:
        return Icons.money;
    }
  }

  String _getPaymentLabel(String paymentMethod) {
    switch (paymentMethod) {
      case 'wallet':
        return 'Wallet';
      case 'card':
        return 'Card';
      case 'bank':
        return 'Bank Transfer';
      default:
        return 'Cash';
    }
  }

  Widget _buildAccountStats() {
    return Consumer<UserProfileProvider>(
      builder: (context, provider, child) {
        final user = provider.userProfile;
        return Row(
          children: [
            _buildStatCard(
              '${user?.totalRides ?? 0}',
              'Rides Taken',
              Icons.directions_car,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              user?.averageRating?.toStringAsFixed(1) ?? '0.0',
              'Rating',
              Icons.star,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              '3',
              'Saved Places',
              Icons.favorite,
            ), // Keep hardcoded for now
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Icon(icon, color: AppColor.primary, size: 24),
              const SizedBox(height: 8),
              Text(value, style: AppTextStyle.paragraph2(AppColor.blackText)),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyle.subtext1(AppColor.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _settingsItems.length,
        separatorBuilder: (context, index) => Divider(height: 1),
        itemBuilder: (context, index) {
          final item = _settingsItems[index];
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item['icon'], color: AppColor.primary),
            ),
            title: Text(
              item['title'],
              style: AppTextStyle.paragraph1(AppColor.blackText),
            ),
            subtitle: Text(
              item['subtitle'],
              style: AppTextStyle.subtext1(AppColor.grey),
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              if (item['title'] == 'Personal Information') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomerProfileScreen(),
                  ),
                );
              } else if (item['title'] == 'Payment Methods') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaymentMethodsScreen(),
                  ),
                );
              } else if (item['title'] == 'Help & Support') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SupportScreen(),
                  ),
                );
              } else if (item['title'] == 'About') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutScreen(),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
