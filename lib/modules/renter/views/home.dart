import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/modules/renter/controllers/home_controller.dart';
import 'package:hommie/widgets/apartment_card.dart';

// ═══════════════════════════════════════════════════════════
// RENTER HOME SCREEN
// Shows all available apartments
// Renter can book any apartment
// ═══════════════════════════════════════════════════════════

class RenterHomeScreen extends StatelessWidget {
  const RenterHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RenterHomeController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Apartments'),
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
        if (controller.apartments.isEmpty) {
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
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${controller.apartments.length} Apartments',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                            'Available',
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
              
              // Apartments List
              ...controller.apartments.map((apartment) {
                return ApartmentCard(
                  apartment: apartment,
                  isMyApartment: false,  // ← Renter: never owns apartments
                  showOwnerActions: false,  // ← Renter: no edit/delete
                  onTap: () {
                    // Navigate to apartment details/booking
                    print('📱 Navigate to details: ${apartment.title}');
                    
                    // TODO: Navigate to apartment details screen
                    // Get.to(() => ApartmentDetailsScreen(apartment: apartment));
                    
                    Get.snackbar(
                      'Apartment Details',
                      'Viewing "${apartment.title}"',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      duration: const Duration(seconds: 2),
                    );
                  },
                );
              }).toList(),
              
              const SizedBox(height: 80),
            ],
          ),
        );
      }),
    );
  }
}