import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/modules/auth/controllers/signup_step1_controller.dart';
import 'package:hommie/app/utils/app_colors.dart';

class SignupStep1Screen extends StatelessWidget {
  const SignupStep1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final SignupStep1Controller controller = Get.find<SignupStep1Controller>();
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.backgroundLight,
      
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
      ),
      
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 25.0, bottom: 20.0),
            child: Form(
              key: controller.formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
               // mainAxisAlignment: MainAxisAlignment.start,
               // crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  
                  const SizedBox(height: 50),
                  
                  const Text(
                    'Create your account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  const Text(
                    'Enter your phone number',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  TextFormField(
                    controller: controller.phoneNumberController,
                    validator: controller.validatePhoneNumber,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    style: const TextStyle(color: AppColors.textPrimaryLight),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '+963',
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
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.confirmPhoneNumber,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: AppColors.backgroundLight)
                          : const Text(
                              'Confirm Phone Number',
                              style: TextStyle(
                                fontSize: 18, 
                                color: AppColors.backgroundLight,
                              ),
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