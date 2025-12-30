import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/widgets/pending_approval_widget.dart';
import 'package:hommie/data/services/approval_status_service.dart';

// ═══════════════════════════════════════════════════════════
// OWNER FAVORITES SCREEN - WITH APPROVAL CHECK
// ═══════════════════════════════════════════════════════════

class FavoritesScreen extends StatelessWidget {
   const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final approvalService = Get.find<ApprovalStatusService>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
        backgroundColor: AppColors.primary,
      ),
      body: Obx(() {
        // ✅ Check approval status
        if (!approvalService.isApproved.value) {
          return PendingApprovalWidget(
            onRefresh: () => approvalService.manualRefresh(),
          );
        }
        
        // ✅ Approved - show favorites
        return _buildFavoritesContent();
      }),
    );
  }

  Widget _buildFavoritesContent() {
    // TODO: Implement actual favorites functionality
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد مفضلات',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'يمكنك إضافة شقق إلى المفضلة للوصول إليها بسهولة',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}