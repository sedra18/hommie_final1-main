
import 'package:get/get.dart';
import 'package:hommie/modules/renter/controllers/apartment_details_controller.dart';
import 'package:hommie/modules/renter/controllers/home_controller.dart';
import 'package:hommie/modules/auth/controllers/loginscreen_controller.dart';
import 'package:hommie/modules/auth/controllers/signup_step1_controller.dart';
import 'package:hommie/modules/auth/controllers/signup_step2_controller.dart';
import 'package:hommie/modules/auth/controllers/signup_step3_controller.dart';
import 'package:hommie/modules/auth/controllers/signup_step4_controller.dart';
import 'package:hommie/modules/renter/views/home.dart';

class Binding extends Bindings {
  @override
  void dependencies() {
   Get.lazyPut(() => SignupStep1Controller(), fenix: true);
   Get.lazyPut(() => SignupStep2Controller(), fenix: true);
   Get.lazyPut(() => SignupStep3Controller(), fenix: true);
   Get.lazyPut(() => SignupStep4Controller(), fenix: true);
   Get.lazyPut(() => HomeController(), fenix: true);
   Get.lazyPut(() => ApartmentDetailsController(), fenix: true);
  }
}
