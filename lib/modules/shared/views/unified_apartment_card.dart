import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/data/models/apartment/apartment_model.dart';
import 'package:hommie/data/services/apartments_service.dart';
import 'package:hommie/modules/owner/controllers/post_ad_controller.dart';

// ═══════════════════════════════════════════════════════════
// UNIFIED APARTMENT CARD - FIXED
// ✅ Checks ownership directly without service method
// ✅ Works with userId field (most common)
// ═══════════════════════════════════════════════════════════

class UnifiedApartmentCard extends StatelessWidget {
  final ApartmentModel apartment;
  final VoidCallback? onTap;
  final bool showOwnerActions;

  const UnifiedApartmentCard({
    super.key,
    required this.apartment,
    this.onTap,
    this.showOwnerActions = true,
  });

  // ═══════════════════════════════════════════════════════════
  // CHECK IF THIS IS MY APARTMENT
  // ═══════════════════════════════════════════════════════════
  
  bool _isMyApartment() {
    try {
      final box = GetStorage();
      final currentUserId = box.read('userId');
      
      // Debug
      print('🔍 Checking ownership:');
      print('   Current user ID: $currentUserId');
      print('   Apartment owner ID: ${apartment.userId}');
      
      if (currentUserId == null) {
        print('   ❌ No current user ID');
        return false;
      }
      
      if (apartment.userId == null) {
        print('   ⚠️  Apartment has no userId field');
        return false;
      }
      
      // Compare as integers
      final currentUserIdInt = int.tryParse(currentUserId.toString()) ?? 0;
      final apartmentUserIdInt = apartment.userId ?? 0;
      
      final isOwned = currentUserIdInt == apartmentUserIdInt;
      print('   Result: ${isOwned ? "✅ MY APARTMENT" : "❌ Not mine"}');
      
      return isOwned;
      
    } catch (e) {
      print('❌ Error checking ownership: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMyApartment = _isMyApartment();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isMyApartment 
            ? BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Badge
            Stack(
              children: [
                _buildImageSection(),
                
                // "My Apartment" Badge
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
                            color: Colors.black.withOpacity(0.2),
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
              ],
            ),
            
            // Content Section
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Actions Row
                  Row(
                    children: [
                      // Title
                      Expanded(
                        child: Text(
                          apartment.title ?? 'Untitled',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // Owner Actions (Edit & Delete) - Only for my apartments
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
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${apartment.city ?? ''} - ${apartment.governorate ?? ''}',
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
                  
                  const SizedBox(height: 8),
                  
                  // Description
                  if (apartment.description != null) ...[
                    Text(
                      apartment.description!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Details Row
                  Row(
                    children: [
                      // Rooms
                      if (apartment.roomsCount != null)
                        _buildDetailChip(
                          icon: Icons.bed,
                          label: '${apartment.roomsCount} Rooms',
                        ),
                      
                      const SizedBox(width: 8),
                      
                      // Size
                      if (apartment.apartmentSize != null)
                        _buildDetailChip(
                          icon: Icons.square_foot,
                          label: '${apartment.apartmentSize?.toInt()} m²',
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Price and Booking Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Text(
                        '\$${apartment.pricePerDay?.toInt() ?? 0} / day',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      
                      // "Cannot Book" indicator for my apartments
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
    print('🗑️ Delete requested for: ${apartment.title} (ID: ${apartment.id})');
    
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete "${apartment.title}"?\nThis action cannot be undone.',
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
              
              try {
                final controller = Get.find<PostAdController>();
                await controller.deleteApartment(apartment.id.toString());
              } catch (e) {
                print('❌ Error deleting apartment: $e');
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
    final imageUrl = apartment.mainImage != null
        ? ApartmentsService.getCleanImageUrl(apartment.mainImage!)
        : null;
    
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: imageUrl != null && imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
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
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}