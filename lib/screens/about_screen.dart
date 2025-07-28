import 'package:flutter/material.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/Utilities/app_images.dart';
import 'package:sepesha_app/l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: AppColor.white,
        foregroundColor: AppColor.blackText,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo and Name
            Center(
              child: Column(
                children: [
                  Image.asset(
                    AppImages.sepeshaRedLogo,
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.appName,
                    style: AppTextStyle.heading2(AppColor.primary).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${localizations.version} 1.0.0',
                    style: AppTextStyle.subtext1(AppColor.grey),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // About Section
            _buildSection(
              title: 'About Sepesha',
              content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.\n\nExcepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium.',
            ),
            
            const SizedBox(height: 24),
            
            // Mission Section
            _buildSection(
              title: 'Our Mission',
              content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.\n\nDuis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident.',
            ),
            
            const SizedBox(height: 24),
            
            // Features Section
            _buildSection(
              title: 'Key Features',
              content: '• Lorem ipsum dolor sit amet consectetur\n• Adipiscing elit sed do eiusmod tempor\n• Incididunt ut labore et dolore magna\n• Aliqua ut enim ad minim veniam\n• Quis nostrud exercitation ullamco\n• Laboris nisi ut aliquip ex ea commodo',
            ),
            
            const SizedBox(height: 24),
            
            // Contact Section
            _buildSection(
              title: 'Contact Information',
              content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. For support and inquiries:\n\nEmail: support@sepesha.com\nPhone: +255 123 456 789\nWebsite: www.sepesha.com\n\nAddress:\nLorem ipsum street, 123\nDar es Salaam, Tanzania',
            ),
            
            const SizedBox(height: 32),
            
            // Legal Links
            _buildLegalSection(),
            
            const SizedBox(height: 32),
            
            // Copyright
            Center(
              child: Text(
                localizations.copyright,
                textAlign: TextAlign.center,
                style: AppTextStyle.subtext1(AppColor.grey),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.paragraph4(AppColor.blackText).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: AppTextStyle.paragraph1(AppColor.blackText).copyWith(
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildLegalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Legal',
          style: AppTextStyle.paragraph4(AppColor.blackText).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildLegalItem(
          title: 'Terms of Service',
          onTap: () {
            // TODO: Navigate to Terms of Service
          },
        ),
        _buildLegalItem(
          title: 'Privacy Policy',
          onTap: () {
            // TODO: Navigate to Privacy Policy
          },
        ),
        _buildLegalItem(
          title: 'End User License Agreement',
          onTap: () {
            // TODO: Navigate to EULA
          },
        ),
      ],
    );
  }

  Widget _buildLegalItem({required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyle.paragraph1(AppColor.primary).copyWith(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColor.primary,
            ),
          ],
        ),
      ),
    );
  }
}
