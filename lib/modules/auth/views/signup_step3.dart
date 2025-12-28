import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/modules/auth/controllers/signup_step3_controller.dart';
import 'package:hommie/app/utils/app_colors.dart';

class SignupStep3Screen extends StatelessWidget {
  const SignupStep3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupStep3Controller());

    const labelStyle = TextStyle(
      fontSize: 16, 
      fontWeight: FontWeight.w600, 
      color: AppColors.textPrimaryLight
    );

    final baseInputDecoration = InputDecoration(
      hintStyle: const TextStyle(color: AppColors.textSecondaryLight),
      filled: true,
      fillColor: AppColors.backgroundLight,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    'Enter your basic information:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                  ),
                  const SizedBox(height: 15),
                  const Text('First Name', style: labelStyle),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: controller.firstNameController,
                    validator: controller.validateName,
                    style: const TextStyle(color: AppColors.textPrimaryLight),
                    decoration: baseInputDecoration.copyWith(hintText: 'e.g., Ahmad'),
                  ),
                  
                  const SizedBox(height: 15),
                  const Text('Last Name', style: labelStyle),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: controller.lastNameController,
                    validator: controller.validateName,
                    style: const TextStyle(color: AppColors.textPrimaryLight),
                    decoration: baseInputDecoration.copyWith(hintText: 'e.g., Sami'),
                  ),
                  
                  const SizedBox(height: 15),
                  const Text('Date of Birth', style: labelStyle),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: controller.dobController,
                    validator: controller.validateDate,
                    readOnly: true,
                    onTap: () => controller.selectDateOfBirth(context),
                    style: const TextStyle(color: AppColors.textPrimaryLight),
                    decoration: baseInputDecoration.copyWith(
                      hintText: 'YYYY-MM-DD',
                      suffixIcon: const Icon(Icons.calendar_today, color: AppColors.textSecondaryLight),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.goToStep3B,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: AppColors.backgroundLight)
                          : const Text('Next →', style: TextStyle(fontSize: 18, color: AppColors.backgroundLight)),
                    )),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}