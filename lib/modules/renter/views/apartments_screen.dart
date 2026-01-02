import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/modules/renter/controllers/renter_home_controller.dart';
import 'package:hommie/data/models/apartment/apartment_model.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/data/services/apartments_service.dart';

// ═══════════════════════════════════════════════════════════
// RENTER APARTMENTS SCREEN - FIXED
// Uses custom grid item (not ApartmentCard)
// ═══════════════════════════════════════════════════════════

class ApartmentsScreen extends StatelessWidget {
  const ApartmentsScreen({super.key});

  Widget _buildApartmentGridItem(
    ApartmentModel apartment,
    Function(ApartmentModel) onTap,
  ) {
    final image = ApartmentsService.getCleanImageUrl(apartment.mainImage);
    
    return GestureDetector(
      onTap: () => onTap(apartment),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimaryLight.withOpacity(0.08),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: image.isEmpty
                    ? const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                      )
                    : Image.network(
                        image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
              ),
            ),
            
            // Info Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      apartment.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 5),
                    
                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.textSecondaryLight,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            apartment.city,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Price
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        '\$${apartment.pricePerDay.toStringAsFixed(0)} / Day',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIXED: Use correct controller name
    final controller = Get.find<RenterHomeController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Obx(() {
        // Loading state
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        // Empty state
        if (controller.apartments.isEmpty) {
          return const Center(
            child: Text(
              'No apartments found.',
              style: TextStyle(
                color: AppColors.textSecondaryLight,
                fontSize: 16,
              ),
            ),
          );
        }

        // Apartments Grid
        return RefreshIndicator(
          onRefresh: controller.fetchApartments,
          color: AppColors.primary,
          child: GridView.builder(
            padding: const EdgeInsets.all(15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.65,
            ),
            itemCount: controller.apartments.length,
            itemBuilder: (context, index) {
              final apartment = controller.apartments[index];
              
              // ✅ FIXED: Pass function properly
              return _buildApartmentGridItem(
                apartment,
                controller.goToDetails,
              );
            },
          ),
        );
      }),
    );
  }
}