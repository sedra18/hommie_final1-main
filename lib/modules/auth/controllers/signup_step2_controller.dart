import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/data/models/signup/signup_step2_model.dart';
import 'package:hommie/data/services/signup_step2_service.dart';
import 'package:hommie/modules/auth/views/signup_step3.dart';

class SignupStep2Controller extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final box = GetStorage();
  final RxBool isPasswordVisible = false.obs;
  final Rx<UserRole> selectedRole = UserRole.renter.obs;
  final RxBool isLoading = false.obs;

  late final int pendingUserId;

  final SignupStep2Service service = Get.put(SignupStep2Service());

  @override
  void onInit() {
    super.onInit();
    pendingUserId = Get.arguments['pendingUserId'];
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void selectRole(UserRole role) {
    selectedRole.value = role;
    String roleString = selectedRole.value == UserRole.owner ? 'owner' : 'renter';

  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Email cannot be empty";
    if (!GetUtils.isEmail(value)) return "Please enter a valid email";
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password cannot be empty";
    if (value.length < 8) return "Password must be at least 8 characters long";
    return null;
  }

  void goToNextStep() async {
    if (!formKey.currentState!.validate()) return;
    String roleString = selectedRole.value == UserRole.owner ? 'owner' : 'renter';
    box.write('temp_signup_role', roleString);
    print("role: $roleString");
    final signupData = SignupStep2Model(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      role: selectedRole.value,
    );

    isLoading.value = true;

    final response = await service.registerStep2(
      pendingUserId: pendingUserId,
      signupStep2Data: signupData,
    );

    isLoading.value = false;

    if (response.containsKey('error')) {
      Get.snackbar(
        'Error',
        'email is already taken!',
        duration: const Duration(seconds: 3),
      );

      if (response['details'] != null) {
        print("Validation details: ${response['details']}");
      }

      return;
    }

    Get.snackbar('Success', 'Step 2 completed');

    Get.to(
      () => SignupStep3Screen(),
      arguments: {"pendingUserId": pendingUserId},
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

