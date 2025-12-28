import 'package:get/get.dart';
import 'package:hommie/data/services/logout_service.dart';
import 'package:hommie/modules/shared/views/welcomescreen.dart';

class LogoutController extends GetxController {
  final LogoutService _logoutService = Get.put(LogoutService()); 
  
  final RxBool isLoggingOut = false.obs;

  Future<void> handleLogout() async {
    isLoggingOut.value = true;

    try {
      final response = await _logoutService.performLogout();

      isLoggingOut.value = false;
      if (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 401) {
        
        Get.snackbar('Success', 'Logged out successfully');
        Get.offAll(() => WelcomeScreen()); 
        
      } else {
        Get.snackbar('Error', 'Logout failed: ${response.statusText}');
      }
    } catch (e) {
      isLoggingOut.value = false;
      Get.snackbar('Error', 'Connection error! Check your network.');
    }
  }
}