import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/data/models/user/user_login_model.dart';
import 'package:hommie/data/models/user/user_permission_controller.dart';
import 'package:hommie/data/services/auth_service.dart';
import 'package:hommie/helpers/loading_helper.dart';
import 'package:hommie/modules/owner/views/main_nav_view.dart';
import 'package:hommie/modules/renter/views/home.dart';
import 'package:hommie/modules/shared/views/empty_screen.dart';

<<<<<<< HEAD
=======

>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
class LoginScreenController extends GetxController {
  final AuthService _authService = Get.put(AuthService());
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

<<<<<<< HEAD
=======

>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
  Future<void> login() async {
    if (!key.currentState!.validate()) return;

    print('');
<<<<<<< HEAD

    print(' LOGIN STARTED');

=======
   
    print(' LOGIN STARTED');
   
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
    print('   Phone: ${userPhoneController.text}');

    final user = UserLoginModel(
      phone: userPhoneController.text,
      password: passwordController.text,
    );

    isLoading.value = true;
    LoadingHelper.show();

    try {
<<<<<<< HEAD
      print("[logincontroller]ارسل بيانات الدخول");
      final response = await _authService.loginuser(user);
      print('📥 [LoginController] ورد الرد من السيرفر');
      print('📊 [LoginController] رمز الحالة: ${response.statusCode}');
      print('👤 [LoginController] بيانات المستخدم: ${response.body}');
=======
      final response = await _authService.loginuser(user);
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
      LoadingHelper.hide();
      isLoading.value = false;

      if (response.statusCode == 200 && response.body != null) {
        final data = response.body!;

        if (data.token != null) {
          final box = GetStorage();
<<<<<<< HEAD

=======
          
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
          print('');
          print(' LOGIN SUCCESSFUL');
          print('   Token: ${data.token?.substring(0, 20)}...');
          print('   Role: ${data.role}');
          print('   Is Approved: ${data.isApproved}');

<<<<<<< HEAD
          box.write('access_token', data.token);
          box.write('user_role', data.role);
          box.write('role', data.role);
          box.write('is_approved', data.isApproved ?? false);

=======
  
          box.write('access_token', data.token);
          box.write('user_role', data.role);
          box.write('role', data.role);  
          box.write('is_approved', data.isApproved ?? false);

      
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
          permissions.updateApprovalStatus(
            data.isApproved ?? false,
            data.role ?? '',
          );

          print('   User Role: ${data.role}');
          print('   User Token: ${data.token}');

          Get.snackbar(
<<<<<<< HEAD
            'Success',
            'Logged in successfully',
            backgroundColor: AppColors.success,
            colorText: AppColors.backgroundLight,
            icon: const Icon(
              Icons.check_circle,
              color: AppColors.backgroundLight,
            ),
=======
            'Success', 
            'Logged in successfully',
            backgroundColor: AppColors.success,
            colorText: AppColors.backgroundLight,
            icon: const Icon(Icons.check_circle, color: AppColors.backgroundLight),
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
          );

          await Future.delayed(const Duration(milliseconds: 500));

<<<<<<< HEAD
=======
         
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
          if (data.role == 'renter') {
            print('  Navigating to Renter Home');
            Get.offAll(() => RenterHomeScreen());
          } else if (data.role == 'owner') {
            print('Navigating to Owner Home');
            Get.offAll(() => const MainNavView());
          } else {
            print(' Navigating to Default Home');
            Get.offAll(() => RenterHomeScreen());
          }
          if (!(data.isApproved ?? false)) {
            print(' User is pending approval');
            Future.delayed(const Duration(milliseconds: 1000), () {
              permissions.showPendingApprovalMessage();
            });
          }
<<<<<<< HEAD
        } else {
          print(' No token received');
          Get.snackbar(
            "Error",
            "Login failed: No authorization token received.",
          );
=======


        } else {
          print(' No token received');
          Get.snackbar("Error", "Login failed: No authorization token received.");
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
        }
      } else {
        print(' LOGIN FAILED');
        print('   Status: ${response.statusCode}');
        Get.snackbar("Error", "Invalid phone number or password.");
      }
    } catch (e, stackTrace) {
      LoadingHelper.hide();
      isLoading.value = false;
<<<<<<< HEAD

      print(' LOGIN EXCEPTION');
      print('   Error: $e');
      print(
        '   Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}',
      );

=======
      
      print(' LOGIN EXCEPTION');
      print('   Error: $e');
      print('   Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
      Get.snackbar('Error', 'Connection error!');
    }
  }

<<<<<<< HEAD
=======

  
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
  Future<void> sendResetOtp() async {
    if (resetPhoneController.text.length < 9) {
      Get.snackbar("Error", "Please enter a valid phone number.");
      return;
    }

    LoadingHelper.show();
    try {
      final response = await _authService.sendResetOtp(
        resetPhoneController.text,
      );
      LoadingHelper.hide();

      if (response.statusCode == 200) {
        Get.back();
        Get.snackbar("Success", "Verification code sent successfully.");
        Get.to(() => EmptyScreen());
        showOtpDialog();
      } else {
        Get.snackbar("Error", "Failed to send verification code.");
      }
    } catch (e) {
      LoadingHelper.hide();
      Get.snackbar("Error", "Connection error!");
    }
  }

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
<<<<<<< HEAD
                prefixIcon: const Icon(
                  Icons.phone,
                  color: AppColors.textSecondaryLight,
                ),
=======
                prefixIcon: const Icon(Icons.phone, color: AppColors.textSecondaryLight),
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
<<<<<<< HEAD
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
=======
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: sendResetOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text("Send Code"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showOtpDialog() {
    otpController.clear();
    Get.defaultDialog(
      title: "Verify OTP",
      titleStyle: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      content: SingleChildScrollView(
        child: Column(
          children: [
<<<<<<< HEAD
            const Text("Enter the verification code sent to your phone."),
=======
            const Text(
              "Enter the verification code sent to your phone.",
            ),
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
            const SizedBox(height: 15),
            TextFormField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "OTP Code",
<<<<<<< HEAD
                prefixIcon: const Icon(
                  Icons.pin,
                  color: AppColors.textSecondaryLight,
                ),
=======
                prefixIcon: const Icon(Icons.pin, color: AppColors.textSecondaryLight),
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
<<<<<<< HEAD
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
=======
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text("Verify"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> verifyOtp() async {
    if (otpController.text.length < 4) {
      Get.snackbar("Error", "Please enter a valid OTP.");
      return;
    }

    LoadingHelper.show();
    try {
      final response = await _authService.verifyResetOtp(
        resetPhoneController.text,
        otpController.text,
      );
      LoadingHelper.hide();

      if (response.statusCode == 200) {
        Get.back();
        Get.snackbar("Success", "OTP verified successfully.");
        showNewPasswordDialog();
      } else {
        Get.snackbar("Error", "Invalid OTP.");
      }
    } catch (e) {
      LoadingHelper.hide();
      Get.snackbar("Error", "Connection error!");
    }
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
<<<<<<< HEAD
            const Text("Enter your new password."),
=======
            const Text(
              "Enter your new password.",
            ),
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
            const SizedBox(height: 15),
            TextFormField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "New Password",
<<<<<<< HEAD
                prefixIcon: const Icon(
                  Icons.lock,
                  color: AppColors.textSecondaryLight,
                ),
=======
                prefixIcon: const Icon(Icons.lock, color: AppColors.textSecondaryLight),
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
<<<<<<< HEAD
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
=======
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text("Reset"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
=======

>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
  Future<void> resetPassword() async {
    if (newPasswordController.text.length < 6) {
      Get.snackbar("Error", "Password must be at least 6 characters.");
      return;
    }

    LoadingHelper.show();
    try {
<<<<<<< HEAD
      final response = await _authService.resetPassword(
        resetPhoneController.text,
        newPasswordController.text,
=======
  
      final response = await _authService.resetPassword(
        resetPhoneController.text,    
        newPasswordController.text,   
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
      );
      LoadingHelper.hide();

      if (response.statusCode == 200) {
        Get.back();
        Get.snackbar("Success", "Password reset successfully.");
      } else {
        Get.snackbar("Error", "Failed to reset password.");
      }
    } catch (e) {
      LoadingHelper.hide();
      Get.snackbar("Error", "Connection error!");
    }
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
<<<<<<< HEAD
}
=======
}
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
