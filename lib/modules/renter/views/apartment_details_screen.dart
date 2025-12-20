import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/modules/renter/controllers/apartment_details_controller.dart';
import 'package:hommie/data/services/apartments_service.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/widgets/rating_stars_widget.dart';

class ApartmentDetailsScreen extends StatelessWidget {
  const ApartmentDetailsScreen({super.key});

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
    final ApartmentDetailsController controller = Get.find<ApartmentDetailsController>();

    return Obx(() {
      final apartment = controller.apartment.value; 
      
      if (controller.isLoading.value && apartment.description == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
        );
      }

      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Obx(() => Container(
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
              )),
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
                  onPressed: controller.bookApartment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Icon(
                    Icons.add, 
                    color: AppColors.backgroundLight,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        body: CustomScrollView(
          slivers: [
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
                    ? SizedBox(
                        height: 300,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: apartment.imageUrls.length,
                          itemBuilder: (context, index) {
                            final url = ApartmentsService.getCleanImageUrl(apartment.imageUrls[index]);
                            return Image.network(
                              url, 
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    color: AppColors.textSecondaryLight.withOpacity(0.2),
                                    child: const Center(child: Icon(Icons.broken_image, color: AppColors.backgroundLight, size: 80)),
                                  ),
                            );
                          },
                        ),
                      )
                    : const Center(child: Icon(Icons.image_not_supported, size: 80, color: AppColors.backgroundLight)),
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
                              child: Icon(Icons.person),
                              backgroundColor: AppColors.primary,
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