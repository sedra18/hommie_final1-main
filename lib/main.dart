import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/app/bindings/bindings.dart';
import 'package:hommie/app/utils/app_theme.dart';
import 'package:hommie/app/utils/app_translations.dart';
import 'package:hommie/modules/renter/views/apartment_details_screen.dart';
import 'package:hommie/modules/renter/views/home.dart';
import 'package:hommie/modules/shared/views/startupscreen.dart';
import 'package:hommie/modules/shared/views/welcomescreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: const Locale('ar', 'SA'),
      fallbackLocale: const Locale('en', 'US'),
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: '/',
      initialBinding: InitialBinding(),
      routes: {
        '/': (context) => StartupScreen(),
        "home": (context) => RenterHomeScreen(),
        "welcome": (context) => WelcomeScreen(),
        "/apartment_details": (context) => ApartmentDetailsScreen(),
      },
    );
  }
}
