import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/models/signup/signup_step1_model.dart';
import 'package:hommie/data/services/otp_service.dart';
import 'package:hommie/data/services/signup_service.dart';
import 'package:hommie/modules/auth/views/signup_step2.dart';

class SignupStep1Controller extends GetxController {
  final phoneNumberController = TextEditingController();
  final otpController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  RxBool isLoading = false.obs;

  final OtpService otpService = Get.put(OtpService());
  final SignupService signupService = Get.put(SignupService());

  late int otpSent;
  int? pendingUserId;

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) return "Phone number cannot be empty";
    if (value.length != 10) return "Phone number must be exactly 10 digits";
    return null;
  }

  void confirmPhoneNumber() async {
    if (!formKey.currentState!.validate()) return;

    final signupData = SignupStep1Model(
      phoneNumber: phoneNumberController.text,
    );
    await _sendOtp(signupData.phoneNumber);
  }

  Future<void> _sendOtp(String phone) async {
    isLoading.value = true;
    final response = await otpService.sendOtp(phone);
    isLoading.value = false;

    if (response.containsKey('error')) {
      Get.snackbar('Error', 'The phone has already been taken.');
      return;
    }

    otpSent = int.parse(response['otp_test'].toString());

    _showOtpDialog(phone);
  }

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
            TextButton(
              onPressed: () async {
                isLoading.value = true;
                final resendResponse = await otpService.resendResetOtp(phone);
                isLoading.value = false;

                if (resendResponse.containsKey('error')) {
                  Get.snackbar('Error', resendResponse['error']);
                } else {
                  otpSent = int.parse(resendResponse['otp_test'].toString());
                  Get.snackbar('Info', 'OTP resent successfully');
                }
              },
              child: const Text('Resend OTP'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (otpController.text.isEmpty) {
                Get.snackbar("Error", "Please enter OTP");
                return;
              }

              isLoading.value = true;

              final verifyResponse = await signupService.verifyOtp(
                phone: phone,
                otp: otpController.text.trim(),
              );

              isLoading.value = false;

              if (verifyResponse.containsKey('error')) {
                Get.snackbar('Error', verifyResponse['error']);
                return;
              }

              if (verifyResponse.containsKey('message') && !verifyResponse.containsKey('pending_user_id')) {
                Get.snackbar('Error', verifyResponse['message']);
                return;
              }

              pendingUserId = verifyResponse['pending_user_id'];

              if (pendingUserId == null) {
                Get.snackbar('Error', 'Verification failed or User ID missing!');
                return;
              }

              Get.back();
              Get.snackbar('Success', 'OTP verified successfully!');

              Get.to(
                () => const SignupStep2Screen(),
                arguments: {'pendingUserId': pendingUserId!},
              );
            },
            child: const Text('Verify'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
    phoneNumberController.dispose();
    otpController.dispose();
    super.onClose();
  }
}