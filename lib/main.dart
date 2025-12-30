import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/app/bindings/bindings.dart';
import 'package:hommie/modules/renter/views/apartment_details_screen.dart';
import 'package:hommie/modules/renter/views/home.dart';
import 'package:hommie/modules/shared/views/startupscreen.dart';
import 'package:hommie/modules/shared/views/welcomescreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const MyApp());
}

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
