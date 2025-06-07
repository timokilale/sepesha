import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/provider/otp_provider.dart';
import 'package:sepesha_app/provider/registration_provider.dart';
import 'package:sepesha_app/provider/ride_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/provider/user_registration_provider.dart';
import 'package:sepesha_app/screens/auth/onboarding_screen.dart';
import 'package:sepesha_app/screens/auth/splash_screen.dart';
import 'package:sepesha_app/screens/info_handler/app_info.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserRegistrationProvider()),
        ChangeNotifierProvider(create: (_) => AppInfo()),
        ChangeNotifierProvider(create: (_) => OTPProvider()),
        ChangeNotifierProvider(create: (_) => RideProvider()),
        ChangeNotifierProvider(create: (_) => RegistrationProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sepesha',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColor.white),
        ),
        home: kDebugMode ? SplashScreen() : const SplashScreen(),
      ),
    );
  }
}
