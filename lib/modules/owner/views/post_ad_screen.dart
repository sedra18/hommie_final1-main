import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/modules/owner/controllers/post_ad_controller.dart';
import 'package:hommie/modules/owner/views/apartment_card_owner.dart';
import 'package:hommie/modules/owner/views/apartment_form_view.dart';
import 'package:hommie/widgets/pending_approval_widget.dart';
import 'package:hommie/data/services/approval_status_service.dart';
import 'package:hommie/data/models/apartment/apartment_model.dart';

// ═══════════════════════════════════════════════════════════
// OWNER POST AD SCREEN - FIXED
// Shows only owner's apartments with edit/delete
// ═══════════════════════════════════════════════════════════

class PostAdScreen extends StatefulWidget {
  const PostAdScreen({super.key});

  @override
  State<PostAdScreen> createState() => _PostAdScreenState();
}

class _PostAdScreenState extends State<PostAdScreen>
    with AutomaticKeepAliveClientMixin {
  final controller = Get.put(PostAdController());
  final approvalService = Get.find<ApprovalStatusService>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Apartments"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchMyApartments(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        // Check approval status
        if (!approvalService.isApproved.value) {
          return PendingApprovalWidget(
            onRefresh: () => approvalService.manualRefresh(),
          );
        }

        // Approved - show normal interface
        return _buildApprovedContent();
      }),
    );
  }

  Widget _buildApprovedContent() {
    return Column(
      children: [
        // Add Apartment Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to add apartment form
                Get.offAll(ApartmentFormView(isEdit: true));
              },
              icon: const Icon(Icons.add_home, size: 24),
              label: const Text(
                'Add New Apartment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ),

        // Divider
        const Divider(height: 1),

        // My Apartments List
        Expanded(
          child: Obx(() {
            // Show loading
            if (controller.isLoading.value) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text('Loading your apartments...'),
                  ],
                ),
              );
            }

            final apartments = controller.myApartments;

            // Empty state
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
                        'No Apartments Yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Click "Add New Apartment" to post your first listing',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Get.offAll(ApartmentFormView(isEdit: true));
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Apartment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Apartments list
            return RefreshIndicator(
              onRefresh: controller.fetchMyApartments,
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Text(
                          '${apartments.length} ${apartments.length == 1 ? 'Apartment' : 'Apartments'}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Colors.green.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Active',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Apartments
                  ...apartments.map((apartment) {
                    return ApartmentCardOwnerPostAd(
                      apartment: apartment,
                      onEdit: () {
                        print('✏️ Edit apartment: ${apartment.title}');
                        // TODO: Navigate to edit screen
                        Get.snackbar(
                          'Edit',
                          'Editing: ${apartment.title}',
                          backgroundColor: Colors.blue,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      onDelete: () => _confirmDelete(apartment),
                    );
                  }).toList(),

                  const SizedBox(height: 80), // Bottom padding
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CONFIRM DELETE DIALOG
  // ═══════════════════════════════════════════════════════════

  void _confirmDelete(ApartmentModel apartment) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            const Text('Delete Apartment'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this apartment?',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.apartment, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      apartment.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('❌ Delete cancelled');
              Get.back();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              print('✅ Delete confirmed for apartment: ${apartment.title}');
              Get.back(); // Close dialog

              // Show loading
              Get.dialog(
                const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Deleting apartment...'),
                        ],
                      ),
                    ),
                  ),
                ),
                barrierDismissible: false,
              );

              try {
                // ✅ Pass int, not String
                final success = await controller.deleteApartment(apartment.id);

                Get.back(); // Close loading

                if (success) {
                  // Success handled by controller
                  print('✅ Delete successful');
                } else {
                  // Error handled by controller
                  print('❌ Delete failed');
                }
              } catch (e) {
                Get.back(); // Close loading

                print('❌ Delete exception: $e');

                Get.snackbar(
                  'Error',
                  'Failed to delete apartment: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  icon: const Icon(Icons.error, color: Colors.white),
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 3),
                );
              }
            },
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
