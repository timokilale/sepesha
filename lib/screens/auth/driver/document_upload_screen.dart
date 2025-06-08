import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/Driver/dasboard/driver_dashboard.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/models/driver_document_model.dart';
import 'package:sepesha_app/provider/registration_provider.dart';
import 'package:sepesha_app/screens/auth/driver/widgets/document_card_widget.dart';
import 'package:sepesha_app/services/session_manager.dart';

class DocumentUploadScreen extends StatefulWidget {
  DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  @override
  void initState() {
    super.initState();
    // Listen for changes in the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RegistrationProvider>(
        context,
        listen: false,
      ).addListener(_refreshScreen);
    });
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    Provider.of<RegistrationProvider>(
      context,
      listen: false,
    ).removeListener(_refreshScreen);
    super.dispose();
  }

  void _refreshScreen() {
    if (mounted) {
      setState(() {});
    }
  }

  // This list will be populated from the provider
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RegistrationProvider>(context);

    return Scaffold(
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
            // const SizedBox(height: 24),
            // Document completion summary
            // Container(
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: Colors.grey[100],
            //     borderRadius: BorderRadius.circular(12),
            //     border: Border.all(color: Colors.grey[300]!),
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       const Text(
            //         'Document Completion Status',
            //         style: TextStyle(
            //           fontSize: 16,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //       const SizedBox(height: 12),
            //       _buildDocumentStatusRow(
            //         'Driving License',
            //         provider.isDocumentComplete('driving_license'),
            //       ),
            //       _buildDocumentStatusRow(
            //         'LATRA Sticker',
            //         provider.isDocumentComplete('latra_sticker'),
            //       ),
            //       _buildDocumentStatusRow(
            //         'Vehicle Registration',
            //         provider.isDocumentComplete('vehicle_registration'),
            //       ),
            //       _buildDocumentStatusRow(
            //         'Plate Number',
            //         provider.isDocumentComplete('plate_number'),
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 24),
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
                    // _allDocumentsComplete(provider)
                    //     ?
                    () {
                      final documents =
                          SessionManager.instance.completedDocuments;

                      for (var document in documents) {
                        print("My documents are ${document.toJson()} ");
                      }

                      _submitDocuments(provider, context);
                    },
                    // : () {
                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //       const SnackBar(
                    //         content: Text(
                    //           'Please complete all required documents',
                    //         ),
                    //       ),
                    //     );
                    //   },
                    isLoading: false,
                    text:
                        // _allDocumentsComplete(provider) ?
                        'Submit ✓',
                    // : 'Submit',
                    backgroundColor:
                        _allDocumentsComplete(provider)
                            ? null // Use default color for enabled button
                            : Colors.grey, // Use grey for disabled button
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

  static bool _allDocumentsComplete(RegistrationProvider provider) {
    return provider.areAllDocumentsComplete([
      'driving_license',
      'latra_sticker',
      'vehicle_registration',
      'plate_number',
    ]);
  }

  // Build a row showing document status (complete/incomplete)
  static Widget _buildDocumentStatusRow(String documentName, bool isComplete) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.cancel,
            color: isComplete ? AppColor.primary  : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            documentName,
            style: TextStyle(
              color: isComplete ? Colors.black : Colors.red[700],
              fontWeight: isComplete ? FontWeight.normal : FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _submitDocuments(
    RegistrationProvider provider,
    BuildContext context,
  ) async {
    try {
      provider.completeRegistration();

      final driver = SessionManager.instance.user;
      final vehicle = SessionManager.instance.vehicle;
      final documents = SessionManager.instance.completedDocuments;

      for (var document in documents) {
        print("My documents are ${document.toJson()} ");
      }

      await provider.registerDriver(driver!, vehicle!, documents, context);

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
