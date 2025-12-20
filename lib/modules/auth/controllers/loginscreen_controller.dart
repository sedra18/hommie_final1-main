import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/helpers/loading_helper.dart';
import 'package:hommie/data/models/user/user_login_model.dart';
import 'package:hommie/data/services/auth_service.dart';
import 'package:hommie/modules/shared/views/empty_screen.dart';
import 'package:hommie/modules/renter/views/home.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/modules/shared/views/welcomescreen.dart';

import '../../owner/views/owner_home_screen.dart';

class LoginScreenController extends GetxController {
  final AuthService _authService = Get.put(AuthService());
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

  Future<void> login() async {
    if (!key.currentState!.validate()) return;

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
          box.write('access_token', data.token);
          box.write('user_role', data.role);
          print('User Role: ${data.role}');
          print('User Token: ${data.token}');
          Get.snackbar('Success', 'Logged in successfully');
          if (data.role == 'renter') {
            Get.offAll(() => Home());
          } else if (data.role == 'owner') {
            Get.offAll(() => OwnerHomeScreen());
          } else {
            Get.offAll(() => Home());
          }

        } else {
          Get.snackbar("Error", "Login failed: No authorization token received.");
        }
      } else {
        Get.snackbar("Error", "Invalid phone number or password.");
      }
    } catch (e) {
      LoadingHelper.hide();
      isLoading.value = false;
      Get.snackbar('Error', 'Connection error!');
    }
  }

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
        Get.to(()=> EmptyScreen());
        showOtpDialog();
      } else {
        String serverError = response.bodyString ?? 'Empty response body';
        String status = response.statusCode.toString();

        Get.snackbar(
          "Error",
          "Failed. Status: $status. Server Response: $serverError",
        );
      }
    } catch (e) {
      LoadingHelper.hide();
      Get.snackbar('Error', 'Connection error! Please check your network.');
    }
  }

  Future<void> verifyResetOtp() async {
    if (otpController.text.length != 6) {
      Get.snackbar("Error", "Please enter a 6-digit verification code.");
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
        newPasswordController.clear();
         Get.to(()=> EmptyScreen());
        showResetPasswordDialog();
      } else {
        String serverError = response.bodyString ?? 'Empty response body';
        String status = response.statusCode.toString();
        Get.snackbar(
          "Error",
          "Verification failed. Status: $status. Server Response: $serverError",
        );
      }
    } catch (e) {
      LoadingHelper.hide();
      Get.snackbar('Error', 'Connection error!');
    }
  }

  Future<void> resetPassword() async {
    if (newPasswordController.text.length < 6) {
      Get.snackbar("Error", "The password must be at least 6 characters long.");
      return;
    }

    LoadingHelper.show();
    try {
      final response = await _authService.resetPassword(
        resetPhoneController.text,
        newPasswordController.text,
      );
      LoadingHelper.hide();

      if (response.statusCode == 200) {
        Get.back();
        Get.snackbar(
          "Success",
          "Password updated successfully. You can log in now.",
        );
        Get.offAll(() => WelcomeScreen());
      } else {
        String serverError = response.bodyString ?? 'Empty response body';
        String status = response.statusCode.toString();
        Get.snackbar(
          "Error",
          "Password update failed. Status: $status. Server Response: $serverError",
        );
      }
    } catch (e) {
      LoadingHelper.hide();
      Get.snackbar('Error', 'Connection error!');
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
              decoration: const InputDecoration(
                labelText: "Phone Number",
                prefixIcon: Icon(
                  Icons.phone,
                  color: AppColors.textSecondaryLight,
                ),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: sendResetOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  "Confirm and Send Code",
                  style: TextStyle(color: AppColors.backgroundLight),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showOtpDialog() {
    otpController.clear();
    Get.defaultDialog(
      title: "Verification Code",
      titleStyle: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              "A code has been sent to ${resetPhoneController.text}. Enter the code:",
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                labelText: "Enter Code",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: verifyResetOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  "Verify",
                  style: TextStyle(color: AppColors.backgroundLight),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showResetPasswordDialog() {
    Get.defaultDialog(
      title: "New Password",
      titleStyle: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      content: Column(
        children: [
          const Text("Enter the new password for your account:"),
          const SizedBox(height: 15),
          TextFormField(
            controller: newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "New Password",
              prefixIcon: Icon(
                Icons.lock_open,
                color: AppColors.textSecondaryLight,
              ),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                "Change Password",
                style: TextStyle(color: AppColors.backgroundLight),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {}
}
