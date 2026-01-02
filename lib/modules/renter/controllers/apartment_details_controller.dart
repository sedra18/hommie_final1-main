import 'package:get/get.dart';
import 'package:hommie/data/models/apartment/apartment_model.dart';
import 'package:hommie/data/services/apartments_service.dart';
import 'package:hommie/data/models/user/user_permission_controller.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

// ═══════════════════════════════════════════════════════════
// APARTMENT DETAILS CONTROLLER - COMPLETE FIXED VERSION
// ✅ Handles all argument types properly
// ✅ Prevents booking own apartments
// ✅ Better error handling
// ✅ Proper navigation scheduling
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
    print('   Arguments: $args');

    // ✅ FIXED: Handle all argument types properly
    if (args != null) {
      try {
        // Case 1: Arguments has full apartment object
        if (args is Map<String, dynamic> && args.containsKey('apartment')) {
          apartment = (args['apartment'] as ApartmentModel).obs;
          print('   ✅ Using full apartment object');
          print('   Title: ${apartment.value.title}');
          print('   ID: ${apartment.value.id}');
          print('   Owner ID: ${apartment.value.userId}');

          // Still fetch fresh details
          fetchApartmentDetails(apartment.value.id);
        }
        // Case 2: Arguments is a Map with apartmentId only
        else if (args is Map<String, dynamic> &&
            args.containsKey('apartmentId')) {
          final apartmentId = args['apartmentId'] as int;
          print('   Received apartment ID: $apartmentId');
          print('   Creating temporary apartment model...');

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
          print(
            '   Expected: Map with "apartment" or "apartmentId", or ApartmentModel',
          );
          print('═══════════════════════════════════════════════════════════');

          //  FIXED: Schedule the navigation for after build completes
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

        // ✅ FIXED: Schedule the navigation for after build completes
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

      // ✅ FIXED: Schedule the navigation for after build completes
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
  // FETCH APARTMENT DETAILS
  // ✅ Uses correct /api/apartments/:id endpoint
  // ═══════════════════════════════════════════════════════════

  void fetchApartmentDetails(int apartmentId) async {
    try {
      isLoading.value = true;

      print('📡 Fetching apartment details for ID: $apartmentId');

      final detailsJson = await ApartmentsService.fetchApartmentDetails(
        apartmentId,
      );
      apartment.value.updateFromDetailsJson(detailsJson);
      apartment.refresh();
      isFavorite.value = apartment.value.isFavorite ?? false;

      print('✅ Apartment details loaded successfully');
      print('   Title: ${apartment.value.title}');
      print('   Price: \$${apartment.value.pricePerDay}');
      print('   Owner ID: ${apartment.value.userId}');
    } catch (e) {
      print('❌ Error fetching apartment details: $e');

      String errorMsg = 'Unable to fetch apartment details.';

      if (e.toString().contains('404')) {
        errorMsg = 'Apartment not found. It may have been deleted.';
      } else if (e.toString().contains('401') || e.toString().contains('403')) {
        errorMsg = 'You don\'t have permission to view this apartment.';
      } else if (e.toString().contains('500')) {
        errorMsg = 'Server error. Please try again later.';
      }

      Get.snackbar(
        "Error",
        errorMsg,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

      // If we don't have the full apartment object, go back
      if (apartment.value.title == 'Loading...') {
        Future.delayed(const Duration(seconds: 2), () {
          if (Get.isDialogOpen != true && Get.isSnackbarOpen != true) {
            Get.back();
          }
        });
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

    print('');
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
  // BOOK APARTMENT - FIXED
  // ✅ Prevents booking own apartments
  // ✅ Better permission checking with apartment owner ID
  // ═══════════════════════════════════════════════════════════

  void bookApartment() {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🏠 BOOK APARTMENT CALLED');
    print('   Apartment: ${apartment.value.title}');
    print('   ID: ${apartment.value.id}');
    print('   Owner ID: ${apartment.value.userId}');
    print('   Price: \$${apartment.value.pricePerDay}/day');
    print('──────────────────────────────────────────────────────────');
    
    // ✅ Get current user ID
    final currentUserId = box.read('user_id') as int?;
    print('   Current User ID: $currentUserId');

    // ✅ Check if user is trying to book their own apartment
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

    // ✅ Check general permission (approval status)
    if (!permissions.checkPermission(
      'book',
      showMessage: true,
      apartmentOwnerId: apartment.value.userId,
    )) {
      print('❌ Booking denied - Not approved or other permission issue');
      print('   Is Approved: ${permissions.isApproved.value}');
      print('   Role: ${permissions.userRole.value}');
      print('═══════════════════════════════════════════════════════════');
      return;
    }

    print('✅ Permission granted - Proceeding to booking');
    print('═══════════════════════════════════════════════════════════');

    // TODO: Navigate to booking form screen
    // Get.to(() => BookingFormScreen(apartment: apartment.value));
//openDialog();
    Get.snackbar(
      "Booking",
      "Booking started for ${apartment.value.title}",
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // GETTERS
  // ═══════════════════════════════════════════════════════════

  bool get canBook {
    // ✅ Check if user can book THIS SPECIFIC apartment
    final currentUserId = box.read('user_id') as int?;

    // Can't book own apartment
    if (apartment.value.userId != null &&
        currentUserId != null &&
        apartment.value.userId == currentUserId) {
      return false;
    }

    // Otherwise, check general permission
    return permissions.canBook;
  }

  bool get isPending => permissions.isPending;

  bool get isOwnApartment {
    final currentUserId = box.read('user_id') as int?;
    return apartment.value.userId != null &&
        currentUserId != null &&
        apartment.value.userId == currentUserId;
  }

  // Future openDialog() =>
  //     showDialog(context: context, builder: (context) => AlertDialog(title: Text('Choose the booking details'),));
}
