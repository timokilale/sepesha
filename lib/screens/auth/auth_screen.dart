import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_images.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/provider/user_registration_provider.dart';
import 'package:sepesha_app/screens/auth/business_documents_screen.dart';
import 'package:sepesha_app/screens/auth/driver/driver_registration_screen.dart';
import 'package:sepesha_app/screens/auth/driver/personal_info_screen.dart';
import 'package:sepesha_app/screens/auth/driver/registration_stepper.dart';
import 'package:sepesha_app/screens/auth/otp_screen.dart';
import 'package:sepesha_app/screens/auth/user_info_registration.dart';
import 'package:sepesha_app/screens/auth/vendor/vendor_registration_screen.dart';
import 'package:sepesha_app/screens/auth/vendor_stepper_screen.dart';
import 'package:sepesha_app/screens/dashboard/dashboard.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/countries.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late UserRegistrationProvider _userRegistration;
  String? phoneNumber;

  @override
  void initState() {
    super.initState();
    _userRegistration = Provider.of<UserRegistrationProvider>(
      context,
      listen: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white2,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  AppImages.authImage,
                  height: 180,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                Text(
                  'Enter your number',
                  style: AppTextStyle.paragraph2(AppColor.lightBlack),
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'ll send you a verification code',
                  style: AppTextStyle.subtext4(AppColor.lightBlack),
                ),
                const SizedBox(height: 32),
                IntlPhoneField(
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: AppTextStyle.paragraph1(AppColor.lightBlack),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColor.lightGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColor.lightGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColor.primary, width: 2),
                    ),
                    fillColor: AppColor.white2,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                  ),
                  initialCountryCode: 'TZ',

                  showCountryFlag: true,
                  dropdownIcon: Icon(
                    Icons.arrow_drop_down,
                    color: AppColor.grey,
                  ),
                  style: AppTextStyle.paragraph1(AppColor.lightBlack),
                  dropdownTextStyle: AppTextStyle.paragraph1(
                    AppColor.lightBlack,
                  ),
                  pickerDialogStyle: PickerDialogStyle(
                    backgroundColor: AppColor.white2,
                    searchFieldCursorColor: AppColor.primary,
                    searchFieldInputDecoration: InputDecoration(
                      // Search field styling
                      hintText: 'Search country...',
                      // border: OutlineInputBorder(
                      //   borderRadius: BorderRadius.circular(8),
                      // ),
                    ),
                  ),

                  keyboardType: TextInputType.phone,
                  languageCode: 'en',
                  onChanged: (phone) {
                    print(phone.completeNumber);
                    phoneNumber = phone.completeNumber;
                  },
                ),
                const SizedBox(height: 24),
                ContinueButton(
                  isLoading: _userRegistration.isLoading,
                  text: "Continue",
                  onPressed: () {
                    // if (_userRegistration.isLoading) return;
                    _userRegistration.userLogin(context, phoneNumber!);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VendorRegistrationScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'I am Vendor',
                        style: TextStyle(
                          color: AppColor.lightBlack,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserInfoScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Register Now',
                        style: TextStyle(
                          color: AppColor.lightBlack,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegistrationStepperScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'I am Driver',
                        style: TextStyle(
                          color: AppColor.lightBlack,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.grey.shade300, thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.grey.shade300, thickness: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: SignInButton(
                    Buttons.appleDark,
                    text: "Continue with Apple",
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => MapScreen()),
                      // );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: SignInButton(
                    Buttons.google,
                    text: "Continue with Google",
                    onPressed: () {},
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text.rich(
                    TextSpan(
                      text: 'By signing up, you agree to our ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      children: [
                        TextSpan(
                          text: 'Terms & Conditions',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.red.shade600,
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.red.shade600,
                          ),
                        ),
                        const TextSpan(text: '. You\'re over 18.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
