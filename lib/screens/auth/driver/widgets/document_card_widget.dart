import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sepesha_app/Driver/dasboard/driver_dashboard.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/provider/registration_provider.dart';
import 'package:sepesha_app/screens/auth/driver/widgets/image_upload_widget.dart';

class DocumentCardWidget extends StatefulWidget {
  final String title;
  final String documentKey;
  final bool requiresIdNumber;
  final bool requiresExpiryDate;

  const DocumentCardWidget({
    super.key,
    required this.title,
    required this.documentKey,
    this.requiresIdNumber = false,
    this.requiresExpiryDate = false,
  });

  @override
  State<DocumentCardWidget> createState() => _DocumentCardWidgetState();
}

class _DocumentCardWidgetState extends State<DocumentCardWidget> {
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _expireDateController = TextEditingController();
  File? _selectedFile;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _idNumberController.dispose();
    _expireDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RegistrationProvider>(context);
    final isCompleted = provider.isDocumentComplete(widget.documentKey);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCompleted ? Colors.blue : Colors.grey,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _showDocumentForm,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: isCompleted ? Colors.blue : Colors.grey,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isCompleted ? Colors.black : Colors.grey,
                  ),
                ),
              ),
              if (isCompleted)
                const Icon(Icons.check_circle, color: Colors.blue, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showDocumentForm() {
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
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (widget.requiresIdNumber) ...[
                      TextFormField(
                        controller: _idNumberController,
                        decoration: const InputDecoration(
                          labelText: 'ID Number',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter ID number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (widget.requiresExpiryDate) ...[
                      TextFormField(
                        controller: _expireDateController,
                        decoration: const InputDecoration(
                          labelText: 'Expiry Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select expiry date';
                          }
                          return null;
                        },
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setModalState(() {
                              _expireDateController.text = DateFormat(
                                'dd/MM/yyyy',
                              ).format(picked);
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    ImageUploadWidget(
                      image: _selectedFile,
                      label: 'Upload ${widget.title}',
                      onImageSelected: (file) {
                        setModalState(() {
                          _selectedFile = file;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    ContinueButton(
                      onPressed: () {
                        if (_validateForm()) {
                          _completeDocument(context);
                        }
                      },
                      isLoading: false,
                      text: 'Save Document',
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool _validateForm() {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload document file')),
      );
      return false;
    }
    return _formKey.currentState?.validate() ?? false;
  }

  void _completeDocument(BuildContext context) {
    try {
      final provider = Provider.of<RegistrationProvider>(
        context,
        listen: false,
      );
      provider.markDocumentComplete(
        widget.documentKey,
        file: _selectedFile,
        idNumber: widget.requiresIdNumber ? _idNumberController.text : null,
        expiryDate:
            widget.requiresExpiryDate ? _expireDateController.text : null,
      );
      Navigator.pop(context);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.title} saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save document: $e')));
    }
  }
}

class DocumentUploadScreen extends StatelessWidget {
  const DocumentUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RegistrationProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Documents')),
      body: SingleChildScrollView(
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
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ContinueButton(
                    onPressed: () => provider.setCurrentStep(1),
                    isLoading: false,
                    text: 'Back',
                    textColor: Colors.black54,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ContinueButton(
                    onPressed:
                        _allDocumentsComplete(provider)
                            ? () => _submitDocuments(provider, context)
                            : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please complete all documents',
                                  ),
                                ),
                              );
                            },
                    isLoading: false,
                    text: 'Submit',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  bool _allDocumentsComplete(RegistrationProvider provider) {
    return provider.areAllDocumentsComplete([
      'driving_license',
      'latra_sticker',
      'vehicle_registration',
      'plate_number',
    ]);
  }

  void _submitDocuments(RegistrationProvider provider, BuildContext context) {
    try {
      provider.completeRegistration();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DriverDashboard()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Submission failed: $e')));
    }
  }
}
