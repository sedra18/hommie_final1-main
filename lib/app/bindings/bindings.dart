import 'package:get/get.dart';
import 'package:hommie/data/repositories/apartment_repository.dart';
import 'package:hommie/data/services/approval_status_service.dart';
import 'package:hommie/data/services/bookings_service.dart';
import 'package:hommie/data/services/owner_aparment_service.dart';
import 'package:hommie/data/services/token_storage_service.dart';
import 'package:hommie/modules/owner/controllers/nav_controller.dart';
import 'package:hommie/modules/owner/controllers/post_ad_controller.dart';
import 'package:hommie/modules/renter/controllers/home_controller.dart';



class InitialBinding extends Bindings {
  @override
  void dependencies() {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🔧 INITIALIZING DEPENDENCIES');
    print('──────────────────────────────────────────────────────────');


    
    Get.lazyPut(() => TokenStorageService());
    print('    TokenStorageService');
    
    Get.lazyPut(() => BookingService());
    print('    BookingService');
    
    //  Approval Status Service (for owner approval check)
    Get.put(ApprovalStatusService());
    print('    ApprovalStatusService');

    
    // Create ApartmentApi instance
    final apartmentApi = ApartmentApi();
    Get.put(apartmentApi);
    print('    ApartmentApi');

    final apartmentRepo = ApartmentRepository();
    Get.put(apartmentRepo);
    print('    ApartmentRepository');

    
    Get.lazyPut(() => PostAdController());
    print('    PostAdController');
    Get.lazyPut(() => NavController());
    print('    NavController');
    
    Get.lazyPut(() => RenterHomeController());
    print('    HomeController');

  }
}