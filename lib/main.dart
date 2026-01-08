import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/app/bindings/bindings.dart';
import 'package:hommie/data/services/auth_service.dart';
import 'package:hommie/modules/owner/views/main_nav_view.dart';
import 'package:hommie/modules/renter/views/apartment_details_screen.dart';
import 'package:hommie/modules/renter/views/renter_home_screen.dart';
import 'package:hommie/modules/shared/views/startupscreen.dart';
import 'package:hommie/modules/shared/views/welcomescreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialize AuthService first
  Get.put(AuthService());
  GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get AuthService instance
    final authService = Get.put(AuthService());

    // Determine initial route based on login state
    String initialRoute = '/';

    if (authService.checkIsLoggedIn()) {
      final role = authService.getUserRole();
      if (role == 'renter') {
        initialRoute = '/home';
      } else if (role == 'owner') {
        initialRoute = '/owner_home';
      }
    }

    print('🚀 App starting with route: $initialRoute');

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      initialBinding: InitialBinding(),
      routes: {
        '/': (context) => StartupScreen(),
        '/home': (context) => RenterHomeScreen(),
        '/owner_home': (context) => MainNavView(),
        '/welcome': (context) => WelcomeScreen(),
        '/apartment_details': (context) => ApartmentDetailsScreen(),
      },
    );
  }
}
