import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:sepesha_app/Driver/dasboard/driver_dashboard.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/components/app_button.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _isChecked = false;
  File? _profileImage;
  File? _idDocumentImage;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
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
  final TextEditingController _referralCodeController = TextEditingController();

  String? _selectedCity;

  Future<void> _pickImage(bool isProfile) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isProfile) {
          _profileImage = File(image.path);
        } else {
          _idDocumentImage = File(image.path);
        }
      });
    }
  }

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
    _referralCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Let`s Get Started',
          style: AppTextStyle.paragraph4(AppColor.black),
        ),
        surfaceTintColor: AppColor.white,
        backgroundColor: AppColor.white,
      ),
      body: Container(
        color: AppColor.white,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  'Please fill in your information',
                  style: AppTextStyle.paragraph1(AppColor.black),
                ),

                // Profile Picture Section
                Column(
                  children: [
                    _buildProfilePictureContainer(_profileImage),
                    Text(
                      'Upload a Profile Picture',
                      style: AppTextStyle.paragraph1(AppColor.black),
                    ),
                  ],
                ),

                SizedBox(height: 24),

                // Name Fields
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _firstNameController,
                        label: 'First Name',
                        validator:
                            (value) =>
                                value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _lastNameController,
                        label: 'Last Name',
                        validator:
                            (value) =>
                                value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

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
                SizedBox(height: 16),

                // Phone Field
                IntlPhoneField(
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: AppTextStyle.paragraph1(AppColor.lightBlack),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColor.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColor.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColor.primary, width: 2),
                    ),
                    fillColor: AppColor.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                  ),
                  initialCountryCode: 'TZ',

                  showCountryFlag: true,
                  dropdownIcon: Icon(
                    Icons.arrow_drop_down,
                    color: AppColor.grey,
                  ),
                  style: AppTextStyle.paragraph1(AppColor.lightBlack),
                  dropdownTextStyle: AppTextStyle.paragraph1(
                    AppColor.lightBlack,
                  ),
                  pickerDialogStyle: PickerDialogStyle(
                    backgroundColor: AppColor.white,
                    searchFieldCursorColor: AppColor.primary,
                    searchFieldInputDecoration: InputDecoration(
                      // Search field styling
                      hintText: 'Search country...',
                      // border: OutlineInputBorder(
                      //   borderRadius: BorderRadius.circular(8),
                      // ),
                    ),
                  ),

                  keyboardType: TextInputType.phone,
                  languageCode: 'en',
                  onChanged: (phone) {
                    print(phone.completeNumber);
                  },
                ),
                SizedBox(height: 16),

                // City Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select City',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColor.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColor.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColor.primary, width: 2),
                    ),
                    labelStyle: TextStyle(color: AppColor.blackText),
                  ),
                  value: _selectedCity,
                  items:
                      ['Dar es Salaam', 'Arusha', 'Mwanza', 'Dodoma', 'Mbeya']
                          .map(
                            (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(color: AppColor.blackText),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value;
                    });
                  },
                  validator:
                      (value) => value == null ? 'Please select a city' : null,
                ),
                SizedBox(height: 16),

                // License Fields
                _buildTextField(
                  controller: _licenseNumberController,
                  label: 'License Number',
                  validator:
                      (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                SizedBox(height: 16),

                _buildTextField(
                  controller: _licenseExpiryController,
                  label: 'License Expiry Date (YYYY-MM-DD)',
                  validator:
                      (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),

                SizedBox(height: 16),

                // // ID Document Upload
                // _buildImageUploadSection(
                //   image: _idDocumentImage,
                //   label: 'National ID or Driving License',
                //   isProfile: false,
                // ),
                // SizedBox(height: 16),

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
                SizedBox(height: 16),

                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Referral Code
                _buildTextField(
                  controller: _referralCodeController,
                  label: 'Referral Code (if any)',
                ),
                SizedBox(height: 16),

                // Terms Checkbox
                Container(
                  decoration: BoxDecoration(
                    color: AppColor.lightred.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(12),
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: AppColor.blackText,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: TextStyle(
                              color: AppColor.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text:
                                '. All information provided is true and Snap or its representatives may contact me via any of the provided channels.',
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
                ),
                SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed:
                      _isChecked
                          ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VehicleDetails(),
                              ),
                            );
                            if (_formKey.currentState?.validate() ?? false) {
                              // Submit form
                            }
                          }
                          : null,
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      color: AppColor.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? prefix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,

        prefix: prefix,
        labelStyle: TextStyle(color: AppColor.blackText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.primary, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,

      style: TextStyle(color: AppColor.blackText),
    );
  }

  Widget _buildImageUploadSection({
    required File? image,
    required String label,
    required bool isProfile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColor.blackText,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickImage(isProfile),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                image == null
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload,
                            size: 40,
                            color: AppColor.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap to upload',
                            style: TextStyle(color: AppColor.grey),
                          ),
                        ],
                      ),
                    )
                    : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          isProfile
                              ? CircleAvatar(
                                radius: 60,
                                backgroundImage: FileImage(image),
                              )
                              : Image.file(image, fit: BoxFit.cover),
                    ),
          ),
        ),
        if (image != null) ...[
          SizedBox(height: 8),
          TextButton(
            onPressed: () => _pickImage(isProfile),
            child: Text(
              'Change ${isProfile ? 'Profile' : 'Document'}',
              style: TextStyle(color: AppColor.primary),
            ),
          ),
        ],
      ],
    );
  }
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  VoidCallback? onTap,
  TextInputType? keyboardType,
  bool obscureText = false,
  Widget? prefix,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,

      prefix: prefix,
      labelStyle: TextStyle(color: AppColor.blackText),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColor.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColor.primary, width: 2),
      ),
    ),
    keyboardType: keyboardType,
    obscureText: obscureText,
    validator: validator,
    onTap: onTap,
    style: TextStyle(color: AppColor.blackText),
  );
}

Widget _buildProfilePictureContainer(File? image) {
  return Container(
    padding: EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColor.white2.withAlpha(128),
      borderRadius: BorderRadius.circular(1000),
      border: Border.all(color: AppColor.white2, width: 1),
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1000),
        border: Border.all(color: AppColor.lightBlack, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child:
          image == null
              ? HugeIcon(
                icon: HugeIcons.strokeRoundedUser02,
                color: AppColor.lightBlack,
                size: 70,
              )
              : ClipRRect(
                borderRadius: BorderRadius.circular(1000),
                child: Image.file(
                  image,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
    ),
  );
}

class VehicleDetails extends StatefulWidget {
  const VehicleDetails({super.key});

  @override
  State<VehicleDetails> createState() => _VehicleDetailsState();
}

class _VehicleDetailsState extends State<VehicleDetails> {
  String? _selectedYear;
  String? _manufactured;
  String? _model;
  String? _color;
  final TextEditingController _plateNumberController = TextEditingController();

  // Image states
  File? _frontImage;
  File? _leftImage;
  File? _rightImage;
  File? _backImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _plateNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, String position) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          switch (position) {
            case 'front':
              _frontImage = File(image.path);
              break;
            case 'left':
              _leftImage = File(image.path);
              break;
            case 'right':
              _rightImage = File(image.path);
              break;
            case 'back':
              _backImage = File(image.path);
              break;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
      );
    }
  }

  Widget _buildImageUploadBox(String position, File? image) {
    return GestureDetector(
      onTap: () => _showImageSourceDialog(position),
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            image != null
                ? Image.file(image, fit: BoxFit.cover)
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 40, color: AppColor.grey),
                    Text(position.toUpperCase()),
                  ],
                ),
      ),
    );
  }

  void _showImageSourceDialog(String position) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Upload $position image'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, position);
                },
                child: Text('Camera'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, position);
                },
                child: Text('Gallery'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Details'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle details section
            Text(
              'Vehicle Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            _buildDropdownList(
              value: _selectedYear,
              label: 'Select Year',
              items: List.generate(25, (index) => (2000 + index).toString()),
              onChanged: (value) => setState(() => _selectedYear = value),
            ),

            _buildDropdownList(
              value: _manufactured,
              label: 'Manufactured',
              items: const ['China', 'USA', 'Canada', 'Japan', 'Germany'],
              onChanged: (value) => setState(() => _manufactured = value),
            ),

            _buildDropdownList(
              value: _model,
              label: 'Model',
              items: const ['Sedan', 'SUV', 'Truck', 'Hatchback', 'Coupe'],
              onChanged: (value) => setState(() => _model = value),
            ),

            _buildDropdownList(
              value: _color,
              label: 'Color',
              items: const ['White', 'Black', 'Red', 'Blue', 'Silver'],
              onChanged: (value) => setState(() => _color = value),
            ),

            SizedBox(height: 16),

            _buildTextField(
              controller: _plateNumberController,
              label: 'Plate Number',
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),

            // Image upload section
            SizedBox(height: 24),
            Text(
              'Vehicle Photos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Please upload clear photos from all sides',
              style: TextStyle(color: AppColor.grey),
            ),
            SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    _buildImageUploadBox('front', _frontImage),
                    SizedBox(height: 8),
                    Text('Front'),
                  ],
                ),
                Column(
                  children: [
                    _buildImageUploadBox('back', _backImage),
                    SizedBox(height: 8),
                    Text('Back'),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    _buildImageUploadBox('left', _leftImage),
                    SizedBox(height: 8),
                    Text('Left Side'),
                  ],
                ),
                Column(
                  children: [
                    _buildImageUploadBox('right', _rightImage),
                    SizedBox(height: 8),
                    Text('Right Side'),
                  ],
                ),
              ],
            ),

            // Submit button
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Validate and submit form
                  if (_validateForm()) {
                    _submitForm();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Submit Vehicle Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateForm() {
    // Add your validation logic here
    return true;
  }

  void _submitForm() {
    // Handle form submission
    print('Vehicle details submitted');
    print('Year: $_selectedYear');
    print('Manufactured: $_manufactured');
    print('Model: $_model');
    print('Color: $_color');
    print('Plate: ${_plateNumberController.text}');
    // You would typically upload images to a server here
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => IdentityDocumentsScreen()),
    );
  }

  Widget _buildDropdownList({
    required List<String> items,
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColor.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColor.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColor.primary, width: 2),
          ),
          labelStyle: TextStyle(color: AppColor.blackText),
        ),
        value: value,
        items:
            items.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select $label' : null,
      ),
    );
  }
}

class IdentityDocumentsScreen extends StatefulWidget {
  const IdentityDocumentsScreen({super.key});

  @override
  State<IdentityDocumentsScreen> createState() =>
      _IdentityDocumentsScreenState();
}

class _IdentityDocumentsScreenState extends State<IdentityDocumentsScreen> {
  final Map<String, DocumentData> _documents = {
    'driving_license': DocumentData(
      requiresIdNumber: true,
      requiresExpiryDate: true,
    ),
    'latra_sticker': DocumentData(requiresExpiryDate: true),
    'vehicle_registration': DocumentData(requiresIdNumber: true),
    'plate_number': DocumentData(),
  };

  final Map<String, bool> _completedDocuments = {
    'driving_license': false,
    'latra_sticker': false,
    'vehicle_registration': false,
    'plate_number': false,
  };

  @override
  void dispose() {
    for (var document in _documents.values) {
      document.idNumberController?.dispose();
      document.expireDateController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Documents'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildDocumentList(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentList() {
    return Column(
      children:
          _documents.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildDocumentCard(
                title: _getDocumentTitle(entry.key),
                documentKey: entry.key,
                isCompleted: _completedDocuments[entry.key]!,
              ),
            );
          }).toList(),
    );
  }

  String _getDocumentTitle(String key) {
    switch (key) {
      case 'driving_license':
        return 'Driving License';
      case 'latra_sticker':
        return 'LATRA Sticker';
      case 'vehicle_registration':
        return 'Vehicle Registration';
      case 'plate_number':
        return 'Plate Number';
      default:
        return 'Document';
    }
  }

  Widget _buildDocumentCard({
    required String title,
    required String documentKey,
    required bool isCompleted,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCompleted ? AppColor.primary : AppColor.grey,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openDocumentForm(documentKey),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: isCompleted ? AppColor.primary : AppColor.grey,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isCompleted ? Colors.black : AppColor.grey,
                  ),
                ),
              ),
              if (isCompleted)
                Icon(
                  Icons.check_circle,
                  color: AppColor.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final allCompleted = _completedDocuments.values.every((status) => status);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: allCompleted ? AppColor.primary : AppColor.grey,
        ),
        onPressed: allCompleted ? _submitAllDocuments : null,
        child: const Text(
          'SUBMIT DOCUMENTS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _openDocumentForm(String documentKey) {
    final document = _documents[documentKey]!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  _buildFormTitle(_getDocumentTitle(documentKey)),
                  const SizedBox(height: 20),
                  if (document.requiresIdNumber) ...[
                    _buildTextField(
                      controller: document.idNumberController!,
                      label: 'ID Number',
                      hint: 'Enter document ID number',
                      icon: Icons.numbers,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (document.requiresExpiryDate) ...[
                    _buildDateField(
                      controller: document.expireDateController!,
                      label: 'Expiry Date',
                      setModalState: setModalState,
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildUploadSection(document, setModalState),
                  const SizedBox(height: 24),
                  _buildFormSubmitButton(documentKey, document),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFormTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,

        labelStyle: TextStyle(color: AppColor.blackText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required StateSetter setModalState,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,

        // prefix: prefix,
        labelStyle: TextStyle(color: AppColor.blackText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.primary, width: 2),
        ),
      ),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          controller.text = "${picked.day}/${picked.month}/${picked.year}";
          setModalState(() {});
        }
      },
    );
  }

  Widget _buildUploadSection(DocumentData document, StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Document',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showUploadOptions(document, setModalState),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: document.file != null ? AppColor.primary : AppColor.grey,
                width: 1.5,
              ),
            ),
            child: Center(
              child:
                  document.file != null
                      ? _buildFilePreview(document)
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload,
                            size: 40,
                            color: AppColor.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to upload document',
                            style: TextStyle(color: AppColor.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '(JPG, PNG or PDF)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColor.grey,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ),
        if (document.file != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${(document.file!.lengthSync() / 1024).toStringAsFixed(1)} KB',
                style: TextStyle(color: AppColor.grey),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed:
                    () => setModalState(() {
                      document.file = null;
                      document.fileType = null;
                    }),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFilePreview(DocumentData document) {
    if (document.fileType == 'pdf') {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf, size: 50, color: Colors.red),
          SizedBox(height: 8),
          Text('PDF Document', style: TextStyle(fontSize: 14)),
        ],
      );
    } else {
      return Image.file(document.file!, height: 140, fit: BoxFit.cover);
    }
  }

  Future<void> _showUploadOptions(
    DocumentData document,
    StateSetter setModalState,
  ) async {
    await showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    final file = await _pickImage();
                    if (file != null) {
                      setModalState(() {
                        document.file = file;
                        document.fileType = 'image';
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a Photo'),
                  onTap: () async {
                    Navigator.pop(context);
                    final file = await _takePhoto();
                    if (file != null) {
                      setModalState(() {
                        document.file = file;
                        document.fileType = 'image';
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: const Text('Upload PDF'),
                  onTap: () async {
                    Navigator.pop(context);
                    final file = await _pickPDF();
                    if (file != null) {
                      setModalState(() {
                        document.file = file;
                        document.fileType = 'pdf';
                      });
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildFormSubmitButton(String documentKey, DocumentData document) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor:
              _isDocumentComplete(document) ? AppColor.primary : AppColor.grey,
        ),
        onPressed:
            _isDocumentComplete(document)
                ? () {
                  setState(() {
                    _completedDocuments[documentKey] = true;
                  });
                  Navigator.pop(context);
                }
                : null,
        child: const Text(
          'SAVE DOCUMENT',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  bool _isDocumentComplete(DocumentData document) {
    if (document.file == null) return false;
    if (document.requiresIdNumber &&
        (document.idNumberController?.text.isEmpty ?? true)) {
      return false;
    }
    if (document.requiresExpiryDate &&
        (document.expireDateController?.text.isEmpty ?? true)) {
      return false;
    }
    return true;
  }

  Future<File?> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<File?> _takePhoto() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<File?> _pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    return result != null && result.files.single.path != null
        ? File(result.files.single.path!)
        : null;
  }

  void _submitAllDocuments() {
    final payload = {
      'documents': {
        for (var entry in _documents.entries)
          entry.key: {
            if (entry.value.requiresIdNumber)
              'id_number': entry.value.idNumberController?.text,
            if (entry.value.requiresExpiryDate)
              'expire_date': entry.value.expireDateController?.text,
            'file_name': entry.value.file?.path.split('/').last,
            'file_type': entry.value.fileType,
            'file_size': '${(entry.value.file?.lengthSync() ?? 0) / 1024} KB',
          },
      },
      'submission_date': DateTime.now().toIso8601String(),
    };

    debugPrint('Submitting all documents: $payload');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Documents submitted successfully!'),
        backgroundColor: AppColor.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class DocumentData {
  final bool requiresIdNumber;
  final bool requiresExpiryDate;
  final TextEditingController? idNumberController;
  final TextEditingController? expireDateController;
  File? file;
  String? fileType;

  DocumentData({this.requiresIdNumber = false, this.requiresExpiryDate = false})
    : idNumberController = requiresIdNumber ? TextEditingController() : null,
      expireDateController =
          requiresExpiryDate ? TextEditingController() : null;
}
