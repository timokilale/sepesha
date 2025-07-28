import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/provider/user_profile_provider.dart';
import 'package:sepesha_app/screens/auth/driver/widgets/image_upload_widget.dart';
import 'package:sepesha_app/Utilities/feedback_manager.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  File? _profileImage;

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileProvider>().loadUserProfile();
    });
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

  void _populateFields() {
    final provider = context.read<UserProfileProvider>();
    final user = provider.userProfile;
    
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _middleNameController.text = user.middleName ?? '';
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information'),
        backgroundColor: AppColor.white,
        foregroundColor: AppColor.black,
        elevation: 0,
        actions: [
          Consumer<UserProfileProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(_isEditing ? Icons.close : Icons.edit),
                onPressed: provider.isUpdating ? null : () {
                  setState(() {
                    _isEditing = !_isEditing;
                    if (!_isEditing) {
                      _profileImage = null;
                      _populateFields();
                    }
                  });
                },
              );
            },
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
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    style: AppTextStyle.paragraph1(Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.loadUserProfile,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.userProfile == null) {
            return const Center(
              child: Text('No profile data available'),
            );
          }

          final user = provider.userProfile!;
          _populateFields();

          return RefreshIndicator(
            onRefresh: provider.loadUserProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildProfileHeader(user),
                    const SizedBox(height: 24),
                    _buildPersonalInfo(user),
                    const SizedBox(height: 24),
                    _buildAccountInfo(user),
                    const SizedBox(height: 32),
                    if (_isEditing) _buildActionButtons(provider),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
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
                backgroundColor: AppColor.primary,
                backgroundImage: user.profilePhotoUrl != null 
                    ? NetworkImage(user.profilePhotoUrl!) 
                    : null,
                child: user.profilePhotoUrl == null 
                    ? Text(
                        _getInitials(user),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            const SizedBox(height: 16),
            Text(
              _getFullName(user),
              style: AppTextStyle.paragraph4(AppColor.blackText).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user.userType?.toUpperCase() ?? 'CUSTOMER',
                style: AppTextStyle.subtext1(AppColor.primary).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo(dynamic user) {
    return _buildSection(
      title: 'Personal Information',
      icon: Icons.person,
      children: [
        _buildTextField(
          controller: _firstNameController,
          label: 'First Name',
          icon: Icons.person_outline,
          enabled: _isEditing,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'First name is required';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _middleNameController,
          label: 'Middle Name',
          icon: Icons.person_outline,
          enabled: _isEditing,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _lastNameController,
          label: 'Last Name',
          icon: Icons.person_outline,
          enabled: _isEditing,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Last name is required';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          enabled: _isEditing,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Email is required';
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAccountInfo(dynamic user) {
    return _buildSection(
      title: 'Account Information',
      icon: Icons.account_circle,
      children: [
        _buildReadOnlyField(
          label: 'Phone Number',
          value: '+255 ${user.phoneNumber ?? 'Not provided'}',
          icon: Icons.phone_outlined,
        ),
        const SizedBox(height: 16),
        _buildReadOnlyField(
          label: 'User Type',
          value: user.userType?.toUpperCase() ?? 'CUSTOMER',
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 16),
        _buildReadOnlyField(
          label: 'Account Status',
          value: (user.isVerified ?? false) ? 'Verified' : 'Unverified',
          icon: Icons.verified_user_outlined,
        ),
        if (user.walletBalanceTzs != null) ...[
          const SizedBox(height: 16),
          _buildReadOnlyField(
            label: 'Wallet Balance (TZS)',
            value: 'TZS ${user.walletBalanceTzs!.toStringAsFixed(0)}',
            icon: Icons.account_balance_wallet_outlined,
          ),
        ],
        if (user.walletBalanceUsd != null) ...[
          const SizedBox(height: 16),
          _buildReadOnlyField(
            label: 'Wallet Balance (USD)',
            value: 'USD ${user.walletBalanceUsd!.toStringAsFixed(2)}',
            icon: Icons.attach_money_outlined,
          ),
        ],
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColor.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyle.paragraph4(AppColor.blackText).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
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
        prefixIcon: Icon(icon, color: enabled ? AppColor.primary : Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.primary),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[50],
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyle.subtext1(Colors.grey[600]!),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyle.paragraph1(AppColor.blackText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(UserProfileProvider provider) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: provider.isUpdating ? null : () {
              setState(() {
                _isEditing = false;
                _profileImage = null;
                _populateFields();
              });
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: provider.isUpdating ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: provider.isUpdating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Save Changes',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  String _getFullName(dynamic user) {
    if (user == null) return 'User Name';
    final firstName = user.firstName ?? '';
    final lastName = user.lastName ?? '';
    final middleName = user.middleName ?? '';

    if (middleName.isNotEmpty) {
      return '$firstName $middleName $lastName'.trim();
    }
    final fullName = '$firstName $lastName'.trim();
    return fullName.isEmpty ? 'User Name' : fullName;
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

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<UserProfileProvider>();

    final success = await provider.updateProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      middleName: _middleNameController.text.isEmpty ? null : _middleNameController.text,
      email: _emailController.text,
      profilePhoto: _profileImage,
    );

    if (success) {
      setState(() {
        _isEditing = false;
        _profileImage = null;
      });
      if (mounted) {
        context.feedback.showSuccess(
          context: context,
          title: 'Success',
          description: 'Profile updated successfully',
        );
      }
    } else {
      if (mounted) {
        context.feedback.showError(
          context: context,
          title: 'Error',
          description: provider.errorMessage ?? 'Failed to update profile',
        );
      }
    }
  }


}
