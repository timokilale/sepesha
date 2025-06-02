import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/Driver/dasboard/driver_dashboard.dart';
import 'package:sepesha_app/Driver/driver_home_screen.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/provider/registration_provider.dart';
import 'package:sepesha_app/screens/auth/driver/widgets/document_card_widget.dart';

class DocumentUploadScreen extends StatelessWidget {
  const DocumentUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RegistrationProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
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
                // OutlinedButton(

                //   child: const Text('Back'),
                // ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ContinueButton(
                  onPressed:
                      _allDocumentsComplete(provider)
                          ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DriverDashboard(),
                              ),
                            );
                            _submitDocuments(provider, context);
                          }
                          : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MainLayout(),
                              ),
                            );
                          },
                  isLoading: false,
                  text: 'Submit',
                ),

                //  ElevatedButton(

                //   child: const Text('Submit Documents'),
                // ),
              ),
            ],
          ),
        ],
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
    // Submit all documents and complete registration
    provider.completeRegistration();

    // Navigate to dashboard or success screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DriverDashboard()),
    );
  }
}
