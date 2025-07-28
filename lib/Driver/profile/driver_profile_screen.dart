import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/Driver/model/user_model.dart';
import 'package:sepesha_app/Driver/profile/driver_profile_provider.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/Utilities/feedback_manager.dart';
import 'package:sepesha_app/widgets/smart_driver_rating.dart';
import 'package:sepesha_app/screens/auth/driver/widgets/image_upload_widget.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverProfileProvider>().loadDriverProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _populateFields(User driver) {
    if (!_isEditing) {
      _nameController.text = driver.name;
      _emailController.text = driver.email;
      _phoneController.text = driver.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Profile'),
        backgroundColor: AppColor.white,
        foregroundColor: AppColor.black,
        elevation: 0,
        actions: [
          Consumer<DriverProfileProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(_isEditing ? Icons.close : Icons.edit),
                onPressed: provider.isUpdating ? null : () {
                  setState(() {
                    _isEditing = !_isEditing;
                    if (!_isEditing) {
                      _profileImage = null;
                      if (provider.driverData != null) {
                        _populateFields(provider.driverData!);
                      }
                    }
                  });
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<DriverProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.paragraph1(AppColor.grey),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Retry',
                    onPressed: () => provider.loadDriverProfile(),
                  ),
                ],
              ),
            );
          }
          
          if (provider.driverData == null) {
            return const Center(child: Text('No profile data found'));
          }
          
          final driver = provider.driverData!;
          _populateFields(driver);
          
          return RefreshIndicator(
            onRefresh: provider.loadDriverProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildProfileHeader(driver),
                    const SizedBox(height: 24),
                    _buildPersonalInfo(driver),
                    const SizedBox(height: 24),
                    _buildVehicleInfo(driver),
                    const SizedBox(height: 24),
                    _buildStatsSection(driver),
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

  Widget _buildProfileHeader(User driver) {
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
                child: const Icon(Icons.person, size: 50, color: Colors.white),
              ),
            const SizedBox(height: 16),
            Text(
              driver.name,
              style: AppTextStyle.heading3(AppColor.blackText).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SmartDriverRating(
              driverId: driver.id,
              iconSize: 16.0,
              fallbackRating: driver.rating,
              fallbackReviews: driver.totalRides,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green, 
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Online', 
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo(User driver) {
    return _buildSection(
      title: 'Personal Information',
      icon: Icons.person,
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          icon: Icons.person_outline,
          enabled: _isEditing,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Name is required';
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
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          enabled: false, 
        ),
      ],
    );
  }

  Widget _buildVehicleInfo(User driver) {
    return _buildSection(
      title: 'Vehicle Information',
      icon: Icons.directions_car,
      children: [
        _buildReadOnlyField(
          label: 'Vehicle Type',
          value: driver.vehicleType,
          icon: Icons.car_rental,
        ),
        const SizedBox(height: 16),
        _buildReadOnlyField(
          label: 'Vehicle Number',
          value: driver.vehicleNumber,
          icon: Icons.confirmation_number_outlined,
        ),
        const SizedBox(height: 16),
        _buildReadOnlyField(
          label: 'License Number',
          value: 'Not provided', 
          icon: Icons.credit_card,
        ),
      ],
    );
  }

  Widget _buildStatsSection(User driver) {
    return _buildSection(
      title: 'Driver Statistics',
      icon: Icons.analytics,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Rides',
                driver.totalRides.toString(),
                Icons.directions_car,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Rating',
                driver.rating.toStringAsFixed(1),
                Icons.star,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Wallet Balance',
                'TZS ${driver.walletBalance.toStringAsFixed(0)}',
                Icons.account_balance_wallet,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Status',
                'Active', 
                Icons.circle,
                Colors.green,
              ),
            ),
          ],
        ),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColor.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyle.paragraph2(AppColor.blackText).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
        prefixIcon: Icon(icon),
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

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: AppColor.grey.withOpacity(0.05),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(DriverProfileProvider provider) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            text: 'Cancel',
            onPressed: provider.isUpdating ? null : () {
              setState(() => _isEditing = false);
            },
            backgroundColor: Colors.grey,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppButton(
            text: provider.isUpdating ? 'Saving...' : 'Save Changes',
            onPressed: provider.isUpdating ? null : _saveProfile,
          ),
        ),
      ],
    );
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<DriverProfileProvider>();
    
    final success = await provider.updateDriverProfile(
      firstName: _nameController.text,
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