import 'package:get/get.dart';
import 'package:hommie/data/models/apartment/apartment_model.dart';
import 'package:hommie/data/services/apartments_service.dart';
import 'package:flutter/material.dart';
import 'package:hommie/modules/renter/views/apartment_details_screen.dart';

class HomeController extends GetxController {
  var apartments = <ApartmentModel>[].obs;
  var isLoading = false.obs;
  var currentIndex = 0.obs;
  PageController pageController = PageController();

  @override
  void onInit() {
    super.onInit();
    fetchApartments();
  }

  void changeTabIndex(int index) {
    currentIndex.value = index;
    pageController.jumpToPage(index);
  }

  void goToDetails(ApartmentModel apartment) {
    Get.to(() =>  ApartmentDetailsScreen(), arguments: apartment);
  }

  Future<void> fetchApartments() async {
    try {
      if (apartments.isEmpty) {
        isLoading(true);
      }
      final result = await ApartmentsService.fetchApartments();
      apartments.assignAll(result);
    } catch (e) {
      print("Error fetching apartments: $e");
    } finally {
      isLoading(false);
    }
  }

  void goToApartmentDetails(ApartmentModel apartment) {
    Get.to(() => ApartmentDetailsScreen(), arguments: apartment);
  }
}
