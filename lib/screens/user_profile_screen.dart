import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/provider/user_profile_provider.dart';
import 'package:sepesha_app/screens/auth/driver/widgets/image_upload_widget.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _profileImage;
  String _selectedPaymentMethod = 'cash';
  bool _isEditing = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'value': 'cash', 'label': 'Cash', 'icon': Icons.money},
    {
      'value': 'wallet',
      'label': 'Wallet',
      'icon': Icons.account_balance_wallet,
    },
    {'value': 'card', 'label': 'Card', 'icon': Icons.credit_card},
    {'value': 'bank', 'label': 'Bank Transfer', 'icon': Icons.account_balance},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });
  }

  void _loadUserProfile() {
    final provider = context.read<UserProfileProvider>();
    provider.initializeFromSession();
    provider.loadUserProfile();
    _populateFields();
  }

  void _populateFields() {
    final provider = context.read<UserProfileProvider>();
    final user = provider.userProfile;

    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _middleNameController.text = user.middleName ?? '';
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber;
      _selectedPaymentMethod = provider.preferredPaymentMethod;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.blackText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: AppTextStyle.heading3(AppColor.blackText),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
              if (!_isEditing) {
                _populateFields(); // Reset fields if canceling edit
              }
            },
            child: Text(
              _isEditing ? 'Cancel' : 'Edit',
              style: AppTextStyle.paragraph2(AppColor.primary),
            ),
          ),
        ],
      ),
      body: Consumer<UserProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.errorMessage!,
                    style: AppTextStyle.paragraph1(AppColor.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadUserProfile,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refreshProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(provider),
                    const SizedBox(height: 24),
                    _buildPersonalInfoSection(provider),
                    const SizedBox(height: 24),
                    _buildAccountStatsSection(provider),
                    const SizedBox(height: 24),
                    _buildPaymentPreferencesSection(provider),
                    const SizedBox(height: 32),
                    if (_isEditing) _buildSaveButton(provider),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserProfileProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            if (_isEditing)
              ImageUploadWidget(
                image: _profileImage,
                onImageSelected: (file) {
                  setState(() {
                    _profileImage = file;
                  });
                },
              )
            else
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColor.primary.withOpacity(0.1),
                backgroundImage:
                    provider.profilePhotoUrl != null
                        ? NetworkImage(provider.profilePhotoUrl!)
                        : null,
                child:
                    provider.profilePhotoUrl == null
                        ? Text(
                          _getInitials(provider.userProfile),
                          style: AppTextStyle.heading2(AppColor.primary),
                        )
                        : null,
              ),
            const SizedBox(height: 16),
            Text(
              _getFullName(provider.userProfile),
              style: AppTextStyle.heading3(AppColor.blackText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  provider.isVerified ? Icons.verified : Icons.pending,
                  color: provider.isVerified ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  provider.isVerified
                      ? 'Verified Account'
                      : 'Pending Verification',
                  style: AppTextStyle.subtext1(
                    provider.isVerified ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(UserProfileProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: AppTextStyle.paragraph2(AppColor.blackText),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _firstNameController,
              label: 'First Name',
              enabled: _isEditing,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'First name is required';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _lastNameController,
              label: 'Last Name',
              enabled: _isEditing,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Last name is required';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _middleNameController,
              label: 'Middle Name (Optional)',
              enabled: _isEditing,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              enabled: _isEditing,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Email is required';
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value!)) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              enabled: false, // Phone number usually shouldn't be editable
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountStatsSection(UserProfileProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Statistics',
              style: AppTextStyle.paragraph2(AppColor.blackText),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Rides',
                    provider.totalRides.toString(),
                    Icons.directions_car,
                    AppColor.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Average Rating',
                    provider.averageRating.toStringAsFixed(1),
                    Icons.star,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Wallet (TZS)',
                    'TZS ${provider.walletBalanceTzs.toStringAsFixed(0)}',
                    Icons.account_balance_wallet,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Wallet (USD)',
                    '\$${provider.walletBalanceUsd.toStringAsFixed(2)}',
                    Icons.attach_money,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentPreferencesSection(UserProfileProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Preferences',
              style: AppTextStyle.paragraph2(AppColor.blackText),
            ),
            const SizedBox(height: 16),
            if (_isEditing)
              Column(
                children:
                    _paymentMethods.map((method) {
                      return RadioListTile<String>(
                        title: Row(
                          children: [
                            Icon(method['icon'], size: 20),
                            const SizedBox(width: 8),
                            Text(method['label']),
                          ],
                        ),
                        value: method['value'],
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                      );
                    }).toList(),
              )
            else
              ListTile(
                leading: Icon(
                  _paymentMethods.firstWhere(
                    (method) =>
                        method['value'] == provider.preferredPaymentMethod,
                    orElse: () => _paymentMethods[0],
                  )['icon'],
                  color: AppColor.primary,
                ),
                title: Text(
                  'Preferred Payment Method',
                  style: AppTextStyle.subtext1(AppColor.grey),
                ),
                subtitle: Text(
                  _paymentMethods.firstWhere(
                    (method) =>
                        method['value'] == provider.preferredPaymentMethod,
                    orElse: () => _paymentMethods[0],
                  )['label'],
                  style: AppTextStyle.paragraph1(AppColor.blackText),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColor.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColor.primary),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColor.grey.withOpacity(0.1)),
        ),
        filled: !enabled,
        fillColor: enabled ? null : AppColor.grey.withOpacity(0.05),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyle.paragraph2(AppColor.blackText)),
          Text(
            title,
            style: AppTextStyle.subtext1(AppColor.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(UserProfileProvider provider) {
    return ContinueButton(
      onPressed: _saveProfile,
      isLoading: provider.isUpdating,
      text: 'SAVE CHANGES',
      backgroundColor: AppColor.primary,
    );
  }

  void _saveProfile() async {
    final provider = context.read<UserProfileProvider>();

    // Don't proceed if already updating
    if (provider.isUpdating) return;

    if (!_formKey.currentState!.validate()) return;

    final success = await provider.updateProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      middleName:
          _middleNameController.text.isEmpty
              ? null
              : _middleNameController.text,
      email: _emailController.text,
      preferredPaymentMethod: _selectedPaymentMethod,
      profilePhoto: _profileImage,
    );

    if (success) {
      setState(() {
        _isEditing = false;
        _profileImage = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
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
}
