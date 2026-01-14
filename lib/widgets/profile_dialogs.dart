// lib/modules/shared/widgets/profile_dialogs.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/modules/shared/controllers/profile_controller.dart';
import 'package:image_picker/image_picker.dart';

class ProfileDialogs {
  // ============================================
  // ✉️ Dialog تحديث البريد الإلكتروني
  // ============================================
  static Future<void> showEmailUpdateDialog(BuildContext context) async {
    final profileController = Get.find<ProfileController>();
    final emailController = TextEditingController(
      text: profileController.email,
    );
    final passwordController = TextEditingController();
    var isUpdating = false.obs;

    await Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          '✉️ تغيير البريد الإلكتروني',
          style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'أدخل بريدك الجديد وكلمة المرور الحالية للتأكيد',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // البريد الجديد
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'البريد الجديد',
                  prefixIcon: Icon(Icons.email, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              // كلمة المرور الحالية
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الحالية',
                  prefixIcon: Icon(Icons.lock, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: isUpdating.value
                  ? null
                  : () async {
                      if (emailController.text.isEmpty||
                      passwordController.text.isEmpty) {
                        Get.snackbar('خطأ', 'جميع الحقول مطلوبة');
                        return;
                      }

                      if (!emailController.text.contains('@')) {
                        Get.snackbar('خطأ', 'بريد إلكتروني غير صالح');
                        return;
                      }

                      isUpdating.value = true;

                      final success = await profileController.updateEmail(
                        emailController.text,
                        passwordController.text,
                      );

                      isUpdating.value = false;

                      if (success) {
                        Get.back();
                        Get.snackbar(
                          'تم ✅',
                          'تم تحديث البريد الإلكتروني',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      } else {
                        Get.snackbar(
                          'خطأ ❌',
                          'فشل تحديث البريد - تحقق من كلمة المرور',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: isUpdating.value
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text('تحديث', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // 🔐 Dialog تغيير كلمة المرور
  // ============================================
  static Future<void> showPasswordUpdateDialog(BuildContext context) async {
    final profileController = Get.find<ProfileController>();
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    var isUpdating = false.obs;

    await Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          '🔐 تغيير كلمة المرور',
          style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'أدخل كلمة المرور الحالية والجديدة',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // كلمة المرور الحالية
              TextField(
                controller: currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الحالية',
                  prefixIcon: Icon(Icons.lock, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
              ),

              const SizedBox(height: 16),

              // كلمة المرور الجديدة
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: AppColors.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
              ),

              const SizedBox(height: 16),
              // تأكيد كلمة المرور الجديدة
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'تأكيد كلمة المرور الجديدة',
                  prefixIcon: Icon(Icons.lock_reset, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: isUpdating.value
                  ? null
                  : () async {
                      if (currentPasswordController.text.isEmpty ||
               newPasswordController.text.isEmpty ||
                          confirmPasswordController.text.isEmpty) {
                        Get.snackbar('خطأ', 'جميع الحقول مطلوبة');
                        return;
                      }

                      if (newPasswordController.text !=
                          confirmPasswordController.text) {
                        Get.snackbar('خطأ', 'كلمات المرور غير متطابقة');
                        return;
                      }

                      if (newPasswordController.text.length < 6) {
                        Get.snackbar(
                          'خطأ',
                          'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
                        );
                        return;
                      }

                      isUpdating.value = true;

                      final success = await profileController.updatePassword(
                        currentPasswordController.text,
                        newPasswordController.text,
                      );

                      isUpdating.value = false;

                      if (success) {
                        Get.back();
                        Get.snackbar(
                          'تم ✅',
                          'تم تغيير كلمة المرور بنجاح',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      } else {
                        Get.snackbar(
                          'خطأ ❌',
                          'فشل تغيير كلمة المرور - تحقق من كلمة المرور الحالية',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: isUpdating.value
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text('تغيير', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // 🗑 Dialog حذف الحساب
  // ============================================
  static Future<void> showDeleteAccountDialog(BuildContext context) async {
    final profileController = Get.find<ProfileController>();
    await Get.dialog(
      AlertDialog(
        title: Text('⚠️ حذف الحساب'),
        content: Text('هل أنت متأكد من حذف حسابك؟ هذا الإجراء نهائي.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await profileController.deleteAccount();
              if (success) {
                Get.offAllNamed('/login');
                Get.snackbar('تم', 'تم حذف الحساب');
              } else {
                Get.snackbar('خطأ', 'فشل حذف الحساب');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ============================================
  // 📞 Dialog تغيير رقم الهاتف (مع OTP)
  // ============================================
  static Future<void> showPhoneUpdateDialog(BuildContext context) async {
    final profileController = Get.find<ProfileController>();
    final phoneController = TextEditingController();
    final otpController = TextEditingController();
    var step = 1.obs; // 1 = إدخال الرقم, 2 = إدخال OTP
    var isLoading = false.obs;
    var sentOtp = false.obs;

    await Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Obx(
          () => Text(
            step.value == 1 ? '📞 إدخال الرقم الجديد' : '🔐 إدخال كود التحقق',
            style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
          ),
        ),
        content: SingleChildScrollView(
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (step.value == 1) ...[
                  Text(
                    'أدخل رقم الهاتف الجديد',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف',
                      prefixIcon: Icon(Icons.phone, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ] else ...[
                  Text(
                    'تم إرسال كود التحقق إلى ${phoneController.text}',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: otpController,
                    decoration: InputDecoration(
                      labelText: 'كود التحقق (6 أرقام)',
                      prefixIcon: Icon(Icons.lock, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                  ),
                ],
                const SizedBox(height: 10),
                if (sentOtp.value && step.value == 1)
                  Text(
                    'تم إرسال الكود، راجع رسائلك',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: isLoading.value
                  ? null
                  : () async {
                      if (step.value == 1) {
                        // الخطوة 1: إرسال OTP
                        if (phoneController.text.isEmpty) {
                          Get.snackbar('خطأ', 'يرجى إدخال رقم الهاتف');
                          return;
                        }
                        isLoading.value = true;
                        final success = await profileController.sendPhoneOtp(
                          phoneController.text,
                        );
                        isLoading.value = false;
                        if (success) {
                          sentOtp.value = true;
                          step.value = 2;
                        } else {
                          Get.snackbar('خطأ', 'فشل إرسال كود التحقق');
                        }
                      } else {
                        // الخطوة 2: تأكيد التغيير
                        if (otpController.text.isEmpty|| 
                            otpController.text.length != 6) {
                          Get.snackbar(
                            'خطأ',
                            'يرجى إدخال كود التحقق (6 أرقام)',
                          );
                          return;
                        }
                        isLoading.value = true;
                        final success = await profileController.updatePhone(
                          phoneController.text,
                          otpController.text,
                        );
                        isLoading.value = false;
                        if (success) {
                          Get.back();
                          Get.snackbar(
                            '✅ تم',
                            'تم تغيير رقم الهاتف بنجاح',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        } else {
                          Get.snackbar('خطأ', 'كود التحقق غير صحيح');
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: isLoading.value
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      step.value == 1 ? 'إرسال الكود' : 'تأكيد التغيير',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // 🖼 Dialog تغيير الصورة الشخصية (ممكن نضيفه بعدين)
  // ============================================
  static Future<void> showAvatarUpdateDialog(BuildContext context) async {
    final profileController = Get.find<ProfileController>();
    await Get.dialog(
      AlertDialog(
        title: Text('🖼 تغيير الصورة الشخصية'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primary),
              title: Text('اختيار من المعرض'),
              onTap: () async {
                Get.back();
                final pickedFile = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 85,
                );
                if (pickedFile != null) {
                  final file = File(pickedFile.path);
                  final success = await profileController.updateAvatar(file);
                  if (success) {
                    Get.snackbar('✅ تم', 'تم تحديث الصورة الشخصية');
                  } else {
                    Get.snackbar('❌ خطأ', 'فشل تحديث الصورة');
                  }
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primary),
              title: Text('التقاط صورة'),
              onTap: () async {
                Get.back();
                final pickedFile = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                  imageQuality: 85,
                );
                if (pickedFile != null) {
                  final file = File(pickedFile.path);
                  final success = await profileController.updateAvatar(file);
                  if (success) {
                    Get.snackbar('✅ تم', 'تم تحديث الصورة الشخصية');
                  } else {
                    Get.snackbar('❌ خطأ', 'فشل تحديث الصورة');
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  ///////تغير صورة الهوية
  static Future<void> showIdImageUpdateDialog(BuildContext context) async {
    final profileController = Get.find<ProfileController>();
    await Get.dialog(
      AlertDialog(
        title: Text('🆔 تغيير صورة الهوية'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primary),
              title: Text('اختيار من المعرض'),
              onTap: () async {
                Get.back();
                final pickedFile = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 90,
                );
                if (pickedFile != null) {
                  final file = File(pickedFile.path);
                  final success = await profileController.updateIdImage(file);
                  if (success) {
                    Get.snackbar('✅ تم', 'تم تحديث صورة الهوية');
                  } else {
                    Get.snackbar('❌ خطأ', 'فشل تحديث صورة الهوية');
                  }
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primary),
              title: Text('التقاط صورة'),
              onTap: () async {
                Get.back();
                final pickedFile = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                  imageQuality: 90,
                );
                if (pickedFile != null) {
                  final file = File(pickedFile.path);
                  final success = await profileController.updateIdImage(file);
                  if (success) {
                    Get.snackbar('✅ تم', 'تم تحديث صورة الهوية');
                  } else {
                    Get.snackbar('❌ خطأ', 'فشل تحديث صورة الهوية');
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}