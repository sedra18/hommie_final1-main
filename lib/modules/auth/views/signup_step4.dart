import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/modules/auth/controllers/signup_step4_controller.dart';
import 'package:hommie/app/utils/app_colors.dart';

class SignupStep4Screen extends StatelessWidget {
  const SignupStep4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupStep4Controller());
    Widget buildImagePicker(String label, RxString imagePath, VoidCallback onTap) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimaryLight)),
          const SizedBox(height: 8),

          Obx(() => InkWell(
            onTap: onTap,
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                border: Border.all(
                  color: imagePath.isNotEmpty
                      ? AppColors.primary
                      : AppColors.textSecondaryLight.withOpacity(0.5),
                  width: imagePath.isNotEmpty ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                color: AppColors.backgroundLight,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      imagePath.value.isNotEmpty
                          ? "Selected: ${imagePath.value.split('/').last}"
                          : "Tap to choose file...",
                      style: TextStyle(
                        fontSize: 14,
                        color: imagePath.isNotEmpty
                            ? AppColors.textPrimaryLight
                            : AppColors.textSecondaryLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    imagePath.isNotEmpty
                        ? Icons.check_circle
                        : Icons.upload_file,
                    color: imagePath.isNotEmpty
                        ? AppColors.primary
                        : AppColors.textSecondaryLight,
                  )
                ],
              ),
            ),
          )),

          const SizedBox(height: 20),
        ],
      );
    }

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),

                const Text(
                  "Upload Photos",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),

                const SizedBox(height: 25),
                buildImagePicker(
                  "Avatar Photo",
                  controller.personalImagePath,
                  () => controller.pickImage(true),
                ),

                buildImagePicker(
                  "National ID Card",
                  controller.nationalIdImagePath,
                  () => controller.pickImage(false),
                ),

                const SizedBox(height: 40),

                Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          controller.uploadImages();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "Finish →",
                          style:
                              TextStyle(fontSize: 18, color: Colors.white),
                        ),
                )),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
