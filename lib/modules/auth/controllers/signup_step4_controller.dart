import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/modules/owner/views/main_nav_view.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/signup/signup_step4_model.dart';
import '../../../data/services/signup_step4_service.dart';
import 'package:hommie/modules/renter/views/home.dart';

import '../../owner/views/owner_home_screen.dart';

class SignupStep4Controller extends GetxController {
  late final int pendingUserId;

  final RxString personalImagePath = ''.obs;
  final RxString nationalIdImagePath = ''.obs;
  final isLoading = false.obs;
  final box = GetStorage();
  final picker = ImagePicker();
  final SignupStep4Service service = SignupStep4Service();

  @override
  void onInit() {
    pendingUserId = Get.arguments['pendingUserId'];
    super.onInit();
  }

  Future<void> pickImage(bool isAvatar) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (isAvatar) {
        personalImagePath.value = picked.path;
      } else {
        nationalIdImagePath.value = picked.path;
      }
    }
  }

  Future<bool> uploadImages() async {
    if (personalImagePath.value.isEmpty || nationalIdImagePath.value.isEmpty) {
      Get.snackbar("Error", "Please select both images");
      return false;
    }

    isLoading.value = true;

    final model = SignupStep4Model(
      pendingUserId: pendingUserId,
      avatarPath: personalImagePath.value,
      idImagePath: nationalIdImagePath.value,
    );

    final result = await service.uploadImages(model);

    isLoading.value = false;

    if (result["success"] == true) {
      Get.snackbar("Success", "Images uploaded successfully");
      final storedRole = box.read('temp_signup_role');
      print("Finalizing account for role: $storedRole");

      if (storedRole == 'owner') {
        Get.offAll(() => const MainNavView());
      } else {
        Get.offAll(() => const RenterHomeScreen());
      }
    box.remove('temp_signup_role');
    finalizeAccount();
    return true;
  } else {
      Get.snackbar("Error", "Upload failed");
      return false;
    }
  }

  Future<void> finalizeAccount() async {
    isLoading.value = true;
    final result = await service.finalizeAccount(pendingUserId);
    isLoading.value = false;

    if (result["success"] == true) {
      Get.snackbar("Success", "Account created. Waiting for admin approval.");
    }
     else {
      Get.snackbar("Error", "Failed to finalize account.");
    }
  }

  Future<void> completeSignup() async {
    bool uploaded = await uploadImages();
    if (uploaded) {
      await finalizeAccount();
    }
  }
}
