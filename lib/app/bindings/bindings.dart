
import 'package:get/get.dart';
import 'package:hommie/data/repositories/apartment_repository.dart';
import 'package:hommie/data/services/approval_status_service.dart';
import 'package:hommie/data/services/auth_service.dart';
import 'package:hommie/data/services/bookings_service.dart';
import 'package:hommie/data/services/owner_aparment_service.dart';
import 'package:hommie/data/services/token_storage_service.dart';
import 'package:hommie/modules/owner/controllers/nav_controller.dart';
import 'package:hommie/modules/owner/controllers/post_ad_controller.dart';
import 'package:hommie/modules/renter/controllers/renter_home_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🔧 INITIALIZING DEPENDENCIES');
    print('──────────────────────────────────────────────────────────');

    // Auth Service (must be first)
    if (!Get.isRegistered<AuthService>()) {
      Get.put(AuthService(), permanent: true);
      print('✅ AuthService');
    }
    
    Get.lazyPut(() => TokenStorageService());
    print('✅ TokenStorageService');
    
    Get.lazyPut(() => BookingService());
    print('✅ BookingService');
    
    Get.put(ApprovalStatusService());
    print('✅ ApprovalStatusService');

    final apartmentApi = ApartmentApi();
    Get.put(apartmentApi);
    print('✅ ApartmentApi');

    final apartmentRepo = ApartmentRepository();
    Get.put(apartmentRepo);
    print('✅ ApartmentRepository');
    
    Get.lazyPut(() => PostAdController());
    print('✅ PostAdController');
    
    Get.lazyPut(() => NavController());
    print('✅ NavController');
    
    Get.lazyPut(() => RenterHomeController());
    print('✅ HomeController');

    print('═══════════════════════════════════════════════════════════');
  }
}