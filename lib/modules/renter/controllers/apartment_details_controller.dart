import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/models/apartment/apartment_model.dart';
import 'package:hommie/data/services/apartments_service.dart';

class ApartmentDetailsController extends GetxController {
  late Rx<ApartmentModel> apartment; 
  final RxBool isLoading = false.obs;
  RxBool isFavorite = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is ApartmentModel) {
      apartment = (args as ApartmentModel).obs;
      fetchApartmentDetails(apartment.value.id); 
    } else {
      Get.back();
      Get.snackbar("Error", "Apartment details not found");
    }
  }

  void fetchApartmentDetails(int apartmentId) async {
    try {
      isLoading.value = true;
      
      final detailsJson = await ApartmentsService.fetchApartmentDetails(apartmentId);
      apartment.value.updateFromDetailsJson(detailsJson);
      apartment.refresh(); 
      isFavorite.value = apartment.value.isFavorite ?? false;

    } catch (e) {
      Get.snackbar("Error", "Unable to fetch apartment details. $e",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
    Get.snackbar("Favorite", 
        isFavorite.value ? "${apartment.value.title} added to favorites." : "${apartment.value.title} removed from favorites.",
        backgroundColor: isFavorite.value ? Colors.orange : Colors.grey, colorText: Colors.white);
  }

  void bookApartment() {
    Get.snackbar("Booking", "Booking started for ${apartment.value.title}",
        backgroundColor: Colors.green, colorText: Colors.white);
  }
}