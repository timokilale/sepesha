import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/services/auth_services.dart';
import 'package:sepesha_app/services/session_manager.dart';
import 'package:sepesha_app/screens/auth/driver/widgets/image_upload_widget.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  File? _profileImage;
  bool _isLoading = false;
  String? _selectedRegion;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    try {
      final userData = SessionManager.instance;
      _firstNameController.text = userData.getFirstname;

      try {
        _middleNameController.text = userData.getMiddlename;
      } catch (e) {
        // Middle name might be null
        _middleNameController.text = '';
      }

      _lastNameController.text = userData.getLastname;
      _emailController.text = userData.getEmail;
      _phoneController.text = userData.phone.toString();
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: AppTextStyle.paragraph2(AppColor.blackText),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColor.blackText),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    ImageUploadWidget(
                      image: _profileImage,
                      // imageOnly:
                      //     true, // Only allow image files for profile picture
                      onImageSelected: (file) {
                        setState(() {
                          _profileImage = file;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Profile Picture',
                      style: AppTextStyle.paragraph1(AppColor.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Personal Information',
                style: AppTextStyle.paragraph2(AppColor.blackText),
              ),
              const SizedBox(height: 16),

              // First Name
              _buildTextField(
                controller: _firstNameController,
                label: 'First Name',
                validator:
                    (value) =>
                        value?.isEmpty ?? true
                            ? 'First name is required'
                            : null,
              ),
              const SizedBox(height: 16),

              // Middle Name
              _buildTextField(
                controller: _middleNameController,
                label: 'Middle Name (Optional)',
              ),
              const SizedBox(height: 16),

              // Last Name
              _buildTextField(
                controller: _lastNameController,
                label: 'Last Name',
                validator:
                    (value) =>
                        value?.isEmpty ?? true ? 'Last name is required' : null,
              ),
              const SizedBox(height: 16),

              // Email
              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Email is required';
                  if (!value!.contains('@')) return 'Invalid email format';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Phone number is required';
                  if (value!.length < 9) {
                    return 'Phone number must be at least 9 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Region Dropdown
              _buildRegionDropdown(),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ContinueButton(
                  onPressed: _isLoading ? () {} : _saveProfile,
                  isLoading: _isLoading,
                  text: 'Save Changes',
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildRegionDropdown() {
    // ToDo: fetch these from backend
    final regions = [
      {'id': '1', 'name': 'Dar es Salaam'},
      {'id': '2', 'name': 'Arusha'},
      {'id': '3', 'name': 'Dodoma'},
      {'id': '4', 'name': 'Mwanza'},
      {'id': '5', 'name': 'Mbeya'},
    ];

    return DropdownButtonFormField<String>(
      value: _selectedRegion,
      decoration: InputDecoration(
        labelText: 'Region',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items:
          regions
              .map(
                (region) => DropdownMenuItem<String>(
                  value: region['id'],
                  child: Text(region['name']!),
                ),
              )
              .toList(),
      onChanged: (value) {
        setState(() {
          _selectedRegion = value;
        });
      },
      hint: Text('Select Region'),
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Get user ID from session
        final userId =
            'current'; // Most APIs use 'current' or 'me' for the current user

        // final result = await AuthServices.updateProfile(
        //   context: context,
        //   userId: userId,
        //   firstName: _firstNameController.text,
        //   middleName:
        //       _middleNameController.text.isEmpty
        //           ? null
        //           : _middleNameController.text,
        //   lastName: _lastNameController.text,
        //   email: _emailController.text,
        //   phone: _phoneController.text,
        //   regionId:
        //       _selectedRegion != null ? int.parse(_selectedRegion!) : null,
        //   profilePhoto: _profileImage,
        // );

        // if (result != null) {
          // Profile updated successfully
          Navigator.pop(context, true); // Return true to indicate success
        //}
      } catch (e) {
        print('Error saving profile: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
