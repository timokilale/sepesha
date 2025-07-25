import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_images.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/provider/otp_provider.dart';
import 'package:sepesha_app/screens/auth/auth_screen.dart';
import 'package:sepesha_app/services/session_manager.dart';

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OTPProvider()..startTimer(),
      child: Consumer<OTPProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColor.white2,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  // Safely pop back to auth screen
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    // Fallback: navigate to auth screen if no previous route
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthScreen()),
                    );
                  }
                },
              ),
            ),
            body: Container(
              color: AppColor.white2,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Add some top spacing
                          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                          Image.asset(AppImages.sepeshaRedLogo, width: 100),
                          const SizedBox(height: 16),
                          const _OTPInstructions(),
                          const SizedBox(height: 32),
                          const _OTPInputFields(),
                          const SizedBox(height: 16),
                          const _OTPActions(),
                          const SizedBox(height: 24),
                          const _ResendOTPButton(),
                          // Add bottom spacing to push content up
                          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                        ],
                      ),
                    ),
                  ),
                  // Fixed button at bottom
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ContinueButton(
                      onPressed:
                          provider.isLoading
                              ? () {}
                              : () {
                                try {
                                  final phone = SessionManager.instance.phone;
                                  final userType =
                                      SessionManager.instance.userType ??
                                      'customer';
                                  provider.verifyOTP(
                                    context,
                                    phone,
                                    userType: userType,
                                  );
                                } catch (e) {
                                  print('Error getting session data: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Session expired. Please login again.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                      isLoading: provider.isLoading,
                      text: 'Verify',
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Widget for OTP actions (Clear button)
class _OTPActions extends StatelessWidget {
  const _OTPActions();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OTPProvider>(context);

    // Only show clear button if there's any input
    final hasInput = provider.otpControllers.any((controller) => controller.text.isNotEmpty);

    if (!hasInput) return const SizedBox();

    return TextButton.icon(
      onPressed: () {
        provider.clearOTPFields();
        // Focus on first field after clearing
        FocusScope.of(context).requestFocus(FocusNode());
      },
      icon: const Icon(Icons.clear, size: 16),
      label: const Text('Clear'),
      style: TextButton.styleFrom(
        foregroundColor: Colors.grey[600],
        textStyle: const TextStyle(fontSize: 14),
      ),
    );
  }
}

// Widget for OTP instructions
class _OTPInstructions extends StatefulWidget {
  const _OTPInstructions();

  @override
  State<_OTPInstructions> createState() => _OTPInstructionsState();
}

class _OTPInstructionsState extends State<_OTPInstructions> {
  int? phoneNumber;
  @override
  void initState() {
    super.initState();
    phoneNumber = SessionManager.instance.phone;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Enter the OTP sent to your mobile number',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          '+255 $phoneNumber',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.red[600],
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Widget for OTP input fields
class _OTPInputFields extends StatefulWidget {
  const _OTPInputFields();

  @override
  State<_OTPInputFields> createState() => _OTPInputFieldsState();
}

class _OTPInputFieldsState extends State<_OTPInputFields> {
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleKeyEvent(int index, String value) {
    final provider = Provider.of<OTPProvider>(context, listen: false);

    if (value.isNotEmpty) {
      // Move to next field if not the last one
      if (index < 3) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last field filled, remove focus
        _focusNodes[index].unfocus();
      }
    }

    provider.updateOTPDigit(index, value);

    // Check if all fields are filled for auto-verification
    final otp = provider.otpControllers.map((c) => c.text).join();
    if (otp.length == 4 && !provider.isLoading) {
      // Only auto-verify if not already processing and add longer delay
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && !provider.isLoading) {
          // Double-check we're not already processing
          try {
            final phone = SessionManager.instance.phone;
            final userType = SessionManager.instance.userType ?? 'customer';
            provider.verifyOTP(context, phone, userType: userType);
          } catch (e) {
            print('Error in auto-verification: $e');
            // Don't show error to user for auto-verification, just log it
          }
        }
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OTPProvider>(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            return SizedBox(
              width: 60,
              height: 60,
              child: TextField(
                controller: provider.otpControllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (value) => _handleKeyEvent(index, value),
                onTap: () {
                  // Clear field when tapped for better UX
                  provider.otpControllers[index].selection = TextSelection.fromPosition(
                    TextPosition(offset: provider.otpControllers[index].text.length),
                  );
                },
                decoration: InputDecoration(
                  counterText: '',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: provider.errorMessage.isNotEmpty
                          ? Colors.red.shade300
                          : Colors.grey[300]!,
                      width: 2
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: provider.errorMessage.isNotEmpty
                          ? Colors.red
                          : Colors.blue,
                      width: 2
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Consumer<OTPProvider>(
          builder: (context, provider, child) {
            return provider.errorMessage.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade600, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.errorMessage,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox();
          },
        ),
      ],
    );
  }
}

// Widget for resend OTP button
class _ResendOTPButton extends StatelessWidget {
  const _ResendOTPButton();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OTPProvider>(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Didn\'t receive the code? ',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            if (provider.resendTimer == 0)
              TextButton(
                onPressed: () async {
                  // Clear fields before resending
                  provider.clearOTPFields();
                  await provider.resendOtp(context);
                  provider.startTimer();

                  // Show success message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text('New OTP sent successfully!'),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text(
                  'Resend OTP',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              )
            else
              Text(
                'Resend in ${provider.resendTimer}s',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        if (provider.resendTimer > 0)
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(
              value: (30 - provider.resendTimer) / 30,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade300),
              minHeight: 2,
            ),
          ),
      ],
    );
  }
}
