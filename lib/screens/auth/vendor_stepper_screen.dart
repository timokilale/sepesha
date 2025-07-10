import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/provider/registration_provider.dart';
import 'package:sepesha_app/screens/auth/business_documents_screen.dart';
import 'package:sepesha_app/screens/auth/driver/personal_info_screen.dart';
import 'package:sepesha_app/screens/auth/vendor_stepper_widget.dart';

class VendorStepperScreen extends StatefulWidget {
  const VendorStepperScreen({super.key});

  @override
  State<VendorStepperScreen> createState() => _VendorStepperScreenState();
}

class _VendorStepperScreenState extends State<VendorStepperScreen> {
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
                VendorStepperWidget(
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
                    children: const [
                      PersonalInfoScreen(),
                      BusinessDocumentsScreen(),
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
