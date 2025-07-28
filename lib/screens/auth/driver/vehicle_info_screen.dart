import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/models/vehicle_model.dart';
import 'package:sepesha_app/provider/registration_provider.dart';
import 'package:sepesha_app/screens/auth/driver/widgets/image_upload_widget.dart';

class VehicleInfoScreen extends StatefulWidget {
  const VehicleInfoScreen({super.key});

  @override
  State<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _licenseNumberController =
      TextEditingController();
  final TextEditingController _licenseExpiryController =
      TextEditingController();

  String? _selectedYear;
  String? _manufacturer;
  String? _model;
  String? _vehicleType;
  String? _color;
  File? _frontImage;
  File? _backImage;

  @override
  void dispose() {
    _plateNumberController.dispose();
    _licenseNumberController.dispose();
    _licenseExpiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RegistrationProvider>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter Vehicle Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                _buildDropdown(
                  label: 'Year',
                  value: _selectedYear,
                  items: List.generate(
                    25,
                    (index) => (2000 + index).toString(),
                  ),
                  onChanged: (value) => setState(() => _selectedYear = value),
                ),
                const SizedBox(height: 16),

                _buildDropdown(
                  label: 'Manufacturer',
                  value: _manufacturer,
                  items: const ['Toyota', 'Honda', 'Ford', 'BMW', 'Mercedes'],
                  onChanged: (value) => setState(() => _manufacturer = value),
                ),
                const SizedBox(height: 16),

                _buildDropdown(
                  label: 'Model',
                  value: _model,
                  items: const ['Sedan', 'SUV', 'Truck', 'Hatchback', 'Coupe'],
                  onChanged: (value) => setState(() => _model = value),
                ),
                const SizedBox(height: 16),

                _buildDropdown(
                  label: 'Color',
                  value: _color,
                  items: const ['White', 'Black', 'Red', 'Blue', 'Silver'],
                  onChanged: (value) => setState(() => _color = value),
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _plateNumberController,
                  label: 'Plate Number',
                  validator:
                      (value) =>
                          value?.isEmpty ?? true
                              ? 'Plate number is required'
                              : null,
                ),

                const SizedBox(height: 16),

                _buildDropdown(
                  label: 'Vehicle type',
                  value: _vehicleType,
                  items: const [
                    'BodaBoda',
                    'Bajaji',
                    'Guta',
                    'Carry',
                    'Townice',
                  ],
                  onChanged: (value) => setState(() => _vehicleType = value),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Driver License Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _licenseNumberController,
                  label: 'License Number',
                  validator:
                      (value) =>
                          value?.isEmpty ?? true
                              ? 'License number is required'
                              : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _licenseExpiryController,
                  label: 'License Expiry Date',
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(
                        const Duration(days: 365),
                      ),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365 * 10),
                      ),
                    );
                    if (date != null) {
                      _licenseExpiryController.text =
                          date.toString().split(' ')[0];
                    }
                  },
                  validator:
                      (value) =>
                          value?.isEmpty ?? true
                              ? 'License expiry date is required'
                              : null,
                ),
                const SizedBox(height: 24),

                const Text(
                  'Upload Vehicle Photos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please upload clear photos from all sides',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),

                Column(
                  children: [
                    _buildImageUpload(
                      label: 'Front',
                      image: _frontImage,
                      onImageSelected:
                          (file) => setState(() => _frontImage = file),
                    ),
                    _buildImageUpload(
                      label: 'Back',
                      image: _backImage,
                      onImageSelected:
                          (file) => setState(() => _backImage = file),
                    ),
                  ],
                ),

                // GridView.count(
                //   crossAxisCount: 1,
                //   shrinkWrap: true,
                //   physics: const NeverScrollableScrollPhysics(),
                //   // crossAxisSpacing: 16,
                //   // mainAxisSpacing: 16,
                //   childAspectRatio: 0.8,
                //   children: [
                //     _buildImageUpload(
                //       label: 'Front',
                //       image: _frontImage,
                //       onImageSelected:
                //           (file) => setState(() => _frontImage = file),
                //     ),
                //     _buildImageUpload(
                //       label: 'Back',
                //       image: _backImage,
                //       onImageSelected:
                //           (file) => setState(() => _backImage = file),
                //     ),
                // _buildImageUpload(
                //   label: 'Left Side',
                //   image: _leftImage,
                //   onImageSelected:
                //       (file) => setState(() => _leftImage = file),
                // ),
                // _buildImageUpload(
                //   label: 'Right Side',
                //   image: _rightImage,
                //   onImageSelected:
                //       (file) => setState(() => _rightImage = file),
                // ),
                //   ],
                // ),
                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          debugPrint('Back button pressed');
                          provider.setCurrentStep(0);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColor.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          debugPrint(
                            'Continue button pressed, validating form...',
                          );
                          if (_validateForm()) {
                            debugPrint('Form validated, submitting...');
                            _submitForm(provider);
                          } else {
                            debugPrint('Form validation failed');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please complete all required fields',
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: AppColor.primary,
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
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
    String? Function(String?)? validator,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onTap: onTap,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.primary, width: 2),
        ),
        suffixIcon: readOnly ? const Icon(Icons.calendar_today) : null,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      value: value,
      items:
          items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select $label' : null,
    );
  }

  Widget _buildImageUpload({
    required String label,
    required File? image,
    required Function(File?) onImageSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ImageUploadWidget(
          image: image,
          label: label,
          onImageSelected: onImageSelected,
        ),
        if (image == null)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Required',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  bool _validateForm() {
    return _selectedYear != null &&
        _manufacturer != null &&
        _model != null &&
        _color != null &&
        _vehicleType != null &&
        _plateNumberController.text.isNotEmpty &&
        _licenseNumberController.text.isNotEmpty &&
        _licenseExpiryController.text.isNotEmpty &&
        _frontImage != null &&
        _backImage != null;
  }

  void _submitForm(RegistrationProvider provider) {
    if (_selectedYear == null ||
        _manufacturer == null ||
        _model == null ||
        _color == null ||
        _vehicleType == null ||
        _frontImage == null ||
        _backImage == null ||
        _licenseNumberController.text.isEmpty ||
        _licenseExpiryController.text.isEmpty) {
      debugPrint('Submit attempted with null values');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    // Store license information in provider
    provider.setLicenseNumber(_licenseNumberController.text);
    provider.setLicenseExpiry(_licenseExpiryController.text);

    final vehicle = Vehicle(
      year: _selectedYear!,
      manufacturer: _manufacturer!,
      model: _model!,
      color: _color!,
      plateNumber: _plateNumberController.text,
      frontImage: _frontImage!,
      backImage: _backImage!,
    );

    debugPrint('Submitting vehicle: ${vehicle.toString()}');
    provider.updateVehicle(vehicle);
    provider.setCurrentStep(2);
  }
}
