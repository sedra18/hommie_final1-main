import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/models/signup/signup_step1_model.dart';
import 'package:hommie/data/services/otp_service.dart';
import 'package:hommie/data/services/signup_service.dart';
import 'package:hommie/modules/auth/views/signup_step2.dart';

// ═══════════════════════════════════════════════════════════
// SIGNUP STEP 1 CONTROLLER - COMPLETELY FIXED
// ✅ Shows actual error messages
// ✅ Better logging
// ✅ Handles OTP verification properly
// ✅ Safe error handling
// ═══════════════════════════════════════════════════════════

class SignupStep1Controller extends GetxController {
  final phoneNumberController = TextEditingController();
  final otpController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  RxBool isLoading = false.obs;

  final OtpService otpService = Get.put(OtpService());
  final SignupService signupService = Get.put(SignupService());

  late int otpSent;
  int? pendingUserId;

  // ═══════════════════════════════════════════════════════════
  // VALIDATION
  // ═══════════════════════════════════════════════════════════

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) return "Phone number cannot be empty";
    if (value.length != 10) return "Phone number must be exactly 10 digits";
    return null;
  }

  // ═══════════════════════════════════════════════════════════
  // CONFIRM PHONE NUMBER
  // ═══════════════════════════════════════════════════════════

  void confirmPhoneNumber() async {
    if (!formKey.currentState!.validate()) return;

    final signupData = SignupStep1Model(
      phoneNumber: phoneNumberController.text,
    );
    await _sendOtp(signupData.phoneNumber);
  }

  // ═══════════════════════════════════════════════════════════
  // SEND OTP - FIXED ERROR HANDLING
  // ✅ Shows actual error from backend
  // ═══════════════════════════════════════════════════════════

  Future<void> _sendOtp(String phone) async {
    isLoading.value = true;

    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📱 [SIGNUP] Sending OTP to: $phone');
    print('═══════════════════════════════════════════════════════════');

    try {
      final response = await otpService.sendOtp(phone);
      isLoading.value = false;

      print('Response received: $response');

      // ✅ FIXED: Show actual error message
      if (response.containsKey('error')) {
        final errorMessage = response['error'] as String;

        print('❌ OTP Error: $errorMessage');
        print('═══════════════════════════════════════════════════════════');

        Get.snackbar(
          'Error',
          errorMessage, // ✅ Show real error
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      // ✅ Success - extract OTP
      if (response.containsKey('otp_test')) {
        otpSent = int.parse(response['otp_test'].toString());

        print('✅ OTP sent successfully');
        print('   Test OTP: $otpSent');
        print('═══════════════════════════════════════════════════════════');

        _showOtpDialog(phone);
      } else {
        print('❌ No OTP in response');
        print('═══════════════════════════════════════════════════════════');

        Get.snackbar(
          'Error',
          'Failed to send OTP. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoading.value = false;

      print('❌ Exception: $e');
      print('═══════════════════════════════════════════════════════════');

      Get.snackbar(
        'Error',
        'Connection error: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // SHOW OTP DIALOG
  // ═══════════════════════════════════════════════════════════

  void _showOtpDialog(String phone) {
    Get.dialog(
      AlertDialog(
        title: const Text('Enter OTP Sent Via WhatsApp'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: 'Enter Code',
                counterText: '',
              ),
            ),
            const SizedBox(height: 10),

            // Resend OTP Button
            TextButton(
              onPressed: () async {
                print('');
                print(
                  '═══════════════════════════════════════════════════════════',
                );
                print('🔄 [RESEND] Resending OTP to: $phone');
                print(
                  '═══════════════════════════════════════════════════════════',
                );

                isLoading.value = true;

                try {
                  final resendResponse = await otpService.resendResetOtp(phone);
                  isLoading.value = false;

                  print('Resend response: $resendResponse');

                  if (resendResponse.containsKey('error')) {
                    final errorMessage = resendResponse['error'] as String;

                    print('❌ Resend Error: $errorMessage');
                    print(
                      '═══════════════════════════════════════════════════════════',
                    );

                    Get.snackbar(
                      'Error',
                      errorMessage,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  } else if (resendResponse.containsKey('otp_test')) {
                    otpSent = int.parse(resendResponse['otp_test'].toString());

                    print('✅ OTP resent successfully');
                    print('   New Test OTP: $otpSent');
                    print(
                      '═══════════════════════════════════════════════════════════',
                    );

                    Get.snackbar(
                      'Info',
                      'OTP resent successfully',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  }
                } catch (e) {
                  isLoading.value = false;

                  print('❌ Resend Exception: $e');
                  print(
                    '═══════════════════════════════════════════════════════════',
                  );

                  Get.snackbar(
                    'Error',
                    'Failed to resend OTP',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              child: const Text('Resend OTP'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () => _verifyOtp(phone),
            child: const Text('Verify'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // VERIFY OTP - COMPLETELY FIXED
  // ✅ Proper error handling
  // ✅ Better logging
  // ✅ Safe navigation
  // ═══════════════════════════════════════════════════════════

  Future<void> _verifyOtp(String phone) async {
    if (otpController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter OTP",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🔐 [VERIFY] Verifying OTP');
    print('   Phone: $phone');
    print('   Entered OTP: ${otpController.text.trim()}');
    print('──────────────────────────────────────────────────────────');

    isLoading.value = true;

    try {
      final verifyResponse = await signupService.verifyOtp(
        phone: phone,
        otp: otpController.text.trim(),
      );

      isLoading.value = false;

      print('Verify response: $verifyResponse');
      print('──────────────────────────────────────────────────────────');

      // ✅ Check for errors
      if (verifyResponse.containsKey('error')) {
        final errorMessage = verifyResponse['error'] as String;

        print('❌ Verification failed: $errorMessage');
        print('═══════════════════════════════════════════════════════════');

        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // ✅ Check for message field (might indicate error)
      if (verifyResponse.containsKey('message') &&
          !verifyResponse.containsKey('pending_user_id')) {
        final message = verifyResponse['message'] as String;

        print('❌ Verification message: $message');
        print('═══════════════════════════════════════════════════════════');

        Get.snackbar(
          'Error',
          message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // ✅ Extract pending user ID
      if (verifyResponse.containsKey('pending_user_id')) {
        pendingUserId = verifyResponse['pending_user_id'];

        if (pendingUserId == null) {
          print('❌ Invalid pending user ID');
          print('═══════════════════════════════════════════════════════════');

          Get.snackbar(
            'Error',
            'Verification failed. Invalid user ID.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        print('✅ OTP verified successfully');
        print('   Pending User ID: $pendingUserId');
        print('═══════════════════════════════════════════════════════════');

        Get.back(); // Close OTP dialog

        Get.snackbar(
          'Success',
          'OTP verified successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate to step 2
        Get.to(
          () => const SignupStep2Screen(),
          arguments: {'pendingUserId': pendingUserId!},
        );
      } else {
        print('❌ No pending_user_id in response');
        print('   Response: $verifyResponse');
        print('═══════════════════════════════════════════════════════════');

        Get.snackbar(
          'Error',
          'Verification failed. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      isLoading.value = false;

      print('❌ Exception during verification: $e');
      print(
        '   Stack trace: ${stackTrace.toString().split('\n').take(3).join('\n')}',
      );
      print('═══════════════════════════════════════════════════════════');

      Get.snackbar(
        'Error',
        'An error occurred during verification',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    phoneNumberController.dispose();
    otpController.dispose();
    super.onClose();
  }
}

