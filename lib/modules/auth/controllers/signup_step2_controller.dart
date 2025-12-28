import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/data/models/signup/signup_step2_model.dart';
import 'package:hommie/data/models/user/user_permission_controller.dart';
import 'package:hommie/data/services/signup_step2_service.dart';
import 'package:hommie/data/services/auth_service.dart';
import 'package:hommie/modules/auth/views/signup_step3.dart';
  // You need this screen

// ═══════════════════════════════════════════════════════════
// SIGNUP STEP 2 CONTROLLER - COMPLETE FLOW
// Navigates to Step 3 (name & DOB) instead of home directly
// ═══════════════════════════════════════════════════════════

class SignupStep2Controller extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final box = GetStorage();
  final RxBool isPasswordVisible = false.obs;
  final Rx<UserRole> selectedRole = UserRole.renter.obs;
  final RxBool isLoading = false.obs;

  late final int pendingUserId;
  String? phoneNumber;

  final SignupStep2Service step2Service = Get.put(SignupStep2Service());
  final authService = Get.find<AuthService>();
  final permissions = Get.find<UserPermissionsController>();

  @override
  void onInit() {
    super.onInit();
    
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📝 SIGNUP STEP 2 CONTROLLER - INITIALIZING');
    print('──────────────────────────────────────────────────────────');
    
    pendingUserId = Get.arguments['pendingUserId'];
    phoneNumber = Get.arguments['phoneNumber'] as String?;
    
    print('✅ Pending User ID: $pendingUserId');
    if (phoneNumber != null) {
      print('✅ Phone Number: $phoneNumber');
    } else {
      print('⚠️  Phone Number: Not provided');
    }
    print('═══════════════════════════════════════════════════════════');
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void selectRole(UserRole role) {
    selectedRole.value = role;
    String roleString = selectedRole.value == UserRole.owner ? 'owner' : 'renter';
    print('👤 Role selected: $roleString');
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Email cannot be empty";
    if (!GetUtils.isEmail(value)) return "Please enter a valid email";
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password cannot be empty";
    if (value.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  Future<void> goToNextStep() async {
    await completeStep2();
  }

  Future<void> completeStep2() async {
    if (!formKey.currentState!.validate()) return;

    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📝 COMPLETING STEP 2 - Email, Password, Role');
    print('──────────────────────────────────────────────────────────');
    print('   Pending User ID: $pendingUserId');
    print('   Email: ${emailController.text}');
    print('   Phone: ${phoneNumber ?? "Not available"}');
    print('   Role: ${selectedRole.value == UserRole.owner ? "owner" : "renter"}');
    print('──────────────────────────────────────────────────────────');

    final signupData = SignupStep2Model(
      email: emailController.text.trim(),
      password: passwordController.text,
      role: selectedRole.value,
    );

    isLoading.value = true;

    try {
      // ═══════════════════════════════════════════════════════════
      // Call registerPage2 API
      // ═══════════════════════════════════════════════════════════
      
      print('');
      print('📤 Calling registerPage2 API...');
      
      final response = await step2Service.registerStep2(
        pendingUserId: pendingUserId,
        signupStep2Data: signupData,
      );

      isLoading.value = false;

      print('📥 Response from registerPage2: $response');

      if (response.containsKey('error')) {
        _handleError(response['error'].toString());
        return;
      }

      print('✅ RegisterPage2 SUCCESS');
      
      // ═══════════════════════════════════════════════════════════
      // Save role temporarily for later use
      // ═══════════════════════════════════════════════════════════
      
      final roleString = selectedRole.value == UserRole.owner ? 'owner' : 'renter';
      box.write('temp_signup_role', roleString);
      
      print('');
      print('💾 Saved temporary role: $roleString');
      print('──────────────────────────────────────────────────────────');
      
      // ═══════════════════════════════════════════════════════════
      // Navigate to Step 3 (Name & Date of Birth)
      // ═══════════════════════════════════════════════════════════
      
      print('');
      print('➡️  Navigating to Step 3 (Name & DOB)...');
      print('═══════════════════════════════════════════════════════════');
      
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Navigate to Step 3 screen
      Get.to(
        () => const SignupStep3Screen(),  // You need to create this screen
        arguments: {
          'pendingUserId': pendingUserId,
          'phoneNumber': phoneNumber,
          'email': emailController.text.trim(),
          'role': roleString,
        },
      );
      
    } catch (e) {
      isLoading.value = false;
      print('💥 Exception during step 2: $e');
      
      if (e.toString().toLowerCase().contains('duplicate') ||
          e.toString().toLowerCase().contains('already exists')) {
        Get.snackbar(
          'Account Exists',
          'This account already exists. Please login instead.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        
        await Future.delayed(const Duration(seconds: 2));
        Get.offAllNamed('/login');
      } else {
        Get.snackbar(
          'Error', 
          'Connection error. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  void _handleError(String error) {
    print('❌ Error: $error');
    
    final errorLower = error.toLowerCase();
    
    if (errorLower.contains('already') || 
        errorLower.contains('exist') ||
        errorLower.contains('duplicate')) {
      Get.snackbar(
        'Account Exists',
        'This email or phone is already registered. Please login instead.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
      );
      
      Future.delayed(const Duration(seconds: 2), () {
        Get.offAllNamed('/login');
      });
    } else {
      Get.snackbar(
        'Error', 
        error,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}