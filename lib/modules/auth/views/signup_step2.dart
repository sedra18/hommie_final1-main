import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/modules/auth/controllers/signup_step2_controller.dart';
import 'package:hommie/data/models/signup/signup_step2_model.dart';
import 'package:hommie/app/utils/app_colors.dart';

class SignupStep2Screen extends StatelessWidget {
  const SignupStep2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final SignupStep2Controller controller = Get.put(SignupStep2Controller());

    final baseInputDecoration = InputDecoration(
      hintStyle: const TextStyle(color: AppColors.textSecondaryLight),
      filled: true,
      fillColor: AppColors.backgroundLight,
      contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black, width: 1.0),
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
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Enter the following information:',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Email Address',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller.emailController,
                    validator: controller.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppColors.textPrimaryLight),
                    decoration: baseInputDecoration.copyWith(
                      hintText: 'Email Address',
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondaryLight),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  Obx(() => TextFormField(
                        controller: controller.passwordController,
                        validator: controller.validatePassword,
                        obscureText: !controller.isPasswordVisible.value,
                        style: const TextStyle(color: AppColors.textPrimaryLight),
                        decoration: baseInputDecoration.copyWith(
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondaryLight),
                          suffixIcon: IconButton(
                            onPressed: controller.togglePasswordVisibility,
                            icon: Icon(
                              controller.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      )),
                  const SizedBox(height: 30),
                  const Text(
                    'Select your role:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    Widget buildRoleOption(UserRole role, String title) {
                      final isSelected = controller.selectedRole.value == role;
                      return Card(
                        color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.backgroundLight,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.textSecondaryLight.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: ListTile(
                          title: Text(title, style: const TextStyle(color: AppColors.textPrimaryLight)),
                          trailing: Icon(
                            isSelected ? Icons.check_circle : Icons.circle_outlined,
                            color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
                          ),
                          onTap: () => controller.selectRole(role),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        buildRoleOption(UserRole.owner, 'I have apartments to rent'),
                        buildRoleOption(UserRole.renter, 'I am looking for apartments to rent'),
                      ],
                    );
                  }),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value ? null : controller.goToNextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator(color: AppColors.backgroundLight)
                              : const Text(
                                  'Next →',
                                  style: TextStyle(fontSize: 18, color: AppColors.backgroundLight),
                                ),
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
