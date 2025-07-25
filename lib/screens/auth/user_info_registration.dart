import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/models/user_data.dart';

import 'package:sepesha_app/provider/registration_provider.dart';
import 'package:sepesha_app/screens/auth/driver/widgets/image_upload_widget.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _referralCodeController = TextEditingController();

  String? _selectedRegion;
  String _selectedUserType = 'customer';
  File? _profileImage;
  bool _privacyChecked = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (kDebugMode) {
      _firstNameController.text = 'John';
      _middleNameController.text = 'Michael';
      _lastNameController.text = 'Doe';
      _emailController.text = 'john.doe@example.com';
      _phoneController.text = '712345678';
      _passwordController.text = 'password123';
      _confirmPasswordController.text = 'password123';
      _referralCodeController.text = 'REF123';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<RegistrationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Create your account',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please provide your personal details to continue',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Profile Picture Section
              Center(
                child: Column(
                  children: [
                    ImageUploadWidget(
                      image: _profileImage,

                      onImageSelected: (file) {
                        setState(() {
                          _profileImage = file;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload Profile Picture',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Name Fields
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _firstNameController,
                      label: 'First Name *',
                      validator:
                          (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _middleNameController,
                      label: 'Middle Name',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _lastNameController,
                      label: 'Last Name *',
                      validator:
                          (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Email Field
              _buildTextField(
                controller: _emailController,
                label: 'Email Address *',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (!value!.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone Field
              _buildPhoneField(),
              const SizedBox(height: 16),

              // User Type Selection
              _buildUserTypeSelection(),
              const SizedBox(height: 16),

              // Region Dropdown
              _buildRegionDropdown(),
              const SizedBox(height: 16),

              // Referral Code (Optional)
              _buildTextField(
                controller: _referralCodeController,
                label: 'Referral Code (Optional)',
                prefixIcon: Icons.card_giftcard_outlined,
              ),
              const SizedBox(height: 16),

              // Password Fields
              _buildPasswordField(
                controller: _passwordController,
                label: 'Create Password *',
                obscureText: _obscurePassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (value!.length < 6) return 'Minimum 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildPasswordField(
                controller: _confirmPasswordController,
                label: 'Confirm Password *',
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Password must be at least 6 characters',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Privacy Checkbox
              _buildPrivacyCheckbox(),
              const SizedBox(height: 24),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ContinueButton(
                  onPressed:
                      _privacyChecked ? () => _submitForm(provider) : () {},
                  text: 'Continue',

                  isLoading: false,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeSelection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonFormField<String>(
        value: _selectedUserType,
        decoration: const InputDecoration(
          labelText: 'User Type *',
          prefixIcon: Icon(Icons.person_outline),
          border: InputBorder.none,
        ),
        items: const [
          DropdownMenuItem(value: 'customer', child: Text('Customer')),
          DropdownMenuItem(value: 'driver', child: Text('Driver')),
        ],
        onChanged: (String? newValue) {
          setState(() {
            _selectedUserType = newValue ?? 'customer';
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a user type';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool obscureText = false,
    IconData? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      decoration: InputDecoration(
        labelText: 'Phone Number *',
        prefix: const Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Text('255 | '),
        ),
        prefixIcon: const Icon(Icons.phone_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        hintText: '712345678',
      ),
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Required';
        if (value!.length != 9) return 'Must be 9 digits';
        if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Digits only';
        return null;
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: onToggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      obscureText: obscureText,
      validator: validator,
    );
  }

  Widget _buildRegionDropdown() {
    // ToDo: Fetch these from backend
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
        labelText: 'Region *',
        prefixIcon: const Icon(Icons.location_on_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
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
      validator: (value) => value == null ? 'Please select a region' : null,
    );
  }

  Widget _buildPrivacyCheckbox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Checkbox(
            value: _privacyChecked,
            onChanged: (bool? value) {
              setState(() {
                _privacyChecked = value ?? false;
              });
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap = () {
                            // Navigate to terms and conditions
                          },
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap = () {
                            // Navigate to privacy policy
                          },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm(RegistrationProvider provider) {
    if (_formKey.currentState?.validate() ?? false) {
      final user = UserData(
        firstName: _firstNameController.text,
        middleName: _middleNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        regionId: int.parse(_selectedRegion ?? '1'),
        referralCode:
            _referralCodeController.text.isEmpty
                ? null
                : _referralCodeController.text,
        password: _passwordController.text,
        profilePhoto: _profileImage,
        userType: _selectedUserType,
      );

      provider.updateUser(user, context);

      // Move to next step or submit
    }
  }
}
