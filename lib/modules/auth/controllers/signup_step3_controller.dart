import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/models/signup/signup_step3_model.dart';
import 'package:hommie/data/services/signup_step3_service.dart';
import 'package:hommie/modules/auth/views/signup_step4.dart';

class SignupStep3Controller extends GetxController {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();
  late final int pendingUserId;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  RxBool isLoading = false.obs;

  final SignupStep3Service signupStep3Service = SignupStep3Service();

  @override
  void onInit() {
    super.onInit();
   pendingUserId = Get.arguments['pendingUserId'];
  }

  Future<void> selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dobController.text = picked.toIso8601String().split('T').first;
    }
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) return "This field cannot be empty";
    return null;
  }

  String? validateDate(String? value) {
    if (value == null || value.isEmpty) return "Date of Birth cannot be empty";
    return null;
  }

  void goToStep3B() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    final model = SignupStep3Model(
      pendingUserId: pendingUserId,
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      dateOfBirth: dobController.text,
    );
    final result = await signupStep3Service.submitStep3(model);

    isLoading.value = false;

    if (result['success']) {
         Get.to(() => SignupStep4Screen(), arguments: {
  "pendingUserId": pendingUserId
});
    } else {
      Get.snackbar("Error", "Failed to save data. Try again.");
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    dobController.dispose();
    super.onClose();
  }
}
