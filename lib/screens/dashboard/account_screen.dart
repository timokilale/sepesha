import 'package:flutter/material.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_images.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/service/auth_services.dart';
import 'package:sepesha_app/services/session_manager.dart';

class AccountScreen extends StatelessWidget {
  AccountScreen({super.key});

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
      'icon': Icons.location_on,
      'title': 'Saved Addresses',
      'subtitle': 'Manage your saved locations',
    },
    {
      'icon': Icons.notifications,
      'title': 'Notifications',
      'subtitle': 'Customize your notification preferences',
    },
    {
      'icon': Icons.security,
      'title': 'Security',
      'subtitle': 'Manage your account security',
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
                onPressed: () {
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
    SessionManager _userData = SessionManager.instance;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColor.primary.withOpacity(0.1),
              child: Text(
                'JD',
                style: AppTextStyle.paragraph3(AppColor.primary),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userData.getFirstname,
                    style: AppTextStyle.paragraph2(AppColor.blackText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userData.getEmail,
                    style: AppTextStyle.paragraph1(AppColor.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+255${_userData.phone}',
                    style: AppTextStyle.paragraph1(AppColor.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: AppColor.primary),
              onPressed: () {
                // Handle edit profile
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountStats() {
    return Row(
      children: [
        _buildStatCard('12', 'Rides Taken', Icons.directions_car),
        const SizedBox(width: 16),
        _buildStatCard('4.8', 'Rating', Icons.star),
        const SizedBox(width: 16),
        _buildStatCard('3', 'Saved Places', Icons.favorite),
      ],
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
              // Handle settings item tap
            },
          );
        },
      ),
    );
  }
}
