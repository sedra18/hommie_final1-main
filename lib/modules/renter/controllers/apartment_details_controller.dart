import 'package:get/get.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/data/models/apartment/apartment_model.dart';
import 'package:hommie/data/services/apartments_service.dart';
import 'package:hommie/data/models/user/user_permission_controller.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/data/services/bookings_service.dart';
import 'package:hommie/widgets/booking_date_range_picker.dart';

// ═══════════════════════════════════════════════════════════
// APARTMENT DETAILS CONTROLLER - FIXED NULL HANDLING
// ✅ Properly handles nullable response from fetchApartmentDetails
// ✅ Prevents booking own apartments
// ✅ Better error handling
// ═══════════════════════════════════════════════════════════

class ApartmentDetailsController extends GetxController {
  late Rx<ApartmentModel> apartment;
  final RxBool isLoading = false.obs;
  RxBool isFavorite = false.obs;

  final permissions = Get.put(UserPermissionsController());
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();

    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🏠 APARTMENT DETAILS CONTROLLER INITIALIZED');
    print('═══════════════════════════════════════════════════════════');

    final args = Get.arguments;
    print('   Arguments type: ${args.runtimeType}');

    if (args != null) {
      try {
        // Case 1: Arguments has full apartment object
        if (args is Map<String, dynamic> && args.containsKey('apartment')) {
          apartment = (args['apartment'] as ApartmentModel).obs;
          print('   ✅ Using full apartment object');
          print('   Title: ${apartment.value.title}');
          print('   ID: ${apartment.value.id}');
          print('   Owner ID: ${apartment.value.userId}');

          fetchApartmentDetails(apartment.value.id);
        }
        // Case 2: Arguments is a Map with apartmentId only
        else if (args is Map<String, dynamic> &&
            args.containsKey('apartmentId')) {
          final apartmentId = args['apartmentId'] as int;
          print('   Received apartment ID: $apartmentId');

          apartment = ApartmentModel(
            id: apartmentId,
            title: 'Loading...',
            governorate: '',
            city: '',
            mainImage: '',
            pricePerDay: 0,
            roomsCount: 0,
            apartmentSize: 0,
            avgRating: 0,
          ).obs;

          fetchApartmentDetails(apartmentId);
        }
        // Case 3: Arguments is direct ApartmentModel
        else if (args is ApartmentModel) {
          apartment = args.obs;
          print('   Received apartment object: ${apartment.value.title}');
          print('   ID: ${apartment.value.id}');
          print('   Owner ID: ${apartment.value.userId}');

          fetchApartmentDetails(apartment.value.id);
        }
        // Case 4: Invalid arguments
        else {
          print('❌ Invalid arguments format');
          print('═══════════════════════════════════════════════════════════');

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.back();
            Get.snackbar(
              "Error",
              "Invalid apartment data",
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          });
          return;
        }

        print('   User Can Book: ${permissions.canBook}');
        print('──────────────────────────────────────────────────────────');
      } catch (e) {
        print('❌ Error processing arguments: $e');
        print('═══════════════════════════════════════════════════════════');

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.back();
          Get.snackbar(
            "Error",
            "Failed to load apartment: $e",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        });
      }
    } else {
      print('❌ No arguments provided');
      print('═══════════════════════════════════════════════════════════');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        Get.snackbar(
          "Error",
          "Apartment details not found",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
    }
  }

  // ═══════════════════════════════════════════════════════════
  // FETCH APARTMENT DETAILS - FIXED NULL HANDLING
  // ✅ Properly checks if detailsJson is null before using it
  // ═══════════════════════════════════════════════════════════

  void fetchApartmentDetails(int apartmentId) async {
    try {
      isLoading.value = true;

      print('📡 Fetching apartment details for ID: $apartmentId');

      // ✅ Fetch details (might be null)
      final detailsJson = await ApartmentsService.fetchApartmentDetails(
        apartmentId,
      );
      
      // ✅ CHECK IF NULL BEFORE USING
      if (detailsJson != null) {
        apartment.value.updateFromDetailsJson(detailsJson);
        apartment.refresh();
        
        isFavorite.value = apartment.value.isFavorite ?? false;

        print('✅ Apartment details loaded successfully');
        print('   Main Image: ${apartment.value.mainImage}');
        print('   Images: ${apartment.value.imageUrls.length}');
      } else {
        print('⚠️  Details returned null - using cached data');
        
        // If we have some data already, show it
        if (apartment.value.title != 'Loading...') {
          print('   Using cached apartment data');
        } else {
          // No data at all
          throw Exception('Could not fetch apartment details');
        }
      }
      
    } catch (e) {
      print('❌ Error fetching details: $e');

      // If we have partial data, show it
      if (apartment.value.title != 'Loading...') {
        print('⚠️ Server error, but showing cached data');
        
        Get.snackbar(
          "Notice",
          "Could not fetch latest details, showing cached data.",
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        // No data at all - show error
        Get.snackbar(
          "Error",
          "Unable to load apartment details.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
 
  // ═══════════════════════════════════════════════════════════
  // TOGGLE FAVORITE
  // ═══════════════════════════════════════════════════════════

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;

    print('❤️  [Favorite] Toggled: ${isFavorite.value ? "Added" : "Removed"}');
    print('   Apartment: ${apartment.value.title}');

    Get.snackbar(
      "Favorite",
      isFavorite.value
          ? "${apartment.value.title} added to favorites."
          : "${apartment.value.title} removed from favorites.",
      backgroundColor: isFavorite.value ? Colors.orange : Colors.grey,
      colorText: Colors.white,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BOOK APARTMENT
  // ═══════════════════════════════════════════════════════════
  
  void bookApartment() {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🏠 BOOK APARTMENT CALLED');
    print('   Apartment: ${apartment.value.title}');
    print('   ID: ${apartment.value.id}');
    print('   Owner ID: ${apartment.value.userId}');
    print('──────────────────────────────────────────────────────────');
    
    final currentUserId = box.read('user_id') as int?;
    print('   Current User ID: $currentUserId');

    // Check if user is trying to book their own apartment
    if (apartment.value.userId != null &&
        currentUserId != null &&
        apartment.value.userId == currentUserId) {
      print('❌ Cannot book own apartment');
      print('═══════════════════════════════════════════════════════════');

      Get.snackbar(
        "❌ Not Allowed",
        "You cannot book your own apartment.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.block, color: Colors.white),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Check permission
    if (!permissions.checkPermission(
      'book',
      showMessage: true,
      apartmentOwnerId: apartment.value.userId,
    )) {
      print('❌ Booking denied');
      print('═══════════════════════════════════════════════════════════');
      return;
    }

    print('✅ Permission granted - Opening booking dialog');
    print('═══════════════════════════════════════════════════════════');

    _showBookingDialog();
  }

  // ═══════════════════════════════════════════════════════════
  // SHOW BOOKING DIALOG
  // ═══════════════════════════════════════════════════════════
  
  void _showBookingDialog() {
    DateTime? selectedStartDate;
    DateTime? selectedEndDate;
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(20),
        title: Column(
          children: [
            Icon(
              Icons.calendar_month,
              color: AppColors.primary,
              size: 50,
            ),
            const SizedBox(height: 12),
            Text(
              'Book ${apartment.value.title}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '\$${apartment.value.pricePerDay} per day',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BookingDateRangePicker(
                    onDateRangeSelected: (start, end) {
                      setState(() {
                        selectedStartDate = start;
                        selectedEndDate = end;
                      });
                    },
                    initialStartDate: selectedStartDate,
                    initialEndDate: selectedEndDate,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  if (selectedStartDate != null && selectedEndDate != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Days:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${selectedEndDate!.difference(selectedStartDate!).inDays} days',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Price:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${apartment.value.pricePerDay * selectedEndDate!.difference(selectedStartDate!).inDays}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: selectedStartDate == null || selectedEndDate == null
                ? null
                : () {
                    _confirmBooking(selectedStartDate!, selectedEndDate!);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Confirm Booking',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CONFIRM BOOKING
  // ═══════════════════════════════════════════════════════════
   
  void _confirmBooking(DateTime startDate, DateTime endDate) async {
    Get.back(); // Close dialog
    
    final days = endDate.difference(startDate).inDays;
    final totalPrice = apartment.value.pricePerDay * days;
    
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📝 PROCESSING BOOKING');
    print('   Apartment ID: ${apartment.value.id}');
    print('   Start: ${_formatDateForAPI(startDate)}');
    print('   End: ${_formatDateForAPI(endDate)}');
    print('   Days: $days');
    print('   Total: \$$totalPrice');
    print('──────────────────────────────────────────────────────────');
    
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    
    try {
      final bookingService = Get.put(BookingService());
      final result = await bookingService.createBooking(
        apartmentId: apartment.value.id,
        startDate: _formatDateForAPI(startDate),
        endDate: _formatDateForAPI(endDate),
        paymentMethod: 'cash',
      );
      
      Get.back(); // Close loading
      
      if (result['success'] == true) {
        print('✅ Booking successful');
        print('═══════════════════════════════════════════════════════════');
        
        Get.snackbar(
          "✅ Booking Confirmed",
          "Your booking for ${apartment.value.title} has been confirmed!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 4),
        );
      } else {
        print('❌ Booking failed: ${result['error']}');
        print('═══════════════════════════════════════════════════════════');
        
        Get.snackbar(
          "❌ Booking Failed",
          result['error'] ?? "Failed to create booking.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
          duration: const Duration(seconds: 3),
        );
      }
      
    } catch (e) {
      Get.back(); // Close loading
      
      print('❌ Booking failed: $e');
      print('═══════════════════════════════════════════════════════════');
      
      Get.snackbar(
        "❌ Booking Failed",
        "Failed to create booking. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // FORMAT DATE FOR API
  // ═══════════════════════════════════════════════════════════
  
  String _formatDateForAPI(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ═══════════════════════════════════════════════════════════
  // GETTERS
  // ═══════════════════════════════════════════════════════════

  bool get canBook {
    final currentUserId = box.read('user_id') as int?;

    // Can't book own apartment
    if (apartment.value.userId != null &&
        currentUserId != null &&
        apartment.value.userId == currentUserId) {
      return false;
    }

    return permissions.canBook;
  }

  bool get isPending => permissions.isPending;

  bool get isOwnApartment {
    final currentUserId = box.read('user_id') as int?;
    return apartment.value.userId != null &&
        currentUserId != null &&
        apartment.value.userId == currentUserId;
  }
}