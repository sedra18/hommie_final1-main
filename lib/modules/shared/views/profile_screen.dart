<<<<<<< HEAD
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/app/utils/app_theme.dart';
=======
import 'package:flutter/material.dart';
import 'package:get/get.dart';
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
import 'package:hommie/modules/shared/controllers/logout_controller.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/widgets/pending_approval_widget.dart';
import 'package:hommie/data/services/approval_status_service.dart';

// ═══════════════════════════════════════════════════════════
// OWNER PROFILE SCREEN - WITH APPROVAL CHECK AND LOGOUT
// ═══════════════════════════════════════════════════════════

<<<<<<< HEAD
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
=======
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
  Widget build(BuildContext context) {
    final LogoutController logoutController = Get.put(LogoutController());
    final approvalService = Get.find<ApprovalStatusService>();

    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        title: Text('Profile'.tr),
        backgroundColor: AppColors.primary,
      ),

=======
        title: const Text("Profile"),
        backgroundColor: AppColors.primary,
      ),
      backgroundColor: Colors.white,
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
      body: Obx(() {
        // ✅ Check approval status
        if (!approvalService.isApproved.value) {
          return PendingApprovalWidget(
            onRefresh: () => approvalService.manualRefresh(),
          );
        }

        // ✅ Approved - show profile content
        return _buildProfileContent(logoutController);
      }),
    );
  }

  Widget _buildProfileContent(LogoutController logoutController) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Profile Avatar
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.primary.withOpacity(0.2),
<<<<<<< HEAD
            child: Icon(Icons.person, size: 60, color: AppColors.primary),
=======
            child: Icon(
              Icons.person,
              size: 60,
              color: AppColors.primary,
            ),
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
          ),

          const SizedBox(height: 16),

          // Name
<<<<<<< HEAD
          Text(
            " اسم المالك".tr,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
=======
          const Text(
            'اسم المالك',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
          ),

          const SizedBox(height: 8),

          // Email
<<<<<<< HEAD
          Text(
            "owner@example.com",
            style: TextStyle(fontSize: 16, color: Colors.grey),
=======
          const Text(
            'owner@example.com',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
          ),

          const SizedBox(height: 24),

          // Approval Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green, width: 2),
            ),
<<<<<<< HEAD
            child: Row(
=======
            child: const Row(
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text(
<<<<<<< HEAD
                  'حساب موثق'.tr,
=======
                  'حساب موثق',
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Profile Options
          _buildProfileOption(
            icon: Icons.edit,
<<<<<<< HEAD
            title: 'تعديل الملف الشخصي'.tr,
=======
            title: 'تعديل الملف الشخصي',
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
            onTap: () {
              Get.snackbar('قريباً', 'ميزة تعديل الملف الشخصي قيد التطوير');
            },
          ),

<<<<<<< HEAD
          // خيار تغيير الوضع (داكن / فاتح)
=======
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
          const Divider(),

          _buildProfileOption(
            icon: Icons.lock,
<<<<<<< HEAD
            title: 'تغيير كلمة المرور'.tr,
=======
            title: 'تغيير كلمة المرور',
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
            onTap: () {
              Get.snackbar('قريباً', 'ميزة تغيير كلمة المرور قيد التطوير');
            },
          ),

          const Divider(),

          _buildProfileOption(
            icon: Icons.notifications,
<<<<<<< HEAD
            title: 'الإشعارات'.tr,
=======
            title: 'الإشعارات',
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
            onTap: () {
              Get.snackbar('قريباً', 'إعدادات الإشعارات قيد التطوير');
            },
          ),

          const Divider(),

          _buildProfileOption(
            icon: Icons.help,
<<<<<<< HEAD
            title: 'المساعدة والدعم'.tr,
=======
            title: 'المساعدة والدعم',
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
            onTap: () {
              Get.snackbar('قريباً', 'صفحة المساعدة قيد التطوير');
            },
          ),
<<<<<<< HEAD
          const Divider(),
          // بدون Obx لمنع الشاشة الحمراء
          _buildProfileOption(
            icon: Get.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            // النص سيتغير تلقائياً: إذا كان دارك سيعرض "فاتح" والعكس
            title: Get.isDarkMode ? 'light_mode'.tr : 'dark_mode'.tr,
            trailing: Switch(
              value: Get.isDarkMode,
              activeColor: AppColors.primary,
              onChanged: (value) {
                // تبديل الثيم
                Get.changeTheme(
                  Get.isDarkMode ? AppThemes.lightTheme : AppThemes.darkTheme,
                );

                // التحديث الإجباري هو السر لحركة السويتش وتغيير النصوص فوراً
                Get.forceAppUpdate();
              },
            ),
            onTap: () {
              Get.changeTheme(
                Get.isDarkMode ? AppThemes.lightTheme : AppThemes.darkTheme,
              );
              Get.forceAppUpdate();
            },
          ),
          const Divider(),

          _buildProfileOption(
            icon: Icons.language,
            title: 'app_language'.tr, // استخدام المفتاح المترجم
            trailing: Text(
              Get.locale?.languageCode == 'ar' ? 'arabic'.tr : 'english'.tr,
              // style: TextStyle(color: AppColors.textPrimaryDark),
            ),
            onTap: () {
              Locale newLocale = Get.locale?.languageCode == 'ar'
                  ? const Locale('en', 'US')
                  : const Locale('ar', 'SA');
              Get.updateLocale(newLocale);
            },
          ),
          const Divider(),

          // ✅ Logout with loading state
          Obx(
            () => _buildProfileOption(
              icon: Icons.logout,
              title: logoutController.isLoggingOut.value
                  ? 'جاري تسجيل الخروج...'.tr
                  : 'تسجيل الخروج'.tr,
              titleColor: Colors.red,
              iconColor: Colors.red,
              onTap: logoutController.isLoggingOut.value
                  ? () {} // Disabled when logging out
                  : logoutController.handleLogout,
              trailing: logoutController.isLoggingOut.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red,
                      ),
                    )
                  : null,
            ),
          ),
=======

          const Divider(),

          // ✅ Logout with loading state
          Obx(() => _buildProfileOption(
                icon: Icons.logout,
                title: logoutController.isLoggingOut.value
                    ? 'جاري تسجيل الخروج...'
                    : 'تسجيل الخروج',
                titleColor: Colors.red,
                iconColor: Colors.red,
                onTap: logoutController.isLoggingOut.value
                    ? () {} // Disabled when logging out
                    : logoutController.handleLogout,
                trailing: logoutController.isLoggingOut.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.red,
                        ),
                      )
                    : null,
              )),
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primary),
<<<<<<< HEAD
      title: Text(title, style: TextStyle(fontSize: 16, color: titleColor)),
=======
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: titleColor,
        ),
      ),
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
