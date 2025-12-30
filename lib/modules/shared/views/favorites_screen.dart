import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/widgets/pending_approval_widget.dart';
import 'package:hommie/data/services/approval_status_service.dart';

// ═══════════════════════════════════════════════════════════
// OWNER FAVORITES SCREEN - WITH APPROVAL CHECK
// ═══════════════════════════════════════════════════════════

class FavoritesScreen extends StatelessWidget {
<<<<<<< HEAD
  FavoritesScreen({super.key});
=======
   FavoritesScreen({super.key});
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54

  @override
  Widget build(BuildContext context) {
    final approvalService = Get.find<ApprovalStatusService>();
<<<<<<< HEAD

=======
    
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
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
<<<<<<< HEAD

=======
        
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
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
<<<<<<< HEAD
            Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'لا توجد مفضلات',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
=======
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
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
            ),
            const SizedBox(height: 8),
            const Text(
              'يمكنك إضافة شقق إلى المفضلة للوصول إليها بسهولة',
<<<<<<< HEAD
              style: TextStyle(fontSize: 14),
=======
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
