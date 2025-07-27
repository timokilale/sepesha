import 'dart:io';
import 'package:sepesha_app/screens/auth/widgets/circular_profile_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/models/vehicle_model.dart';
import 'package:sepesha_app/models/driver_document_model.dart';
import 'package:sepesha_app/models/user_data.dart';
import 'package:sepesha_app/provider/registration_provider.dart';
import 'package:sepesha_app/screens/auth/driver/widgets/image_upload_widget.dart';
import 'package:sepesha_app/Utilities/app_color.dart';

class UnifiedRegistrationScreen extends StatefulWidget {
  final String? userType;
  const UnifiedRegistrationScreen({super.key, this.userType});

  @override
  State<UnifiedRegistrationScreen> createState() =>
      _UnifiedRegistrationScreenState();
}

class _UnifiedRegistrationScreenState extends State<UnifiedRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Step management for drivers
  int _currentStep = 0;
  int get _totalSteps => _selectedUserType == 'driver' ? 3 : 1;

  Map<String, File?> _driverDocuments = {
    'driving_license': null,
    'vehicle_registration': null,
    'insurance_certificate': null,
    'national_id': null,
  };

  Map<String, String> _documentLabels = {
    'driving_license': 'Driving License *',
    'vehicle_registration': 'Vehicle Registration *',
    'insurance_certificate': 'Insurance Certificate *',
    'national_id': 'National ID *',
  };

  // Common fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _referralCodeController = TextEditingController();

  // Role-specific fields
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessAddressController =
      TextEditingController();
  final TextEditingController _businessDescriptionController =
      TextEditingController();
  final TextEditingController _licenseNumberController =
      TextEditingController();
  final TextEditingController _licenseExpiryController =
      TextEditingController();
  final TextEditingController _vehicleMakeController = TextEditingController();
  final TextEditingController _vehicleModelController = TextEditingController();
  final TextEditingController _vehicleYearController = TextEditingController();
  final TextEditingController _plateNumberController = TextEditingController();

  // Vehicle dropdown selections
  String? _selectedYear;
  String? _manufacturer;
  String? _model;
  String? _vehicleType;
  String? _color;

  // Vehicle images
  File? _frontImage;
  File? _backImage;

  String? _selectedRegion;
  String? _selectedUserType = 'customer';
  File? _profileImage;
  bool _privacyChecked = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    // Dispose all controllers
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralCodeController.dispose();
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _businessDescriptionController.dispose();
    _licenseNumberController.dispose();
    _licenseExpiryController.dispose();
    _vehicleMakeController.dispose();
    _vehicleModelController.dispose();
    _vehicleYearController.dispose();
    _plateNumberController.dispose();
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

    setState(() {
      _selectedUserType = widget.userType ?? 'customer';
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<RegistrationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedUserType == 'driver'
              ? 'Driver Registration'
              : 'Create Account',
        ),
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
                _selectedUserType == 'driver'
                    ? 'Join as Driver'
                    : 'Join Sepesha',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedUserType == 'driver'
                    ? 'Complete the registration process in ${_totalSteps} steps'
                    : 'Please provide your details to create your account',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Driver Step Indicator
              if (_selectedUserType == 'driver') ...[
                _buildStepIndicator(),
                const SizedBox(height: 24),
              ],

              // Content based on user type and step
              if (_selectedUserType == 'driver')
                _buildDriverStepContent()
              else
                _buildSingleStepContent(),

              const SizedBox(height: 24),

              // Navigation Buttons
              _buildNavigationButtons(provider),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          for (int i = 0; i < _totalSteps; i++) ...[
            _buildStepCircle(i + 1, i <= _currentStep),
            if (i < _totalSteps - 1) _buildStepConnector(i < _currentStep),
          ],
        ],
      ),
    );
  }

  Widget _buildStepCircle(int stepNumber, bool isActive) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColor.primary : Colors.grey.shade300,
      ),
      child: Center(
        child: Text(
          stepNumber.toString(),
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppColor.primary : Colors.grey.shade300,
        margin: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildDriverStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1PersonalInfo();
      case 1:
        return _buildStep2VehicleInfo();
      case 2:
        return _buildStep3Documents();
      default:
        return _buildStep1PersonalInfo();
    }
  }

  Widget _buildStep1PersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 1: Personal Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColor.primary,
          ),
        ),
        const SizedBox(height: 16),

        // Profile Picture Section
        Center(
          child: Column(
            children: [
              CircularProfilePicker(
                image: _profileImage,
                onImageSelected: (file) {
                  setState(() {
                    _profileImage = file;
                  });
                },
                size: 120,
              ),
              const SizedBox(height: 8),
              Text(
                'Upload Profile Picture',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Common Fields
        _buildCommonFields(),
      ],
    );
  }

  Widget _buildStep2VehicleInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 2: Vehicle Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColor.primary,
          ),
        ),
        const SizedBox(height: 16),

        // Vehicle Details
        _buildVehicleDropdown(
          label: 'Year *',
          value: _selectedYear,
          items: List.generate(25, (index) => (2000 + index).toString()),
          onChanged: (value) => setState(() => _selectedYear = value),
        ),
        const SizedBox(height: 16),

        _buildVehicleDropdown(
          label: 'Manufacturer *',
          value: _manufacturer,
          items: const [
            'Bajaj Auto',
            'TVS Motor',
            'Piaggio',
            'Mahindra Electric',
            'King',
            'Dayun',
            'Shineray',
            'Zongshen',
            'Suzuki',
            'Daihatsu',
            'Mitsubishi',
            'Honda',
            'Toyota',
            'Hero MotoCorp',
            'Yamaha',
            'Haojue',
            'Sunday',
            'Kinglion',
            'Skygo',
            'Rato',
            'Jialing',
            'Loncin',
            'Sanya',
            'T-Bird',
            'Haowei',
            'Foton',
            'Changan',
          ],

          onChanged: (value) => setState(() => _manufacturer = value),
        ),
        const SizedBox(height: 16),

        _buildVehicleDropdown(
          label: 'Model *',
          value: _model,
          items: const [
            'RE Compact',
            'RE Maxima',
            'Maxima C',
            'Maxima Z',
            'TVS King Deluxe',
            'TVS King Duramax',
            'TVS XL100 Heavy Duty',
            'TVS King Cargo',
            'Ape City',
            'Ape Xtra',
            'e-Alfa Mini',
            'Treo Auto',
            'King Cargo Tricycle 200cc',
            'King Passenger Tricycle',
            'Dayun DY200ZH',
            'Dayun DY150ZH',
            'Shineray SR200ZH',
            'Zongshen ZS200ZH',
            'Zongshen Cargo King',
            'Suzuki Carry',
            'Suzuki Super Carry',
            'Hijet Cargo',
            'Hijet Truck',
            'Minicab',
            'L300',
            'Acty Truck',
            'Acty Van',
            'TownAce Noah',
            'LiteAce Van',
            'TownAce Truck',
            'LiteAce Truck',
            'Boxer 100',
            'Boxer X125',
            'CT100',
            'TVS HLX 100',
            'TVS HLX 125',
            'TVS Star HLX',
            'Hero Dawn 125',
            'Hero Hunter 100',
            'Yamaha Crux',
            'Yamaha YBR 125',
            'Honda Ace 125',
            'Honda CD 70',
            'Honda CB Shine',
            'Suzuki GN125',
            'Suzuki AX4',
            'Haojue HJ125',
            'Haojue KA150',
            'Zongshen ZS125',
            'Zongshen ZS150',
            'Sunday 150cc',
            'Sunday Boxer',
            'Kinglion 150cc Cargo',
            'Skygo SG150',
            'Rato RT150ZH',
            'Jialing JL150',
            'Loncin LX150',
            'Sanya SY125',
            'T-Bird TB200ZH',
            'Haowei HW150ZH',
            'Foton Mini Truck',
            'Changan Star Truck',
          ],
          onChanged: (value) => setState(() => _model = value),
        ),
        const SizedBox(height: 16),

        _buildVehicleDropdown(
          label: 'Color *',
          value: _color,
          items: const ['White', 'Black', 'Red', 'Blue', 'Silver', 'Gray'],
          onChanged: (value) => setState(() => _color = value),
        ),
        const SizedBox(height: 16),

        _buildTextField(
          controller: _plateNumberController,
          label: 'Plate Number *',
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),

        _buildVehicleDropdown(
          label: 'Vehicle Type *',
          value: _vehicleType,
          items: const ['BodaBoda', 'Bajaji', 'Guta', 'Carry', 'Townice'],
          onChanged: (value) => setState(() => _vehicleType = value),
        ),
        const SizedBox(height: 24),

        // License Information
        Text(
          'Driver License Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColor.primary,
          ),
        ),
        const SizedBox(height: 16),

        _buildTextField(
          controller: _licenseNumberController,
          label: 'License Number *',
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),

        _buildTextField(
          controller: _licenseExpiryController,
          label: 'License Expiry Date *',
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 365)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
            );
            if (date != null) {
              _licenseExpiryController.text = date.toString().split(' ')[0];
            }
          },
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 24),

        // Vehicle Photos
        Text(
          'Upload Vehicle Photos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColor.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please upload clear photos from front and back',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),

        _buildVehicleImageUpload(
          label: 'Front Photo *',
          image: _frontImage,
          onImageSelected: (file) => setState(() => _frontImage = file),
        ),
        const SizedBox(height: 16),

        _buildVehicleImageUpload(
          label: 'Back Photo *',
          image: _backImage,
          onImageSelected: (file) => setState(() => _backImage = file),
        ),
      ],
    );
  }

  Widget _buildStep3Documents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 3: Document Upload',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColor.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please upload clear photos or scanned copies of the following documents',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),

        ..._documentLabels.entries.map(
          (entry) => _buildDocumentUpload(entry.key, entry.value),
        ),

        const SizedBox(height: 24),
        // Privacy Checkbox for final step
        _buildPrivacyCheckbox(),
      ],
    );
  }

  Widget _buildVehicleDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      value: value,
      items:
          items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
      onChanged: onChanged,
      validator:
          (value) =>
              value == null
                  ? 'Please select ${label.replaceAll('*', '').trim()}'
                  : null,
    );
  }

  Widget _buildVehicleImageUpload({
    required String label,
    required File? image,
    required Function(File?) onImageSelected,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: image != null ? Colors.green : Colors.grey.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        color: image != null ? Colors.green.shade50 : Colors.grey.shade50,
      ),
      child: ListTile(
        leading: Icon(
          image != null ? Icons.check_circle : Icons.camera_alt,
          color: image != null ? Colors.green : Colors.grey,
          size: 32,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: image != null ? Colors.green.shade700 : Colors.black87,
          ),
        ),
        subtitle: Text(
          image != null ? 'Photo uploaded' : 'Tap to upload photo',
          style: TextStyle(
            color: image != null ? Colors.green.shade600 : Colors.grey[600],
          ),
        ),
        trailing:
            image != null
                ? IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () => onImageSelected(null),
                )
                : Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: () => _pickVehicleImage(onImageSelected),
      ),
    );
  }

  Future<void> _pickVehicleImage(Function(File?) onImageSelected) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        onImageSelected(File(result.files.single.path!));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Photo uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleStepNavigation(RegistrationProvider provider) {
    if (_currentStep == _totalSteps - 1) {
      // Final step - submit form
      if (_privacyChecked) {
        _submitForm(provider);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please accept the Terms & Conditions and Privacy Policy',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Validate current step before proceeding
      if (_validateCurrentStep()) {
        setState(() {
          _currentStep++;
        });
      }
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Personal Info
        return _formKey.currentState?.validate() ?? false;
      case 1: // Vehicle Info
        return _validateVehicleInfo();
      case 2: // Documents
        return _validateDocuments();
      default:
        return false;
    }
  }

  bool _validateVehicleInfo() {
    if (_selectedYear == null ||
        _manufacturer == null ||
        _model == null ||
        _color == null ||
        _vehicleType == null ||
        _plateNumberController.text.isEmpty ||
        _licenseNumberController.text.isEmpty ||
        _licenseExpiryController.text.isEmpty ||
        _frontImage == null ||
        _backImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please complete all vehicle information fields'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  bool _validateDocuments() {
    final missingDocs =
        _driverDocuments.entries
            .where((entry) => entry.value == null)
            .map((entry) => _documentLabels[entry.key])
            .toList();

    if (missingDocs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please upload: ${missingDocs.join(', ')}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return false;
    }
    return true;
  }

  Widget _buildNavigationButtons(RegistrationProvider provider) {
    if (_selectedUserType != 'driver') {
      // Single step registration for customer/vendor
      return SizedBox(
        width: double.infinity,
        child: ContinueButton(
          onPressed: _privacyChecked ? () => _submitForm(provider) : () {},
          text: 'Create Account',
          isLoading: false,
        ),
      );
    }

    // Multi-step navigation for drivers
    return Row(
      children: [
        if (_currentStep > 0) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _currentStep--;
                });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: AppColor.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Back',
                style: TextStyle(fontSize: 16, color: AppColor.primary),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: ContinueButton(
            onPressed: () => _handleStepNavigation(provider),
            text:
                _currentStep == _totalSteps - 1 ? 'Create Account' : 'Continue',
            isLoading: false,
          ),
        ),
      ],
    );
  }

  Widget _buildSingleStepContent() {
    return Column(
      children: [
        // Profile Picture Section
        Center(
          child: Column(
            children: [
              CircularProfilePicker(
                image: _profileImage,
                onImageSelected: (file) {
                  setState(() {
                    _profileImage = file;
                  });
                },
                size: 120,
              ),
              const SizedBox(height: 8),
              Text(
                'Upload Profile Picture',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Common Fields
        _buildCommonFields(),

        // Role-specific fields
        if (_selectedUserType == 'vendor') ...[
          const SizedBox(height: 24),
          _buildVendorFields(),
        ],

        const SizedBox(height: 24),
        // Privacy Checkbox
        _buildPrivacyCheckbox(),
      ],
    );
  }

  Widget _buildCommonFields() {
    return Column(
      children: [
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
      ],
    );
  }

  Widget _buildVendorFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Business Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColor.primary,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _businessNameController,
          label: 'Business Name *',
          prefixIcon: Icons.business,
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _businessAddressController,
          label: 'Business Address *',
          prefixIcon: Icons.location_on,
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _businessDescriptionController,
          label: 'Business Description *',
          prefixIcon: Icons.description,
          maxLines: 3,
          validator:
              (value) =>
                  value?.isEmpty ?? true
                      ? 'Business description is required'
                      : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _licenseNumberController,
          label: 'Business License Number *',
          prefixIcon: Icons.assignment,
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
      ],
    );
  }

  // Keep all the existing helper methods from user_info_registration.dart
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool obscureText = false,
    IconData? prefixIcon,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    bool readOnly = false,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines ?? 1,
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
        suffixIcon: readOnly ? const Icon(Icons.calendar_today) : null,
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onTap: onTap,
      readOnly: readOnly,
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
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = () {},
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
      // Additional validation for driver documents
      if (_selectedUserType == 'driver') {
        final missingDocs =
            _driverDocuments.entries
                .where((entry) => entry.value == null)
                .map((entry) => _documentLabels[entry.key])
                .toList();

        if (missingDocs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please upload: ${missingDocs.join(', ')}'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
          return;
        }
      }

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
        userType: _selectedUserType ?? 'customer',
        // Add vendor-specific fields
        businessName:
            _selectedUserType == 'vendor' ? _businessNameController.text : null,
        businessDescription:
            _selectedUserType == 'vendor'
                ? _businessDescriptionController.text
                : null,
      );

      if (_selectedUserType == 'driver') {
        // Handle driver registration with documents
        _handleDriverRegistration(provider, user);
      } else if (_selectedUserType == 'vendor') {
        // Handle vendor registration with business details
        provider.updateVendor(user, context);
      } else {
        // Handle customer registration
        provider.updateUser(user, context);
      }
    }
  }

  void _handleDriverRegistration(RegistrationProvider provider, UserData user) {
    // Store license information in provider first
    provider.setLicenseNumber(_licenseNumberController.text);
    provider.setLicenseExpiry(_licenseExpiryController.text);

    // Create vehicle object using the dropdown values
    final vehicle = Vehicle(
      year: _selectedYear ?? '',
      manufacturer: _manufacturer ?? '',
      model: _model ?? '',
      color: _color ?? '',
      plateNumber: _plateNumberController.text,
      frontImage: _frontImage,
      backImage: _backImage,
    );

    // Create document models
    final documents =
        _driverDocuments.entries
            .where((entry) => entry.value != null)
            .map(
              (entry) =>
                  DriverDocumentModel(key: entry.key, document: entry.value!),
            )
            .toList();

    // Call the driver registration method
    provider.registerDriver(user, vehicle, documents, context);
  }

  Widget _buildDocumentUpload(String documentKey, String label) {
    final file = _driverDocuments[documentKey];
    final isUploaded = file != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isUploaded ? Colors.green : Colors.grey.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isUploaded ? Colors.green.shade50 : Colors.grey.shade50,
      ),
      child: ListTile(
        leading: Icon(
          isUploaded ? Icons.check_circle : Icons.upload_file,
          color: isUploaded ? Colors.green : Colors.grey,
          size: 32,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isUploaded ? Colors.green.shade700 : Colors.black87,
          ),
        ),
        subtitle: Text(
          isUploaded ? 'Document uploaded' : 'Tap to upload document',
          style: TextStyle(
            color: isUploaded ? Colors.green.shade600 : Colors.grey[600],
          ),
        ),
        trailing:
            isUploaded
                ? IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _driverDocuments[documentKey] = null;
                    });
                  },
                )
                : Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: () => _pickDocument(documentKey),
      ),
    );
  }

  Future<void> _pickDocument(String documentKey) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _driverDocuments[documentKey] = File(result.files.single.path!);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${_documentLabels[documentKey]} uploaded successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
