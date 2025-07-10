import 'package:flutter/material.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_images.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/provider/otp_provider.dart';
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
              automaticallyImplyLeading: false,
            ),
            body: Container(
              color: AppColor.white2,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(AppImages.sepeshaRedLogo, width: 100),
                  const SizedBox(height: 16),
                  const _OTPInstructions(),
                  const SizedBox(height: 32),
                  const _OTPInputFields(),
                  const SizedBox(height: 24),
                  const _ResendOTPButton(),
                  Spacer(),
                  ContinueButton(
                    onPressed:
                        provider.isLoading
                            ? () {}
                            : () {
                              final phone = SessionManager.instance.phone;
                              provider.verifyOTP(context, phone, '');
                            },
                    isLoading: provider.isLoading,
                    text: 'Continue',
                    backgroundColor: Colors.red,
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

// Widget for verification title
class _VerificationTitle extends StatelessWidget {
  const _VerificationTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'OTP Verification',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
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
class _OTPInputFields extends StatelessWidget {
  const _OTPInputFields();

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
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (value) {
                  provider.updateOTPDigit(index, value);
                  if (value.isNotEmpty && index < 3) {
                    FocusScope.of(context).nextFocus();
                  } else if (value.isEmpty && index > 0) {
                    FocusScope.of(context).previousFocus();
                  }
                  if (index == 3 && value.isNotEmpty) {
                    final phone = SessionManager.instance.phone;
                    provider.verifyOTP(context, phone, value);
                  }
                },
                decoration: InputDecoration(
                  counterText: '',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Consumer<OTPProvider>(
          builder: (context, provider, child) {
            return provider.errorMessage.isNotEmpty
                ? Text(
                  // provider.errorMessage,
                  "Something went wrong",
                  style: const TextStyle(color: Colors.red, fontSize: 14),
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Didn\'t receive code? ',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        GestureDetector(
          onTap:
              provider.resendTimer == 0
                  ? () {
                    provider.resendOtp(context);
                    provider.startTimer();
                    // Add resend OTP logic here
                  }
                  : null,
          child: Text(
            provider.resendTimer == 0
                ? 'Resend OTP'
                : 'Resend in 00:${provider.resendTimer.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: provider.resendTimer == 0 ? Colors.red : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
