import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sepesha_app/l10n/app_localizations.dart';
import 'package:sepesha_app/Driver/profile/driver_profile_provider.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/provider/customer_history_provider.dart';
import 'package:sepesha_app/provider/localization_provider.dart';
import 'package:sepesha_app/provider/otp_provider.dart';
import 'package:sepesha_app/provider/payment_provider.dart';
import 'package:sepesha_app/provider/registration_provider.dart';
import 'package:sepesha_app/provider/ride_provider.dart';
import 'package:sepesha_app/provider/message_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/provider/user_profile_provider.dart';
import 'package:sepesha_app/provider/user_registration_provider.dart';
import 'package:sepesha_app/screens/auth/splash_screen.dart';
import 'package:sepesha_app/screens/info_handler/app_info.dart';
import 'package:sepesha_app/services/auth_services.dart';
import 'package:sepesha_app/services/token_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Disable SSL certificate verification for testing
  HttpOverrides.global = MyHttpOverrides();

  // Initialize TokenManager to start token refresh scheduling
  await TokenManager.instance.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        ChangeNotifierProvider(create: (_) => UserRegistrationProvider()),
        ChangeNotifierProvider(create: (_) => AppInfo()),
        ChangeNotifierProvider(create: (_) => OTPProvider()),
        ChangeNotifierProvider(create: (_) => RideProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => RegistrationProvider()),
        ChangeNotifierProvider(create: (_) => CustomerHistoryProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => DriverProfileProvider()),
      ],
      child: Consumer<LocalizationProvider>(
        builder: (context, localizationProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Sepesha',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: AppColor.white),
            ),
            locale: localizationProvider.locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('sw'), // Swahili
            ],
            home: kDebugMode ? SplashScreen() : const SplashScreen(),
          );
        },
      ),
    );
  }
}
