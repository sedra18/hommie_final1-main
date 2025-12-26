import 'package:get/get.dart';
import 'package:hommie/data/services/approval_status_service.dart';
import 'package:hommie/data/services/auth_service.dart';
import 'package:hommie/data/models/user/user_permission_controller.dart';
import 'package:hommie/data/repositories/apartment_repository.dart';
import 'package:hommie/data/services/bookings_service.dart';
import 'package:hommie/data/services/owner_aparment_service.dart';
import 'package:hommie/data/services/token_storage_service.dart';
import 'package:hommie/modules/owner/controllers/post_ad_controller.dart';
import 'package:hommie/modules/owner/controllers/nav_controller.dart';


class InitialBinding extends Bindings {
  @override
  void dependencies() {
   

    Get.put(AuthService(), permanent: true);
    print(' AuthService (permanent)');

    Get.put(UserPermissionsController(), permanent: true);
    print(' UserPermissionsController (permanent)');
    Get.lazyPut(() => TokenStorageService());
    Get.lazyPut(() => BookingService());


    // Create ApartmentApi first
    final apartmentApi = ApartmentApi();
    Get.put(apartmentApi);
    print(' ApartmentApi');



    //  Pass apartmentApi to ApartmentRepository constructor
    final apartmentRepo = ApartmentRepository(apartmentApi);
    Get.put(apartmentRepo);
    print(' ApartmentRepository');

   
    // CONTROLLERS (Depend on repositories)
   

    Get.put(PostAdController(apartmentRepo));
    print(' PostAdController');

    // Navigation controller
    Get.put(NavController());
    print(' NavController');
    Get.put((ApprovalStatusService()));
    print(' ApprovalStatusService');

    print('');
    print('[InitialBinding] Core dependencies initialized');
    print(' Ready to start app!');
  }
}
