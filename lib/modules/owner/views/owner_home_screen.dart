import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/modules/owner/controllers/owner_home_controller.dart';
import 'package:hommie/widgets/apartment_card.dart';

// ═══════════════════════════════════════════════════════════
// OWNER HOME SCREEN
// Shows my apartments + other apartments
// ═══════════════════════════════════════════════════════════

class OwnerHomeScreen extends StatelessWidget {
  const OwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OwnerHomeController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Apartments'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refresh(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      
      body: Obx(() {
        // Loading state
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading apartments...'),
              ],
            ),
          );
        }
        
        // Empty state
        if (controller.allApartments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.home_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No apartments available',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pull down to refresh',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }
        
        // Apartments list
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              // ═══════════════════════════════════════════════════════
              // MY APARTMENTS SECTION
              // ═══════════════════════════════════════════════════════
              
              if (controller.myApartments.isNotEmpty) ...[
                const SizedBox(height: 16),
                
                // Section Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.home,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Apartments',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              '${controller.myApartments.length} apartment${controller.myApartments.length > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // My Apartments List
                ...controller.myApartments.map((apartment) {
                  return ApartmentCard(
                    apartment: apartment,
                    isMyApartment: true,  // ← This is MY apartment
                    showOwnerActions: true,  // ← Show edit/delete
                    onTap: () {
                      // Show message: cannot book own apartment
                      Get.snackbar(
                        'My Apartment',
                        'You cannot book your own apartment',
                        backgroundColor: Colors.orange,
                        colorText: Colors.white,
                        icon: const Icon(Icons.info_outline, color: Colors.white),
                        duration: const Duration(seconds: 2),
                      );
                    },
                  );
                }).toList(),
                
                // Divider
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    thickness: 2,
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
              
              // ═══════════════════════════════════════════════════════
              // OTHER APARTMENTS SECTION
              // ═══════════════════════════════════════════════════════
              
              if (controller.otherApartments.isNotEmpty) ...[
                const SizedBox(height: 16),
                
                // Section Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.apartment,
                          color: Colors.green,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Available Apartments',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${controller.otherApartments.length} apartment${controller.otherApartments.length > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Other Apartments List
                ...controller.otherApartments.map((apartment) {
                  return ApartmentCard(
                    apartment: apartment,
                    isMyApartment: false,  // ← NOT my apartment
                    showOwnerActions: false,  // ← No edit/delete
                    onTap: () {
                      // Navigate to apartment details/booking
                      print('📱 Navigate to details: ${apartment.title}');
                      
                      // TODO: Navigate to apartment details screen
                      // Get.to(() => ApartmentDetailsScreen(apartment: apartment));
                      
                      Get.snackbar(
                        'Available',
                        'You can book "${apartment.title}"',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        icon: const Icon(Icons.check_circle, color: Colors.white),
                        duration: const Duration(seconds: 2),
                      );
                    },
                  );
                }).toList(),
              ],
              
              // ═══════════════════════════════════════════════════════
              // ONLY MY APARTMENTS (no others available)
              // ═══════════════════════════════════════════════════════
              
              if (controller.myApartments.isNotEmpty && 
                  controller.otherApartments.isEmpty) ...[
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No other apartments available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }
}