import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/app/bindings/bindings.dart';
<<<<<<< HEAD
import 'package:hommie/app/utils/app_theme.dart';
import 'package:hommie/app/utils/app_translations.dart';
=======
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
import 'package:hommie/modules/renter/views/apartment_details_screen.dart';
import 'package:hommie/modules/renter/views/home.dart';
import 'package:hommie/modules/shared/views/startupscreen.dart';
import 'package:hommie/modules/shared/views/welcomescreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const MyApp());
}

<<<<<<< HEAD
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
=======
class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _Myapp();
}

class _Myapp extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
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
