import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/models/user/user_permission_controller.dart';
import 'package:hommie/modules/renter/controllers/apartment_details_controller.dart';
import 'package:hommie/data/services/apartments_service.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/modules/shared/controllers/booking_dialog_controller.dart';
import 'package:hommie/widgets/rating_stars_widget.dart';

class ApartmentDetailsScreen extends StatelessWidget {
  ApartmentDetailsScreen({super.key});
  
  final permissions = Get.put(UserPermissionsController());
  
  // ✅ Track current carousel page
  final RxInt currentCarouselIndex = 0.obs;

  Widget _buildDetailIcon(IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ApartmentDetailsController controller = Get.put(ApartmentDetailsController());

    return Obx(() {
      final apartment = controller.apartment.value; 
      
      if (controller.isLoading.value && apartment.description == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
        );
      }

      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        
        bottomNavigationBar: Obx(() {
          if (permissions.isOwner) {
            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                      color: AppColors.backgroundLight
                    ),
                    child: IconButton(
                      icon: Icon(
                        controller.isFavorite.value ? Icons.favorite : Icons.favorite_border,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      onPressed: controller.toggleFavorite,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                      child: const Text(
                        'Contact Owner',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final canBook = permissions.canBook;
          final isPending = permissions.isPending;
          final isRenter = permissions.isRenter;

          if (!isRenter) {
            return const SizedBox.shrink();
          }

          return Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isPending)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange, width: 2),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.hourglass_empty,
                            color: Colors.orange,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'حسابك في انتظار الموافقة. الحجز معطل.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                          color: AppColors.backgroundLight
                        ),
                        child: IconButton(
                          icon: Icon(
                            controller.isFavorite.value ? Icons.favorite : Icons.favorite_border,
                            color: AppColors.primary,
                            size: 28,
                          ),
                          onPressed: controller.toggleFavorite,
                        ),
                      ),
                      const SizedBox(width: 10),

                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            side: const BorderSide(color: AppColors.primary),
                          ),
                          child: const Text(
                            'Contact Owner',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 10),

                      SizedBox(
                        width: 60,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: canBook
                              ? () {
                                  print('');
                                  print('═══════════════════════════════════════════════════════════');
                                  print('🏠 BOOK NOW PRESSED');
                                  print('   Apartment: ${apartment.title}');
                                  print('   Can Book: $canBook');
                                  print('──────────────────────────────────────────────────────────');
                                  
                                  if (permissions.checkPermission('book', showMessage: true)) {
                                    print('✅ Permission granted - Proceeding to booking');
                                   showBookingDialog(apartmentId: apartment.id);
                                  } else {
                                    
                                    print('❌ Booking denied - User not approved');
                                  }
                                  print('═══════════════════════════════════════════════════════════');
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canBook
                                ? AppColors.primary
                                : Colors.grey[400],
                            foregroundColor: canBook 
                                ? AppColors.backgroundLight 
                                : Colors.grey[600],
                            disabledBackgroundColor: Colors.grey[400],
                            disabledForegroundColor: Colors.grey[600],
                            padding: const EdgeInsets.all(0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: canBook ? 2 : 0,
                          ),
                          child: Icon(
                            canBook ? Icons.add : Icons.lock,
                            color: canBook 
                                ? AppColors.backgroundLight 
                                : Colors.grey[600],
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        
        body: CustomScrollView(
          slivers: [
            // ═══════════════════════════════════════════════════════════
            // ✅ FIXED CAROUSEL SLIDER WITH DOTS INDICATOR
            // ═══════════════════════════════════════════════════════════
            SliverAppBar(
              expandedHeight: 300, 
              pinned: true,
              backgroundColor: AppColors.primary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.backgroundLight),
                onPressed: () => Get.back(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                background: apartment.imageUrls.isNotEmpty
                    ? Stack(
                        children: [
                          // ✅ CAROUSEL SLIDER
                          CarouselSlider(
                            options: CarouselOptions(
                              height: 300,
                              viewportFraction: 1.0,
                              enlargeCenterPage: false,
                              autoPlay: true,                    // ✅ Auto play
                              autoPlayInterval: const Duration(seconds: 4),
                              autoPlayAnimationDuration: const Duration(milliseconds: 800),
                              autoPlayCurve: Curves.fastOutSlowIn,
                              pauseAutoPlayOnTouch: true,
                              enableInfiniteScroll: apartment.imageUrls.length > 1,
                              onPageChanged: (index, reason) {
                                currentCarouselIndex.value = index;
                              },
                            ),
                            items: apartment.imageUrls.map((imageUrl) {
                              final url = ApartmentsService.getCleanImageUrl(imageUrl);
                              return Builder(
                                builder: (BuildContext context) {
                                  return GestureDetector(
                                    onTap: () {
                                      // ✅ Optional: Zoom image on tap
                                      showDialog(
                                        context: context,
                                        builder: (context) => Dialog(
                                          backgroundColor: Colors.transparent,
                                          child: Stack(
                                            children: [
                                              Center(
                                                child: InteractiveViewer(
                                                  child: Image.network(
                                                    url,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 20,
                                                right: 20,
                                                child: IconButton(
                                                  icon: const Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 30,
                                                  ),
                                                  onPressed: () => Navigator.pop(context),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                      ),
                                      child: Image.network(
                                        url, 
                                        fit: BoxFit.cover,
                                        width: MediaQuery.of(context).size.width,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              color: AppColors.primary,
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                      loadingProgress.expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) =>
                                            Container(
                                              width: MediaQuery.of(context).size.width,
                                              color: AppColors.textSecondaryLight.withOpacity(0.2),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.broken_image, 
                                                  color: AppColors.backgroundLight, 
                                                  size: 80
                                                ),
                                              ),
                                            ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                          
                          // ✅ DOTS INDICATOR
                          if (apartment.imageUrls.length > 1)
                            Positioned(
                              bottom: 20,
                              left: 0,
                              right: 0,
                              child: Obx(() => Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: apartment.imageUrls.asMap().entries.map((entry) {
                                  return Container(
                                    width: currentCarouselIndex.value == entry.key ? 12 : 8,
                                    height: 8,
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: currentCarouselIndex.value == entry.key
                                          ? AppColors.primary
                                          : Colors.white.withOpacity(0.5),
                                    ),
                                  );
                                }).toList(),
                              )),
                            ),
                          
                          // ✅ IMAGE COUNTER (optional)
                          if (apartment.imageUrls.length > 1)
                            Positioned(
                              top: 20,
                              right: 20,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Obx(() => Text(
                                  '${currentCarouselIndex.value + 1}/${apartment.imageUrls.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                              ),
                            ),
                        ],
                      )
                    : const Center(
                        child: Icon(
                          Icons.image_not_supported, 
                          size: 80, 
                          color: AppColors.backgroundLight
                        ),
                      ),
              ),
            ),
            
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        apartment.title, 
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.primary),
                          const SizedBox(width: 5),
                          Text('${apartment.governorate}, ${apartment.city}',
                              style: const TextStyle(
                                  fontSize: 16, color: AppColors.textSecondaryLight)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Price per Day: \$${apartment.pricePerDay.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const SizedBox(height: 10),
                      RatingStarsWidget(rating: apartment.avgRating),
                      const SizedBox(height: 15),
                      if (apartment.ownerName != null) ...[
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Icon(Icons.person),
                            ),
                            const SizedBox(width: 10),
                            Text('Posted by: ${apartment.ownerName}',
                                style: const TextStyle(
                                    fontSize: 16, color: AppColors.textPrimaryLight)),
                          ],
                        ),
                        const SizedBox(height: 15),
                      ],
                      const Text(
                        'Key Details',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildDetailIcon(Icons.meeting_room_sharp, 'Rooms',
                              apartment.roomsCount.toString()),
                          _buildDetailIcon(Icons.square_foot, 'Area',
                              '${apartment.apartmentSize} m²'),
                          _buildDetailIcon(Icons.attach_money, 'Price/Day',
                              '\$${apartment.pricePerDay.toStringAsFixed(0)}'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Description',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        apartment.description ?? 'No description available for this apartment.',
                        style: const TextStyle(
                            fontSize: 16, color: AppColors.textSecondaryLight, height: 1.5),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      );
    });
  }
}