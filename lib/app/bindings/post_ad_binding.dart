// bindings/post_ad_binding.dart
// import 'package:get/get.dart';
// import 'package:hommie/data/repositories/apartment_repository.dart';
// import 'package:hommie/data/services/owner_aparment_service.dart';
// import 'package:hommie/modules/owner/controllers/post_ad_controller.dart';


// class PostAdBinding extends Bindings {
//   @override
//   void dependencies() {
//     // 1. Register ApartmentApi (singleton)
//     Get.put<ApartmentApi>(ApartmentApi());

//     // 2. Register ApartmentRepository, injecting ApartmentApi
//     Get.put<ApartmentRepository>(ApartmentRepository(Get.find<ApartmentApi>()));

//     // 3. Register PostAdController, injecting ApartmentRepository
//     Get.put<PostAdController>(
//       PostAdController(Get.find<ApartmentRepository>()),
//     );
//   }
// }


