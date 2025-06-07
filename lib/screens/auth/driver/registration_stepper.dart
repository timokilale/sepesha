import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/provider/registration_provider.dart';
import 'package:sepesha_app/screens/auth/driver/document_upload_screen.dart';
import 'package:sepesha_app/screens/auth/driver/personal_info_screen.dart';
import 'package:sepesha_app/screens/auth/driver/vehicle_info_screen.dart';
import 'package:sepesha_app/screens/auth/driver/widgets/registration_stepper_widget.dart';

class RegistrationStepperScreen extends StatefulWidget {
  const RegistrationStepperScreen({super.key});

  @override
  State<RegistrationStepperScreen> createState() =>
      _RegistrationStepperScreenState();
}

class _RegistrationStepperScreenState extends State<RegistrationStepperScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegistrationProvider(),
      child: Consumer<RegistrationProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Driver Registration'),
              centerTitle: true,
            ),
            body: Column(
              children: [
                // Stepper Widget
                RegistrationStepperWidget(
                  currentStep: provider.currentStep,
                  onStepTapped: (step) {
                    if (step <= provider.currentStep) {
                      _pageController.jumpToPage(step);
                      provider.setCurrentStep(step);
                    }
                  },
                ),

                // Page View
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children:  [
                      PersonalInfoScreen(),
                      VehicleInfoScreen(),
                      DocumentUploadScreen(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
