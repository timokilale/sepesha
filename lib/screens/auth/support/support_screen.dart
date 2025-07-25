import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support & Help'),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Safely pop, this should always work since support is accessed from drawer
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 48,
                    color: AppColor.primaryColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Need Help?',
                    style: AppTextStyle.headingTextStyle.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Our support team is here to help you 24/7',
                    style: AppTextStyle.bodyTextStyle.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Contact Us',
              style: AppTextStyle.headingTextStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            // Contact Options
            _buildContactOption(
              context,
              icon: Icons.chat,
              title: 'WhatsApp Chat',
              subtitle: 'Quick response via WhatsApp',
              contact: '0762821819',
              color: const Color(0xFF25D366),
              onTap: () => _openWhatsApp('0762821819'),
            ),

            const SizedBox(height: 12),

            _buildContactOption(
              context,
              icon: Icons.phone,
              title: 'Phone Call',
              subtitle: 'Speak directly with our team',
              contact: '0762821819',
              color: Colors.blue,
              onTap: () => _makePhoneCall('0762821819'),
            ),

            const SizedBox(height: 12),

            _buildContactOption(
              context,
              icon: Icons.email,
              title: 'Email Support',
              subtitle: 'Send us a detailed message',
              contact: 'support@sepesha.com',
              color: Colors.orange,
              onTap: () => _sendEmail('support@sepesha.com'),
            ),

            const SizedBox(height: 24),

            // Additional Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Support Hours',
                        style: AppTextStyle.bodyTextStyle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '24/7 - We\'re always here to help',
                    style: AppTextStyle.bodyTextStyle.copyWith(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String contact,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: AppTextStyle.bodyTextStyle.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: AppTextStyle.bodyTextStyle.copyWith(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              contact,
              style: AppTextStyle.bodyTextStyle.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }

  // Open WhatsApp
  Future<void> _openWhatsApp(String phoneNumber) async {
    // Remove any non-digit characters and ensure proper format
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final whatsappNumber = cleanNumber.startsWith('0') 
        ? '255${cleanNumber.substring(1)}' // Convert 0762... to 255762...
        : cleanNumber;
    
    final whatsappUrl = 'https://wa.me/$whatsappNumber?text=Hello, I need support with Sepesha app';
    
    try {
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch WhatsApp');
      }
    } catch (e) {
      print('Error opening WhatsApp: $e');
      // Fallback to regular phone call
      _makePhoneCall(phoneNumber);
    }
  }

  // Make phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final phoneUrl = 'tel:$phoneNumber';
    
    try {
      if (await canLaunchUrl(Uri.parse(phoneUrl))) {
        await launchUrl(Uri.parse(phoneUrl));
      } else {
        throw Exception('Could not make phone call');
      }
    } catch (e) {
      print('Error making phone call: $e');
    }
  }

  // Send email
  Future<void> _sendEmail(String email) async {
    final emailUrl = 'mailto:$email?subject=Sepesha App Support&body=Hello, I need help with...';
    
    try {
      if (await canLaunchUrl(Uri.parse(emailUrl))) {
        await launchUrl(Uri.parse(emailUrl));
      } else {
        throw Exception('Could not open email app');
      }
    } catch (e) {
      print('Error opening email: $e');
    }
  }
}