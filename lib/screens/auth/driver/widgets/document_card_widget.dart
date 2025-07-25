import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/provider/registration_provider.dart';
import 'package:sepesha_app/screens/auth/driver/widgets/image_upload_widget.dart';

class DocumentCardWidget extends StatefulWidget {
  final String title;
  final String documentKey;
  final bool requiresIdNumber;
  final bool requiresExpiryDate;

  final bool isCompleted;

  const DocumentCardWidget({
    super.key,
    required this.title,
    required this.documentKey,
    this.requiresIdNumber = false,
    this.requiresExpiryDate = false,
     this.isCompleted = false,

  });

  @override
  State<DocumentCardWidget> createState() => _DocumentCardWidgetState();
}

class _DocumentCardWidgetState extends State<DocumentCardWidget> {
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _expireDateController = TextEditingController();
  File? _selectedFile;
  final _formKey = GlobalKey<FormState>();
  bool _imageError = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _loadExistingData();
    });
    _loadExistingData();
  }

  @override
  void dispose() {
    _idNumberController.dispose();
    _expireDateController.dispose();
    super.dispose();
  }

  void _loadExistingData() {
    final provider = Provider.of<RegistrationProvider>(context, listen: false);
    final documentData = provider.documents[widget.documentKey];

    if (documentData != null) {
      setState(() {
        _selectedFile = documentData['file'];
        if (widget.requiresIdNumber) {
          _idNumberController.text = documentData['idNumber'] ?? '';
        }
        if (widget.requiresExpiryDate) {
          _expireDateController.text = documentData['expiryDate'] ?? '';
        }
      });
    }
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
          color: isCompleted ? AppColor.primary : Colors.grey,
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
                color: isCompleted ? AppColor.primary : Colors.grey,
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
                const Icon(Icons.check_circle, color: Colors.green, size: 24),
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
                          _imageError = false;
                        });
                      },
                    ),
                    _imageError
                        ? Text(
                          'Please upload document file',
                          style: AppTextStyle.smallText2(AppColor.primary),
                        )
                        : SizedBox.shrink(),
                    const SizedBox(height: 24),
                    ContinueButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (_selectedFile == null) {
                            setModalState(() {
                              _imageError = true;
                            });
                            return;
                          }

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

  void _completeDocument(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
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
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('${widget.title} saved successfully'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to save document: $e'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
