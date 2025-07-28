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
import 'package:sepesha_app/screens/conversation_list_screen.dart';
import 'package:sepesha_app/services/auth_services.dart';
import 'package:sepesha_app/services/preferences.dart';
import 'package:sepesha_app/services/session_manager.dart';
import 'package:sepesha_app/Driver/profile/driver_profile_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String? firstName;
  String? lastName;
  String? email;
  String? profilePhotoUrl;
  String? userType;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
      }

      setState(() {});
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Section
            _buildProfileHeader(),
            const SizedBox(height: 32),

            // Main Actions Section
            _buildSectionTitle('Profile & Settings'),
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Personal Information',
              subtitle: 'Manage your profile details',
              onTap: () => _navigateToProfile(),
            ),
            _buildMenuItem(
              icon: Icons.payment,
              title: 'Payment Methods',
              subtitle: 'Manage your payment options',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()),
              ),
            ),
            _buildMenuItem(
              icon: Icons.chat_bubble_outline,
              title: 'Messages',
              subtitle: 'View your conversations',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ConversationsScreen()),
              ),
            ),

            const SizedBox(height: 24),

            // Support Section
            _buildSectionTitle('Support & Information'),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get help and support',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SupportScreen()),
              ),
            ),
            _buildMenuItem(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'App information and version',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
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

  Widget _buildProfileHeader() {
    final fullName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    final displayName = fullName.isNotEmpty ? fullName : 'User';

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
          // Profile Avatar
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
              backgroundImage: profilePhotoUrl != null
                  ? NetworkImage(profilePhotoUrl!)
                  : null,
              child: profilePhotoUrl == null
                  ? Icon(
                      Icons.person_rounded,
                      size: 35,
                      color: AppColor.primary,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppTextStyle.heading2(AppColor.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (email != null)
                  Text(
                    email!,
                    style: AppTextStyle.subtext1(AppColor.white.withOpacity(0.9)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColor.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    userType?.toUpperCase() ?? 'USER',
                    style: AppTextStyle.paragraph1(AppColor.white),
                  ),
                ),
              ],
            ),
          ),

          // Edit Profile Button
          IconButton(
            onPressed: () => _navigateToProfile(),
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColor.white,
            ),
          ),
        ],
      ),
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

  void _navigateToProfile() {
    // Navigate to appropriate profile screen based on user type
    Widget profileScreen;
    
    switch (userType?.toLowerCase()) {
      case 'driver':
        // Import and use DriverProfileScreen
        profileScreen = const CustomerProfileScreen(); // Replace with DriverProfileScreen when imported
        break;
      case 'vendor':
        // Create VendorProfileScreen or use appropriate screen
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