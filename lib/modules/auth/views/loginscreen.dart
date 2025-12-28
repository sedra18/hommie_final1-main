import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/modules/auth/controllers/loginscreen_controller.dart';
import 'package:hommie/app/utils/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginScreenController controller = Get.put(LoginScreenController(), permanent: true);
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
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Form(
              key: controller.key,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 50),
                  Image.asset(
                    'assets/images/logo.png',
                    height: 120, 
                    width: 120,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 40),
                  TextFormField(
                    controller: controller.userPhoneController, 
                    validator: controller.validatePhone, 
                    keyboardType: TextInputType.phone, 
                    style: const TextStyle(color: AppColors.textPrimaryLight),
                    decoration: InputDecoration(
                      hintText: 'Phone Number', 
                      hintStyle: const TextStyle(color: AppColors.textSecondaryLight),
                      prefixIcon: const Icon(Icons.phone, color: AppColors.textSecondaryLight), 
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
                    ),
                  ), 
                  const SizedBox(height: 15),

                  Obx(() => TextFormField(
                    controller: controller.passwordController,
                    validator: controller.validatePassword,
                    obscureText: !controller.isPasswordVisible.value,
                    style: const TextStyle(color: AppColors.textPrimaryLight),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: const TextStyle(color: AppColors.textSecondaryLight),
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondaryLight),
                      suffixIcon: IconButton(
                          onPressed: controller.togglePasswordVisibility,
                          icon: Icon(
                              controller.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                              color: AppColors.textSecondaryLight)),
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
                    ),
                  )), 
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: controller.login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Obx(() => 
                          controller.isLoading.value 
                          ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: AppColors.backgroundLight,
                                  strokeWidth: 2,
                                ),
                              )
                          : const Text(
                                'Log In',
                                style: TextStyle(
                                  fontSize: 18, 
                                  color: AppColors.backgroundLight,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10), 
               Align(
               alignment: Alignment.center,
               child: TextButton(
               onPressed: controller.showResetPhoneDialog,
               child: const Text(
                    'Forgot Password?',
                     style: TextStyle(
                     color: AppColors.textPrimaryLight,
                     fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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