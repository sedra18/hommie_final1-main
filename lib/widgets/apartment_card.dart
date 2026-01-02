import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/data/models/apartment/apartment_model.dart';
import 'package:hommie/modules/renter/views/apartment_details_screen.dart';
import 'package:hommie/modules/owner/controllers/owner_home_controller.dart';

// ═══════════════════════════════════════════════════════════
// UNIFIED APARTMENT CARD - WORKS FOR BOTH OWNER & RENTER
// ✅ Shows rating as stars (not numbers)
// ✅ Shows "My Apartment" badge for owner's apartments
// ✅ Shows edit/delete buttons for owner's apartments
// ✅ Single card design for consistency
// ═══════════════════════════════════════════════════════════

class UnifiedApartmentCard extends StatelessWidget {
  final ApartmentModel apartment;
  final bool showOwnerActions;
  final VoidCallback? onFavoriteToggle;

  const UnifiedApartmentCard({
    super.key,
    required this.apartment,
    this.showOwnerActions = false,
    this.onFavoriteToggle,
  });

  // ═══════════════════════════════════════════════════════════
  // CHECK IF THIS IS USER'S OWN APARTMENT
  // ═══════════════════════════════════════════════════════════
  
  bool get isMyApartment {
    final box = GetStorage();
    final currentUserId = box.read('user_id') as int?;
    
    if (currentUserId == null || apartment.userId == null) {
      return false;
    }
    
    return apartment.userId == currentUserId;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        // Blue border for my apartments
        side: isMyApartment 
            ? const BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToDetails(),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════════════════════════════════════════════════
            // IMAGE SECTION WITH BADGES
            // ═══════════════════════════════════════════════════
            
            Stack(
              children: [
                _buildImageSection(),
                
                // "My Apartment" Badge (top-left)
                if (isMyApartment)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.home,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'My Apartment',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Favorite Button (top-right) - Only for renters
                if (!isMyApartment && onFavoriteToggle != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          apartment.isFavorite == true
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: apartment.isFavorite == true
                              ? Colors.red
                              : Colors.grey[700],
                          size: 22,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // ═══════════════════════════════════════════════════
            // CONTENT SECTION
            // ═══════════════════════════════════════════════════
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Owner Actions Row
                  Row(
                    children: [
                      // Title
                      Expanded(
                        child: Text(
                          apartment.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // Edit & Delete buttons (only for my apartments)
                      if (isMyApartment && showOwnerActions) ...[
                        const SizedBox(width: 8),
                        _buildOwnerActions(context),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${apartment.city}, ${apartment.governorate}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // ✅ RATING AS STARS (NOT NUMBERS!)
                  _buildRatingStars(),
                  
                  const SizedBox(height: 12),
                  
                  // Details Row (Rooms + Size)
                  Row(
                    children: [
                      _buildDetailChip(
                        icon: Icons.bed_outlined,
                        label: '${apartment.roomsCount} Rooms',
                      ),
                      const SizedBox(width: 8),
                      _buildDetailChip(
                        icon: Icons.square_foot_outlined,
                        label: '${apartment.apartmentSize.toInt()} m²',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Price and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${apartment.pricePerDay.toInt()}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            ' / night',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      
                      // "Cannot Book" badge (for my apartments)
                      if (isMyApartment)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.orange.shade300,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.block,
                                size: 14,
                                color: Colors.orange.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Cannot Book',
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD RATING STARS - ✅ SHOWS STARS NOT NUMBERS!
  // ═══════════════════════════════════════════════════════════
  
  Widget _buildRatingStars() {
    final rating = apartment.avgRating;
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;
    
    return Row(
      children: [
        // Full stars
        ...List.generate(fullStars, (index) => const Icon(
          Icons.star,
          size: 18,
          color: Colors.amber,
        )),
        
        // Half star
        if (hasHalfStar)
          const Icon(
            Icons.star_half,
            size: 18,
            color: Colors.amber,
          ),
        
        // Empty stars
        ...List.generate(
          5 - fullStars - (hasHalfStar ? 1 : 0),
          (index) => Icon(
            Icons.star_border,
            size: 18,
            color: Colors.grey.shade400,
          ),
        ),
        
        const SizedBox(width: 6),
        
        // Rating number
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // OWNER ACTIONS (Edit & Delete Buttons)
  // ═══════════════════════════════════════════════════════════
  
  Widget _buildOwnerActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit Button
        Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: () => _handleEdit(context),
            icon: const Icon(Icons.edit),
            color: Colors.blue,
            iconSize: 20,
            tooltip: 'Edit',
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            padding: const EdgeInsets.all(8),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Delete Button
        Container(
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: () => _handleDelete(context),
            icon: const Icon(Icons.delete),
            color: Colors.red,
            iconSize: 20,
            tooltip: 'Delete',
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            padding: const EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }

  void _handleEdit(BuildContext context) {
    print('✏️ Edit apartment: ${apartment.title} (ID: ${apartment.id})');
    
    Get.snackbar(
      'Edit',
      'Edit feature coming soon...',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      icon: const Icon(Icons.info, color: Colors.white),
      duration: const Duration(seconds: 2),
    );
  }

  void _handleDelete(BuildContext context) {
    print('🗑️ Delete requested: ${apartment.title} (ID: ${apartment.id})');
    
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Apartment'),
        content: Text(
          'Are you sure you want to delete "${apartment.title}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              print('❌ Delete cancelled');
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              print('✅ Delete confirmed');
              
              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );
              
              try {
                final controller = Get.find<OwnerHomeController>();
                await controller.deleteApartment(apartment.id);
                Get.back();
              } catch (e) {
                Get.back();
                print('❌ Error: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // IMAGE SECTION
  // ═══════════════════════════════════════════════════════════
  
  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: apartment.mainImage.isNotEmpty
          ? Image.network(
              apartment.mainImage,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder(showError: true);
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            )
          : _buildPlaceholder(showError: false),
    );
  }

  Widget _buildPlaceholder({bool showError = false}) {
    return Container(
      height: 200,
      color: showError ? Colors.red.shade50 : Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            showError ? Icons.broken_image : Icons.home,
            size: 64,
            color: showError ? Colors.red.shade300 : Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            showError ? 'Failed to load image' : 'No image',
            style: TextStyle(
              color: showError ? Colors.red.shade600 : Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // DETAIL CHIP
  // ═══════════════════════════════════════════════════════════
  
  Widget _buildDetailChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // NAVIGATE TO DETAILS
  // ═══════════════════════════════════════════════════════════
  
  void _navigateToDetails() {
    print('📍 Navigating to details for: ${apartment.title}');
    
    Get.to(
      () => ApartmentDetailsScreen(),
      arguments: apartment,
    );
  }
}