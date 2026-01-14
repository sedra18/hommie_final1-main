// ═══════════════════════════════════════════════════════════
// FIXED APARTMENT CARD HOME - WITH DEBUGGING
// ✅ Better error handling for images
// ✅ Shows actual image URL for debugging
// ✅ Fallback to placeholder if image fails
// ═══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/models/apartment/apartment_model.dart';
import 'package:hommie/modules/renter/views/apartment_details_screen.dart';
import 'package:hommie/app/utils/app_colors.dart';

class ApartmentCardHome extends StatelessWidget {
  final ApartmentModel apartment;
  final VoidCallback? onFavoriteToggle;
  final bool showFavoriteButton;

  const ApartmentCardHome({
    super.key,
    required this.apartment,
    this.onFavoriteToggle,
    this.showFavoriteButton = true,
  });

  void _navigateToDetails() {
    print('🏠 Navigating to: ${apartment.title}');
    
    Get.to(
      () => ApartmentDetailsScreen(),
      arguments: {
        'apartmentId': apartment.id,
        'apartment': apartment,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // ✅ DEBUG: Print image URL
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🏠 RENDERING APARTMENT CARD: ${apartment.title}');
    print('   Main Image URL: ${apartment.mainImage}');
    print('   Image URLs Count: ${apartment.imageUrls.length}');
    if (apartment.imageUrls.isNotEmpty) {
      print('   First Image URL: ${apartment.imageUrls.first}');
    }
    print('═══════════════════════════════════════════════════════════');
    
    return GestureDetector(
      onTap: _navigateToDetails,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2438) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Favorite Button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: _buildImage(context),
                ),
                
                // Favorite Button
                if (showFavoriteButton && onFavoriteToggle != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
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
                          size: 20,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    apartment.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${apartment.city}, ${apartment.governorate}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Rating and Price
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 18,
                        color: Colors.amber[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        apartment.avgRating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      
                      // Price
                      Text(
                        '\$${apartment.pricePerDay.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF3A7AFE),
                        ),
                      ),
                      Text(
                        '/night',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.grey[600],
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
  // BUILD IMAGE WITH BETTER ERROR HANDLING
  // ═══════════════════════════════════════════════════════════

  Widget _buildImage(BuildContext context) {
    // Check if mainImage exists
    if (apartment.mainImage.isEmpty) {
      print('⚠️  ${apartment.title}: No main image URL');
      return _buildPlaceholder('No image URL');
    }

    print('📸 Loading image: ${apartment.mainImage}');

    return Image.network(
     '${apartment.mainImage}',
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          print('✅ Image loaded successfully: ${apartment.title}');
          return child;
        }
        
        // Show loading progress
        final progress = loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded / 
              loadingProgress.expectedTotalBytes!
            : null;
        
        return Container(
          height: 200,
          color: Colors.grey[300],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  progress != null 
                      ? '${(progress * 100).toInt()}%' 
                      : 'Loading...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('');
        print('❌ IMAGE LOAD ERROR for ${apartment.title}');
        print('   URL: ${apartment.mainImage}');
        print('   Error: $error');
        print('   Stack trace: ${stackTrace.toString().split('\n').first}');
        print('');
        
        return _buildPlaceholder('Image failed to load');
      },
    );
  }

  Widget _buildPlaceholder(String message) {
    return Container(
      height: 200,
      color: Colors.grey[300],
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.image_not_supported, 
            size: 50, 
            color: Colors.grey
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          // ✅ DEBUG: Show the URL that failed
          if (apartment.mainImage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                apartment.mainImage,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}