import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/modules/owner/controllers/post_ad_controller.dart';
import 'package:hommie/widgets/apartment_card.dart';
import 'package:hommie/widgets/pending_approval_widget.dart';
import 'package:hommie/data/services/approval_status_service.dart';
import 'package:hommie/data/models/apartment/apartment_model.dart';  // ✅ Import correct model

// ═══════════════════════════════════════════════════════════
// OWNER POST AD SCREEN - FULLY FIXED
// Uses ApartmentModel (not OwnerApartmentModel)
// ═══════════════════════════════════════════════════════════

class PostAdScreen extends StatefulWidget {
  const PostAdScreen({super.key});

  @override
  State<PostAdScreen> createState() => _PostAdScreenState();
}

class _PostAdScreenState extends State<PostAdScreen> 
    with AutomaticKeepAliveClientMixin {
  
  final controller = Get.find<PostAdController>();
  final approvalService = Get.find<ApprovalStatusService>();
  
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Ad"),
        backgroundColor: AppColors.primary,
      ),
      body: Obx(() {
        // ✅ Check approval status
        if (!approvalService.isApproved.value) {
          return PendingApprovalWidget(
            onRefresh: () => approvalService.manualRefresh(),
          );
        }
        
        // ✅ Approved - show normal interface
        return _buildApprovedContent();
      }),
    );
  }

  Widget _buildApprovedContent() {
    return Column(
      children: [
        // Action Buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Add a Flat Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.onAddApartmentPressed,
                  icon: const Icon(Icons.add_home, size: 24),
                  label: const Text(
                    'Add a Flat',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Pending Requests Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                      'قريباً',
                      'ميزة الطلبات المعلقة قيد التطوير',
                      backgroundColor: Colors.blue,
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(Icons.pending_actions, size: 24),
                  label: const Text(
                    'Pending Requests',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Divider
        const Divider(height: 1),
        
        // My Apartments List
        Expanded(
          child: Obx(() {
            // ✅ FIXED: Use ApartmentModel type
            final List<ApartmentModel> apartments = controller.myApartments;
            
            if (apartments.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.apartment,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'لا توجد شقق',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'انقر على "Add a Flat" لإضافة شقتك الأولى',
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
            
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: apartments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                // ✅ FIXED: ApartmentModel type
                final ApartmentModel apartment = apartments[index];
                
                return GestureDetector(
                  onLongPress: () => _showApartmentMenu(context, apartment),
                  child: ApartmentCard(
                    apartment: apartment,
                    isMyApartment: true,  // ✅ This is MY apartment
                    showOwnerActions: false,  // Using long-press menu
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  // ✅ Show menu on long press
  void _showApartmentMenu(BuildContext context, ApartmentModel apartment) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.home, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        apartment.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Edit Option
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('تعديل الشقة'),
                onTap: () {
                  Get.back();
                  Get.snackbar(
                    'تعديل',
                    'تعديل الشقة: ${apartment.title}',
                    backgroundColor: Colors.blue,
                    colorText: Colors.white,
                  );
                },
              ),
              
              const Divider(height: 1),
              
              // Delete Option
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('حذف الشقة'),
                onTap: () {
                  Get.back();
                  _confirmDelete(apartment);
                },
              ),
              
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ✅ Confirm delete dialog
  void _confirmDelete(ApartmentModel apartment) {
    Get.dialog(
      AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "${apartment.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              
              // Show loading
              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );
              
              try {
                await controller.deleteApartment(apartment.id.toString());
                Get.back(); // Close loading
                
                Get.snackbar(
                  'تم الحذف',
                  'تم حذف الشقة بنجاح',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  icon: const Icon(Icons.check, color: Colors.white),
                );
              } catch (e) {
                Get.back(); // Close loading
                
                Get.snackbar(
                  'خطأ',
                  'فشل حذف الشقة',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  icon: const Icon(Icons.error, color: Colors.white),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}