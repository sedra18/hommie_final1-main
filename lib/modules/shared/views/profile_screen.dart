import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/app/utils/app_theme.dart';

import 'package:hommie/modules/shared/controllers/logout_controller.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/modules/shared/controllers/profile_controller.dart';
import 'package:hommie/modules/shared/views/edit_profile_bottom_sheet.dart';
import 'package:hommie/modules/shared/views/favorites_screen.dart';
import 'package:hommie/modules/shared/views/help_support_screen.dart';
import 'package:hommie/modules/shared/views/notification_screen.dart';

import 'package:hommie/widgets/pending_approval_widget.dart';
import 'package:hommie/data/services/approval_status_service.dart';

// ═══════════════════════════════════════════════════════════
// OWNER PROFILE SCREEN - WITH APPROVAL CHECK AND LOGOUT
// ═══════════════════════════════════════════════════════════

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(ProfileController());

    final LogoutController logoutController = Get.put(LogoutController());
    final approvalService = Get.find<ApprovalStatusService>();

    return Scaffold(
      appBar: AppBar(
        title: Text('profile'.tr),
        backgroundColor: AppColors.primary,
      ),

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
          Obx(() {
            final controller = Get.find<ProfileController>();
            final avatarUrl = controller.avatarUrl;

            return CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl) as ImageProvider
                  : null,
              child: avatarUrl == null || avatarUrl.isEmpty
                  ? Icon(Icons.person, size: 60, color: AppColors.primary)
                  : null,
            );
          }),

          const SizedBox(height: 16),

          // Name
          Obx(() {
            final controller = Get.find<ProfileController>();
            return Text(
              controller.fullName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Get.isDarkMode
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            );
          }),
          const SizedBox(height: 8),

          // Email
          Obx(() {
            final controller = Get.find<ProfileController>();
            return Text(
              controller.email,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            );
          }),
          const SizedBox(height: 24),
          // Approval Status Badge - ديناميكي
          Obx(() {
            final controller = Get.find<ProfileController>();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: controller.statusColor.withOpacity(0.1), // ✅ استخدمي _
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: controller.statusColor,
                  width: 2,
                ), // ✅
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    controller.isVerified
                        ? Icons.verified
                        : Icons.hourglass_empty, // ✅
                    color: controller.statusColor, // ✅
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    controller.statusText.tr, // ✅
                    style: TextStyle(
                      color: controller.statusColor, // ✅
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 32),

          // Profile Options
          _buildProfileOption(
            icon: Icons.settings,
            title: 'إعدادات الحساب',
            onTap: () {
              Get.bottomSheet(
                 EditProfileBottomSheet(),
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
              );
            },
          ),
          const Divider(),

          const Divider(),

          _buildProfileOption(
            icon: Icons.notifications,
            title: 'الإشعارات'.tr,
            onTap: () {
              Get.to(() => NotificationsScreen());
            },
          ),

          const Divider(),
          _buildProfileOption(
            icon: Icons.help,
            title: ' عرض الحجوزات'.tr,
            onTap: () {
              Get.snackbar('قريباً', 'إعدادات الإشعارات قيد التطوير');
            },
          ),

          const Divider(),

          // قسم الثيم - أبسط حل
          // قسم الثيم - مع BottomSheet
          ListTile(
            leading: Icon(
              Get.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: AppColors.primary,
            ),
            title: Text(Get.isDarkMode ? 'dark_mode'.tr : 'light_mode'.tr),
            trailing: SizedBox(
              width: 60,
              child: Text(
                Get.isDarkMode ? 'داكن' : 'فاتح',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ),
            onTap: () {
              Get.bottomSheet(
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'اختر المظهر',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // الوضع الفاتح
                      RadioListTile(
                        title: Row(
                          children: [
                            Icon(Icons.light_mode, color: Colors.amber),
                            const SizedBox(width: 10),
                            Text('الوضع الفاتح'),
                          ],
                        ),
                        value: false,
                        groupValue: Get.isDarkMode,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          if (value == false) {
                            GetStorage().write('isDarkMode', false);
                            Get.changeTheme(AppThemes.lightTheme);
                            Get.back();
                            Get.snackbar('تم', 'الوضع الفاتح');
                          }
                        },
                      ),

                      // الوضع الداكن
                      RadioListTile(
                        title: Row(
                          children: [
                            Icon(Icons.dark_mode, color: Colors.blueGrey),
                            const SizedBox(width: 10),
                            Text('الوضع الداكن'),
                          ],
                        ),
                        value: true,
                        groupValue: Get.isDarkMode,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          if (value == true) {
                            GetStorage().write('isDarkMode', true);
                            Get.changeTheme(AppThemes.darkTheme);
                            Get.back();
                            Get.snackbar('تم', 'الوضع الداكن');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(),

          // قسم اللغة - النسخة البسيطة
          // قسم اللغة - مصلح
          ListTile(
            leading: Icon(Icons.language, color: AppColors.primary),
            title: Text('app_language'.tr),
            trailing: SizedBox(
              width: 60,
              child: Text(
                Get.locale?.languageCode == 'ar' ? 'ع' : 'EN',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ),
            onTap: () {
              Get.bottomSheet(
                Container(
                  height: 200, // تحديد ارتفاع BottomSheet
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'اختر اللغة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 20),
                      RadioListTile(
                        title: Text('العربية'),
                        value: 'ar',
                        groupValue: Get.locale?.languageCode,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          Get.updateLocale(const Locale('ar', 'SA'));
                          GetStorage().write('lang', 'ar');
                          Get.back();
                          Get.snackbar('تم', 'العربية');
                        },
                      ),

                      RadioListTile(
                        title: Text('English'),
                        value: 'en',
                        groupValue: Get.locale?.languageCode,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          Get.updateLocale(const Locale('en', 'US'));
                          GetStorage().write('lang', 'en');
                          Get.back();
                          Get.snackbar('Done', 'English');
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(),

          _buildProfileOption(
            icon: Icons.help,
            title: 'المساعدة والدعم'.tr,
            onTap: () {
              Get.to(() =>  HelpSupportScreen());
            },
          ),

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
      title: Text(title, style: TextStyle(fontSize: 16, color: titleColor)),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}