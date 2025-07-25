import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/models/vehicle_model.dart';
import 'package:sepesha_app/provider/registration_provider.dart';
import 'package:sepesha_app/screens/auth/driver/widgets/document_card_widget.dart';
import 'package:sepesha_app/services/session_manager.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final _licenseNumberController = TextEditingController();
  final _licenseExpiryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<RegistrationProvider>(context, listen: false);
    _licenseNumberController.text = provider.licenseNumber;
    _licenseExpiryController.text = provider.licenseExpiry;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RegistrationProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Upload Documents'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Please upload all required documents',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  DocumentCardWidget(
                    title: 'Driving License',
                    documentKey: 'driving_license',
                    requiresIdNumber: true,
                    requiresExpiryDate: true,
                  ),

                  // License Number Field
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _licenseNumberController,
                    decoration: InputDecoration(
                      labelText: 'License Number *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.credit_card),
                    ),
                    validator:
                        (value) =>
                            value?.isEmpty ?? true
                                ? 'License number is required'
                                : null,
                    onChanged: (value) {
                      provider.setLicenseNumber(value);
                    },
                  ),

                  // License Expiry Date Field
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _licenseExpiryController,
                    decoration: InputDecoration(
                      labelText: 'License Expiry Date *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.calendar_today),
                      hintText: 'YYYY-MM-DD',
                    ),
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
                        final formattedDate = date.toString().split(' ')[0];
                        _licenseExpiryController.text = formattedDate;
                        provider.setLicenseExpiry(formattedDate);
                      }
                    },
                    validator:
                        (value) =>
                            value?.isEmpty ?? true
                                ? 'License expiry date is required'
                                : null,
                  ),

                  const SizedBox(height: 12),
                  DocumentCardWidget(
                    title: 'LATRA Sticker',
                    documentKey: 'latra_sticker',
                    requiresExpiryDate: true,
                  ),
                  const SizedBox(height: 12),
                  DocumentCardWidget(
                    title: 'Vehicle Registration',
                    documentKey: 'vehicle_registration',
                    requiresIdNumber: true,
                  ),
                  const SizedBox(height: 12),
                  DocumentCardWidget(
                    title: 'Plate Number',
                    documentKey: 'plate_number',
                  ),
                  const SizedBox(height: 12),
                  DocumentCardWidget(
                    title: 'Insurance Certificate',
                    documentKey: 'insurance_certificate',
                    requiresExpiryDate: true,
                  ),
                  const SizedBox(height: 12),
                  DocumentCardWidget(
                    title: 'National ID',
                    documentKey: 'national_id',
                    requiresIdNumber: true,
                  ),
                  const SizedBox(height: 32),
                  ContinueButton(
                    onPressed: () => _submitDocuments(provider, context),
                    isLoading: provider.isLoading,
                    text: 'Complete Registration',
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> _submitDocuments(
    RegistrationProvider provider,
    BuildContext context,
  ) async {
    // Validate the form first
    final formKey =
        context.findAncestorStateOfType<_DocumentUploadScreenState>()?._formKey;
    if (formKey?.currentState?.validate() != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    try {
      provider.completeRegistration();

      final driver = SessionManager.instance.user;
      final vehicle = SessionManager.instance.vehicle;
      final documents = SessionManager.instance.completedDocuments;

      for (var document in documents) {
        print("My documents are ${document.toJson()} ");
      }

      if (vehicle == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle information is missing')),
        );
        return;
      }
      await provider.registerDriver(driver!, vehicle, documents, context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  void dispose() {
    _licenseNumberController.dispose();
    _licenseExpiryController.dispose();
    super.dispose();
  }
}
