import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/data/models/user/user_login_model.dart';
import 'package:hommie/data/models/user/user_permission_controller.dart';
import 'package:hommie/data/services/auth_service.dart';
import 'package:hommie/data/services/otp_service.dart';
import 'package:hommie/modules/owner/views/main_nav_view.dart';
import 'package:hommie/modules/renter/views/renter_home_screen.dart';
import 'package:hommie/helpers/loading_helper.dart';

class LoginScreenController extends GetxController {
  final AuthService _authService = Get.put(AuthService());
  final OtpService _otpService = Get.put(OtpService());
  final permissions = Get.put(UserPermissionsController());
  
  var logingFirstTime = false;
  final userPhoneController = TextEditingController();
  final passwordController = TextEditingController();
  final key = GlobalKey<FormState>();

  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;

  final resetPhoneController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return "Phone number cannot be empty";
    }
    if (value.length < 9) {
      return "Phone number is too short";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password cannot be empty";
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════
  // LOGIN
  // ═══════════════════════════════════════════════════════════

  Future<void> login() async {
    if (!key.currentState!.validate()) return;

    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🔐 LOGIN STARTED');
    print('   Phone: ${userPhoneController.text}');
    print('──────────────────────────────────────────────────────────');

    final user = UserLoginModel(
      phone: userPhoneController.text,
      password: passwordController.text,
    );

    isLoading.value = true;
    LoadingHelper.show();

    try {
      final response = await _authService.loginuser(user);
      LoadingHelper.hide();
      isLoading.value = false;

      if (response.statusCode == 200 && response.body != null) {
        final data = response.body!;

        if (data.token != null) {
          final box = GetStorage();
          
          print('✅ LOGIN SUCCESSFUL');
          print('   Token: ${data.token?.substring(0, 20)}...');
          print('   Role: ${data.role}');
          print('   User ID: ${data.id}');
          print('   Is Approved: ${data.isApproved}');
          print('──────────────────────────────────────────────────────────');

          // Save to GetStorage
          box.write('access_token', data.token);
          box.write('user_role', data.role);
          box.write('role', data.role);
          box.write('user_id', data.id);
          box.write('is_approved', data.isApproved ?? false);

          // Update permissions
          permissions.updateApprovalStatus(
            data.isApproved ?? false,
            data.role ?? '',
          );

          Get.snackbar(
            'Success', 
            'Logged in successfully',
            backgroundColor: AppColors.success,
            colorText: AppColors.backgroundLight,
            icon: const Icon(Icons.check_circle, color: AppColors.backgroundLight),
          );

          await Future.delayed(const Duration(milliseconds: 500));

          // Navigate based on role
          if (data.role == 'renter') {
            print('🏠 Navigating to Renter Home');
            print('═══════════════════════════════════════════════════════════');
            Get.offAll(() => const RenterHomeScreen());
          } else if (data.role == 'owner') {
            print('🏠 Navigating to Owner Home');
            print('═══════════════════════════════════════════════════════════');
            Get.offAll(() => const MainNavView());
          } else {
            print('🏠 Navigating to Default Home');
            print('═══════════════════════════════════════════════════════════');
            Get.offAll(() => const RenterHomeScreen());
          }

          // Show pending approval message if needed
          if (!(data.isApproved ?? false)) {
            print('⚠️ User is pending approval');
            Future.delayed(const Duration(milliseconds: 1000), () {
              permissions.showPendingApprovalMessage();
            });
          }

        } else {
          print('❌ No token received');
          print('═══════════════════════════════════════════════════════════');
          Get.snackbar("Error", "Login failed: No authorization token received.");
        }
      } else {
        print('❌ LOGIN FAILED');
        print('   Status: ${response.statusCode}');
        print('═══════════════════════════════════════════════════════════');
        Get.snackbar("Error", "Invalid phone number or password.");
      }
    } catch (e, stackTrace) {
      LoadingHelper.hide();
      isLoading.value = false;
      
      print('❌ LOGIN EXCEPTION');
      print('   Error: $e');
      print('   Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      print('═══════════════════════════════════════════════════════════');
      
      Get.snackbar('Error', 'Connection error!');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // PASSWORD RESET FLOW
  // ═══════════════════════════════════════════════════════════

  /// Step 1: Send Reset OTP
  Future<void> sendResetOtp() async {
    if (resetPhoneController.text.length < 9) {
      Get.snackbar("Error", "Please enter a valid phone number.");
      return;
    }

    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📧 SENDING RESET OTP');
    print('   Phone: ${resetPhoneController.text}');
    print('──────────────────────────────────────────────────────────');

    LoadingHelper.show();
    try {
      final response = await _otpService.resendResetOtp(
        resetPhoneController.text,
      );
      
      LoadingHelper.hide();

      print('📥 Response received: $response');
      print('═══════════════════════════════════════════════════════════');

      if (response.containsKey('error')) {
        Get.snackbar("Error", response['error']);
      } else {
        Get.back();  // Close phone dialog
        Get.snackbar("Success", "Verification code sent successfully.");
        showOtpDialog();
      }
    } catch (e) {
      LoadingHelper.hide();
      print('❌ Exception: $e');
      print('═══════════════════════════════════════════════════════════');
      Get.snackbar("Error", "Connection error!");
    }
  }

  /// Step 2: Verify OTP
  Future<void> verifyOtp() async {
    if (otpController.text.length < 4) {
      Get.snackbar("Error", "Please enter a valid OTP.");
      return;
    }

    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🔍 VERIFYING OTP');
    print('   Phone: ${resetPhoneController.text}');
    print('   Code: ${otpController.text.replaceAll(RegExp(r'\d'), '*')}');
    print('──────────────────────────────────────────────────────────');

    LoadingHelper.show();
    try {
      final response = await _otpService.verifyResetOtp(
        resetPhoneController.text,
        otpController.text,
      );
      
      LoadingHelper.hide();

      print('📥 Response received: $response');
      print('═══════════════════════════════════════════════════════════');

      if (response.containsKey('error')) {
        Get.snackbar("Error", response['error']);
      } else {
        Get.back();  // Close OTP dialog
        Get.snackbar("Success", "OTP verified successfully.");
        showNewPasswordDialog();
      }
    } catch (e) {
      LoadingHelper.hide();
      print('❌ Exception: $e');
      print('═══════════════════════════════════════════════════════════');
      Get.snackbar("Error", "Connection error!");
    }
  }

  /// Step 3: Reset Password
  Future<void> resetPassword() async {
    if (newPasswordController.text.length < 6) {
      Get.snackbar("Error", "Password must be at least 6 characters.");
      return;
    }

    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🔐 RESETTING PASSWORD');
    print('   Phone: ${resetPhoneController.text}');
    print('──────────────────────────────────────────────────────────');

    LoadingHelper.show();
    try {
      final response = await _otpService.resetPassword(
        phone: resetPhoneController.text,
        newPassword: newPasswordController.text,
      );
      
      LoadingHelper.hide();

      print('📥 Response received: $response');
      print('═══════════════════════════════════════════════════════════');

      if (response.containsKey('error')) {
        Get.snackbar("Error", response['error']);
      } else {
        Get.back();  // Close password dialog
        Get.snackbar("Success", "Password reset successfully.");
        
        // Clear all fields
        resetPhoneController.clear();
        otpController.clear();
        newPasswordController.clear();
      }
    } catch (e) {
      LoadingHelper.hide();
      print('❌ Exception: $e');
      print('═══════════════════════════════════════════════════════════');
      Get.snackbar("Error", "Connection error!");
    }
  }

  // ═══════════════════════════════════════════════════════════
  // UI DIALOGS
  // ═══════════════════════════════════════════════════════════

  void showResetPhoneDialog() {
    resetPhoneController.clear();
    Get.defaultDialog(
      title: "Reset Password",
      titleStyle: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      content: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              "Enter your account's phone number to receive a verification code.",
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: resetPhoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Phone Number",
                prefixIcon: const Icon(Icons.phone, color: AppColors.textSecondaryLight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.textSecondaryLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
      confirm: ElevatedButton(
        onPressed: sendResetOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text("Send Code", style: TextStyle(color: Colors.white)),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("Cancel", style: TextStyle(color: AppColors.textSecondaryLight)),
      ),
    );
  }

  void showOtpDialog() {
    otpController.clear();
    Get.defaultDialog(
      title: "Enter Verification Code",
      titleStyle: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      content: SingleChildScrollView(
        child: Column(
          children: [
            const Text("Enter the verification code sent to your phone."),
            const SizedBox(height: 15),
            TextFormField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                hintText: "Verification Code",
                prefixIcon: const Icon(Icons.vpn_key, color: AppColors.textSecondaryLight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.textSecondaryLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                counterText: "",
              ),
            ),
          ],
        ),
      ),
      confirm: ElevatedButton(
        onPressed: verifyOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text("Verify", style: TextStyle(color: Colors.white)),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("Cancel", style: TextStyle(color: AppColors.textSecondaryLight)),
      ),
    );
  }

  void showNewPasswordDialog() {
    newPasswordController.clear();
    Get.defaultDialog(
      title: "New Password",
      titleStyle: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      content: SingleChildScrollView(
        child: Column(
          children: [
            const Text("Enter your new password."),
            const SizedBox(height: 15),
            TextFormField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "New Password",
                prefixIcon: const Icon(Icons.lock, color: AppColors.textSecondaryLight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.textSecondaryLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
      confirm: ElevatedButton(
        onPressed: resetPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text("Reset Password", style: TextStyle(color: Colors.white)),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("Cancel", style: TextStyle(color: AppColors.textSecondaryLight)),
      ),
    );
  }

  @override
  void onClose() {
    userPhoneController.dispose();
    passwordController.dispose();
    resetPhoneController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    super.onClose();
  }
}