import 'package:get/get.dart';
import 'package:hommie/data/models/apartment/apartment_model.dart';
import 'package:hommie/data/services/apartments_service.dart';
import 'package:hommie/data/models/user/user_permission_controller.dart';
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════
// UPDATED APARTMENT DETAILS CONTROLLER
// With Approval System Integration
// ═══════════════════════════════════════════════════════════

class ApartmentDetailsController extends GetxController {
  late Rx<ApartmentModel> apartment; 
  final RxBool isLoading = false.obs;
  RxBool isFavorite = false.obs;
  
  // ADD THIS: Permission controller
  final permissions = Get.put(UserPermissionsController());

  @override
  void onInit() {
    super.onInit();
    
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🏠 APARTMENT DETAILS CONTROLLER INITIALIZED');
    print('═══════════════════════════════════════════════════════════');
    
    final args = Get.arguments;
    if (args != null && args is ApartmentModel) {
      apartment = (args).obs;
      
      print('   Apartment: ${apartment.value.title}');
      print('   ID: ${apartment.value.id}');
      print('   User Can Book: ${permissions.canBook}');
      print('──────────────────────────────────────────────────────────');
      
      fetchApartmentDetails(apartment.value.id); 
    } else {
      print('❌ No apartment data in arguments');
      print('══════════════════════════════════════════════════════════');
      
      Get.back();
      Get.snackbar("Error", "Apartment details not found");
    }
  }

  void fetchApartmentDetails(int apartmentId) async {
    try {
      isLoading.value = true;
      
      print('📡 Fetching apartment details for ID: $apartmentId');
      
      final detailsJson = await ApartmentsService.fetchApartmentDetails(apartmentId);
      apartment.value.updateFromDetailsJson(detailsJson);
      apartment.refresh(); 
      isFavorite.value = apartment.value.isFavorite ?? false;

      print('✅ Apartment details loaded successfully');
      print('   Title: ${apartment.value.title}');
      print('   Price: \$${apartment.value.pricePerDay}');

    } catch (e) {
      print('❌ Error fetching apartment details: $e');
      
      Get.snackbar("Error", "Unable to fetch apartment details. $e",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
    
    print('');
    print('❤️  [Favorite] Toggled: ${isFavorite.value ? "Added" : "Removed"}');
    print('   Apartment: ${apartment.value.title}');
    
    Get.snackbar("Favorite", 
        isFavorite.value 
            ? "${apartment.value.title} added to favorites." 
            : "${apartment.value.title} removed from favorites.",
        backgroundColor: isFavorite.value ? Colors.orange : Colors.grey, 
        colorText: Colors.white);
  }

  // ═══════════════════════════════════════════════════════════
  // UPDATED BOOK APARTMENT METHOD WITH PERMISSION CHECK
  // ═══════════════════════════════════════════════════════════
  void bookApartment() {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🏠 BOOK APARTMENT CALLED');
    print('   Apartment: ${apartment.value.title}');
    print('   ID: ${apartment.value.id}');
    print('   Price: \$${apartment.value.pricePerDay}/day');
    print('──────────────────────────────────────────────────────────');

    // CHECK PERMISSION FIRST
    if (!permissions.checkPermission('book', showMessage: true)) {
      print('❌ Booking denied - User not approved');
      print('   Is Approved: ${permissions.isApproved.value}');
      print('   Role: ${permissions.userRole.value}');
      print('   Can Book: ${permissions.canBook}');
      print('═══════════════════════════════════════════════════════════');
      return;
    }

    print('✅ Permission granted - Proceeding to booking');
    print('   User is approved and can book');
    print('═══════════════════════════════════════════════════════════');
    
    // Proceed with booking
    // TODO: Navigate to booking form screen
    // Get.toNamed('/booking-form', arguments: {
    //   'apartment': apartment.value,
    //   'apartmentId': apartment.value.id,
    // });
    
    // For now, show success message
    Get.snackbar(
      "Booking", 
      "Booking started for ${apartment.value.title}",
      backgroundColor: Colors.green, 
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HELPER GETTER FOR UI
  // ═══════════════════════════════════════════════════════════
  
  /// Check if user can book this apartment
  bool get canBook => permissions.canBook;
  
  /// Check if user is pending approval
  bool get isPending => permissions.isPending;
}