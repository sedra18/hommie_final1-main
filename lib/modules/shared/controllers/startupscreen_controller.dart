import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/modules/owner/views/main_nav_view.dart';
import 'package:hommie/modules/renter/views/home.dart';
import 'package:hommie/modules/shared/views/welcomescreen.dart';

class StartupscreenController extends GetxController {
  
  final box = GetStorage();
  RxBool waiting = true.obs;
  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 4), () {
      if (box.hasData('access_token')) {
        String? role = box.read('user_role');
        print('Startup check - User Role: $role');
        if (role == 'owner') {
          Get.offAll(() => const MainNavView());
        } else {
          Get.offAll(() => const RenterHomeScreen());
        }
      } else {
        Get.offAll(() => WelcomeScreen());
      }

      waiting.value = false;
    });
  }
}