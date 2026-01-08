import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/modules/shared/controllers/logout_controller.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/data/services/approval_status_service.dart';

// ═══════════════════════════════════════════════════════════
// PROFILE SCREEN - FIXED
// Shows profile content regardless of approval status
// ═══════════════════════════════════════════════════════════

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LogoutController logoutController = Get.put(LogoutController());
    final approvalService = Get.put(ApprovalStatusService());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // ✅ No back button in navbar
      ),
      backgroundColor: AppColors.backgroundLight,
      body: _buildProfileContent(logoutController, approvalService),
    );
  }

  Widget _buildProfileContent(
    LogoutController logoutController,
    ApprovalStatusService approvalService,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Profile Avatar
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Icon(Icons.person, size: 60, color: AppColors.primary),
          ),

          const SizedBox(height: 16),

          // Name
          const Text(
            'UserName',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          // Email
          const Text(
            'owner@example.com',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),

          const SizedBox(height: 24),

          // ✅ Approval Status Badge - Show current status
          Obx(() => _buildApprovalBadge(approvalService)),

          const SizedBox(height: 32),

          // Profile Options
          _buildProfileOption(
            icon: Icons.edit,
            title: 'Edit personal information',
            onTap: () {
              Get.snackbar(
                'Soon',
                'Editing the personal information feature will be soon added',
              );
            },
          ),

          const Divider(),

          _buildProfileOption(
            icon: Icons.lock,
            title: 'Change password',
            onTap: () {
              Get.snackbar(
                'Soon',
                'Editing the password feature will be soon added',
              );
            },
          ),

          const Divider(),

          _buildProfileOption(
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: () {
              Get.snackbar('Soon', 'Informations feature will be soon added');
            },
          ),

          const Divider(),

          _buildProfileOption(
            icon: Icons.help,
            title: 'Help center',
            onTap: () {
              Get.snackbar('Soon', 'Helping center will be added soon');
            },
          ),

          const Divider(),

          // ✅ Check Approval Status button (if pending)
          Obx(() {
            if (!approvalService.isApproved.value) {
              return Column(
                children: [
                  _buildProfileOption(
                    icon: Icons.refresh,
                    title: 'Check Approval Status',
                    titleColor: AppColors.primary,
                    iconColor: AppColors.primary,
                    // ✅ FIX: Use checkApprovalStatus() instead of refreshApprovalStatus()
                    onTap: () => approvalService.checkApprovalStatus(),
                  ),
                  const Divider(),
                ],
              );
            }
            return const SizedBox.shrink();
          }),

          // ✅ Logout with loading state
          Obx(
            () => _buildProfileOption(
              icon: Icons.logout,
              title: logoutController.isLoggingOut.value
                  ? 'Logging out now...'
                  : 'Log out',
              titleColor: AppColors.failure,
              iconColor: AppColors.failure,
              onTap: logoutController.isLoggingOut.value
                  ? () {} // Disabled when logging out
                  : logoutController.handleLogout,
              trailing: logoutController.isLoggingOut.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.failure,
                      ),
                    )
                  : null,
            ),
          ),

          const SizedBox(height: 80), // ✅ Extra padding for navbar
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD APPROVAL BADGE
  // Shows different badge based on approval status
  // ✅ FIXED: Added .value to access RxBool
  // ═══════════════════════════════════════════════════════════

  Widget _buildApprovalBadge(ApprovalStatusService approvalService) {
    if (approvalService.isApproved.value) {
      // Approved - Green badge
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.success, width: 2),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified, color: AppColors.success, size: 20),
            SizedBox(width: 8),
            Text(
              'Verified account',
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else if (approvalService.isPending.value) {
      // ✅ FIX: Added .value to access RxBool
      // Pending - Orange badge
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF59E0B), width: 2),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule, color: Color(0xFFF59E0B), size: 20),
            SizedBox(width: 8),
            Text(
              'Pending approval',
              style: TextStyle(
                color: Color(0xFFF59E0B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else if (approvalService.isRejected.value) {
      // ✅ FIX: Added .value to access RxBool
      // Rejected - Red badge
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.failure, width: 2),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cancel, color: AppColors.failure, size: 20),
            SizedBox(width: 8),
            Text(
              'Account rejected',
              style: TextStyle(
                color: AppColors.failure,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      // Unknown - Grey badge
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey, width: 2),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.help_outline, color: Colors.grey, size: 20),
            SizedBox(width: 8),
            Text(
              'Status unknown',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }
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
