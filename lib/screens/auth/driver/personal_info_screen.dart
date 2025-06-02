import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/models/driver_model.dart';
import 'package:sepesha_app/provider/registration_provider.dart';
import 'package:sepesha_app/screens/auth/driver/widgets/image_upload_widget.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _licenseNumberController =
      TextEditingController();
  final TextEditingController _licenseExpiryController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _selectedCity;
  File? _profileImage;
  bool _isChecked = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenseNumberController.dispose();
    _licenseExpiryController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  @override
  void initState() {
    if (kDebugMode) {
      _firstNameController.text = 'John';
      _lastNameController.text = 'Doe';
      _emailController.text = 'john.doe@example.com';
      _phoneController.text = '+255712345678';
      _licenseNumberController.text = 'D1234567890';
      _licenseExpiryController.text = '2027-12-31';
      _passwordController.text = 'password123';
      _confirmPasswordController.text = 'password123';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RegistrationProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Profile Picture Section
            Column(
              children: [
                ImageUploadWidget(
                  image: _profileImage,
                  isCircle: false,
                  onImageSelected: (file) {
                    setState(() {
                      _profileImage = file;
                    });
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'Upload a Profile Picture',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Name Fields
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _firstNameController,
                    label: 'First Name',
                    validator:
                        (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _lastNameController,
                    label: 'Last Name',
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
              label: 'Email Address',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                if (!value!.contains('@')) return 'Invalid email';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone Field
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // City Dropdown
            _buildCityDropdown(),
            const SizedBox(height: 16),

            // License Fields
            _buildTextField(
              controller: _licenseNumberController,
              label: 'License Number',
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _licenseExpiryController,
              label: 'License Expiry Date (YYYY-MM-DD)',
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // Password Fields
            _buildTextField(
              controller: _passwordController,
              label: 'Create Strong Password',
              obscureText: true,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                if (value!.length < 6) return 'Password too short';
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              obscureText: true,
              validator: (value) {
                if (value != _passwordController.text)
                  return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Terms Checkbox
            _buildTermsCheckbox(),
            const SizedBox(height: 24),

            ContinueButton(
              onPressed: _isChecked ? () => _submitForm(provider) : () {},
              isLoading: false,
            ),
            // Continue Button
            // ElevatedButton(
            //   onPressed: _isChecked ? () => _submitForm(provider) : null,
            //   child: const Text('Continue'),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
    );
  }

  Widget _buildCityDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCity,
      decoration: InputDecoration(
        labelText: 'Select City',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items:
          ['Dar es Salaam', 'Arusha', 'Mwanza', 'Dodoma', 'Mbeya']
              .map(
                (String value) =>
                    DropdownMenuItem<String>(value: value, child: Text(value)),
              )
              .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCity = value;
        });
      },
      validator: (value) => value == null ? 'Please select a city' : null,
    );
  }

  Widget _buildTermsCheckbox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        title: RichText(
          text: const TextSpan(
            style: TextStyle(color: Colors.black),
            children: [
              TextSpan(text: 'I agree to the '),
              TextSpan(
                text: 'Terms & Conditions',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        value: _isChecked,
        onChanged: (bool? value) {
          setState(() {
            _isChecked = value ?? false;
          });
        },
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  void _submitForm(RegistrationProvider provider) {
    if (_formKey.currentState?.validate() ?? false) {
      final driver = Driver(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        city: _selectedCity ?? '',
        licenseNumber: _licenseNumberController.text,
        licenseExpiry: _licenseExpiryController.text,
        password: _passwordController.text,
        profileImage: _profileImage,
      );

      provider.updateDriver(driver);
      provider.setCurrentStep(1); // Move to next step
    }
  }
}
