import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_images.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/provider/user_registration_provider.dart';
import 'package:sepesha_app/screens/auth/unified_registration_screen.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late UserRegistrationProvider _userRegistration;
  String? phoneNumber;
  String _selectedUserType = 'customer';

  @override
  void initState() {
    super.initState();
    _userRegistration = Provider.of<UserRegistrationProvider>(
      context,
      listen: false,
    );
    // Reset provider state after the build is complete
    // This ensures clean state after logout or app restart
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userRegistration.resetState();
    });
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

                if (_selectedUserType == 'driver') ...[
                  SvgPicture.asset(AppSvg.driverImage, width: 300, height: 300),
                ] else if (_selectedUserType == 'customer') ...[
                  SvgPicture.asset(
                    AppSvg.customerImage,
                    width: 300,
                    height: 300,
                  ),
                ] else if (_selectedUserType == 'vendor') ...[
                  Column(
                    children: [
                      Image.asset(
                        AppImages.authImage,
                        height: 180,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ],

                Text(
                  'Hello, $_selectedUserType!, Welcome back',
                  style: AppTextStyle.paragraph2(AppColor.lightBlack),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your phone number We\'ll send you a verification code',
                  style: AppTextStyle.subtext4(AppColor.lightBlack),
                  textAlign: TextAlign.center,
                ),
                // const SizedBox(height: 8),
                // Text(
                //   'Hello, $_selectedUserType!, Welcome back',
                //   style: AppTextStyle.subtext4(AppColor.lightBlack),
                // ),
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
                      hintText: 'Search country...',
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  languageCode: 'en',
                  onChanged: (phone) {
                    phoneNumber = phone.completeNumber;
                  },
                ),

                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (BuildContext context) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: HugeIcon(
                                  icon: HugeIcons.strokeRoundedBriefcase01,
                                  color: AppColor.primary,
                                ),
                                title: Text(
                                  'Driver',
                                  style: AppTextStyle.paragraph1(
                                    AppColor.black,
                                  ),
                                ),
                                subtitle: Text(
                                  'Login as a driver for easy gain request from customers and vendors',
                                  style: AppTextStyle.subtext4(
                                    AppColor.blackSubtext,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedUserType = 'driver';
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              Divider(),
                              ListTile(
                                leading: Icon(
                                  Icons.storefront_outlined,
                                  color: AppColor.primary,
                                ),
                                title: Text(
                                  'Vendor/Business',
                                  style: AppTextStyle.paragraph1(
                                    AppColor.black,
                                  ),
                                ),
                                subtitle: Text(
                                  'Login as a vendor to manage your products and receive orders',
                                  style: AppTextStyle.subtext4(
                                    AppColor.blackSubtext,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedUserType = 'vendor';
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              Divider(),
                              ListTile(
                                leading: Icon(
                                  Icons.person_outline,
                                  color: AppColor.primary,
                                ),
                                title: Text(
                                  'Customer',
                                  style: AppTextStyle.paragraph1(
                                    AppColor.black,
                                  ),
                                ),
                                subtitle: Text(
                                  'Login as a customer to request deliveries and order products',
                                  style: AppTextStyle.subtext4(
                                    AppColor.blackSubtext,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedUserType = 'customer';
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              SizedBox(height: 30),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Text(
                    _selectedUserType == 'customer'
                        ? 'Login as Driver or Vendor'
                        : _selectedUserType == 'driver'
                        ? 'Login as Customer or Vendor'
                        : 'Login as Customer or Driver',
                    style: AppTextStyle.subtext4(AppColor.primary),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),

                ContinueButton(
                  isLoading: _userRegistration.isLoading,
                  text: "Login",
                  onPressed: () {
                    if (phoneNumber != null) {
                      _userRegistration.userLogin(
                        context,
                        phoneNumber!,
                        _selectedUserType,
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not registered? ',
                      style: TextStyle(
                        color: AppColor.lightBlack,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          showDragHandle: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (BuildContext context) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),

                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: HugeIcon(
                                      icon: HugeIcons.strokeRoundedBriefcase01,
                                      color: AppColor.primary,
                                    ),
                                    title: Text(
                                      'Driver',
                                      style: AppTextStyle.paragraph1(
                                        AppColor.black,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Login as a driver for easy gain request from customers and vendors',
                                      style: AppTextStyle.subtext4(
                                        AppColor.blackSubtext,
                                      ),
                                    ),

                                    onTap: () {
                                      Navigator.pop(context);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  UnifiedRegistrationScreen(
                                                    userType: 'driver',
                                                  ),
                                        ),
                                      );
                                    },
                                  ),
                                  Divider(),
                                  ListTile(
                                    leading: Icon(
                                      Icons.storefront_outlined,
                                      color: AppColor.primary,
                                    ),
                                    title: Text(
                                      'Vendor/Business',
                                      style: AppTextStyle.paragraph1(
                                        AppColor.black,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Login as a vendor to manage your products and receive orders',
                                      style: AppTextStyle.subtext4(
                                        AppColor.blackSubtext,
                                      ),
                                    ),

                                    onTap: () {
                                      Navigator.pop(context);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  UnifiedRegistrationScreen(
                                                    userType: 'vendor',
                                                  ),
                                        ),
                                      );
                                    },
                                  ),
                                  Divider(),
                                  ListTile(
                                    leading: Icon(
                                      Icons.person_outline,
                                      color: AppColor.primary,
                                    ),
                                    title: Text(
                                      'Customer',
                                      style: AppTextStyle.paragraph1(
                                        AppColor.black,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Login as a customer to request deliveries and order products',
                                      style: AppTextStyle.subtext4(
                                        AppColor.blackSubtext,
                                      ),
                                    ),

                                    onTap: () {
                                      Navigator.pop(context);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  UnifiedRegistrationScreen(
                                                    userType: 'customer',
                                                  ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 30),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppColor.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text.rich(
                    TextSpan(
                      text: 'By continuing, you agree to our ',
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
