import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/models/apartment/apartment_model.dart';
import 'package:hommie/data/repositories/apartment_repository.dart';
import 'package:hommie/data/services/approval_status_service.dart';
import 'package:hommie/modules/renter/views/apartment_details_screen.dart';

// ═══════════════════════════════════════════════════════════
// OWNER HOME CONTROLLER - FIXED
// ✅ Uses browseAllApartments() to see ALL apartments
// ✅ With delete functionality
// ═══════════════════════════════════════════════════════════

class OwnerHomeController extends GetxController {
  final _apartmentRepo = ApartmentRepository();
  final _approvalService = Get.put(ApprovalStatusService());

  final apartments = <ApartmentModel>[].obs;
  final isLoading = false.obs;
  final isApproved = true.obs;

  @override
  void onInit() {
    super.onInit();
    print('✅ [OWNER] OwnerHomeController initialized');

    print('🔍 [OWNER] Checking approval status on init...');
    checkApprovalAndFetch();
  }

  // ═══════════════════════════════════════════════════════════
  // CHECK APPROVAL AND FETCH
  // ═══════════════════════════════════════════════════════════

  Future<void> checkApprovalAndFetch() async {
    await _approvalService.checkApprovalStatus();

    isApproved.value = _approvalService.isApproved.value;

    if (isApproved.value) {
      print('✅ [OWNER] User is approved, fetching apartments...');
      await fetchApartments();
    } else {
      print('⏳ [OWNER] User not approved yet');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // FETCH ALL APARTMENTS
  // ✅ FIXED: Uses browseAllApartments() to see ALL apartments
  // ═══════════════════════════════════════════════════════════

  Future<void> fetchApartments() async {
    try {
      isLoading.value = true;
      print('📥 [OWNER] Fetching all apartments...');

      // ✅ CHANGED: Use browseAllApartments() instead of getAllApartments()
      final fetchedApartments = await _apartmentRepo.browseAllApartments();

      apartments.value = fetchedApartments;

      print('✅ [OWNER] Loaded ${fetchedApartments.length} apartments');
    } catch (e) {
      print('❌ [OWNER] Error fetching apartments: $e');

      Get.snackbar(
        'Error',
        'Failed to load apartments',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // FETCH MY APARTMENTS ONLY
  // ✅ NEW: Method to fetch only apartments owned by current user
  // ═══════════════════════════════════════════════════════════

  Future<void> fetchMyApartments() async {
    try {
      isLoading.value = true;
      print('📥 [OWNER] Fetching MY apartments only...');

      // Uses original getAllApartments() which is filtered by user
      final myApartments = await _apartmentRepo.getAllApartments();

      apartments.value = myApartments;

      print('✅ [OWNER] Loaded ${myApartments.length} of my apartments');
    } catch (e) {
      print('❌ [OWNER] Error fetching my apartments: $e');

      Get.snackbar(
        'Error',
        'Failed to load your apartments',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // DELETE APARTMENT
  // Endpoint: DELETE /api/apartments/{id}
  // ═══════════════════════════════════════════════════════════

  Future<void> deleteApartment(int apartmentId) async {
    try {
      print('🗑️ [OWNER] Deleting apartment ID: $apartmentId');

      final success = await _apartmentRepo.deleteApartment(apartmentId);

      if (success) {
        // Remove from local list
        apartments.removeWhere((apt) => apt.id == apartmentId);

        print('✅ [OWNER] Apartment deleted and removed from list');

        Get.snackbar(
          'Success',
          'Apartment deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      } else {
        print('❌ [OWNER] Failed to delete apartment');

        Get.snackbar(
          'Error',
          'Failed to delete apartment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e) {
      print('❌ [OWNER] Error deleting apartment: $e');

      Get.snackbar(
        'Error',
        'An error occurred while deleting',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // REFRESH
  // ═══════════════════════════════════════════════════════════

  Future<void> refresh() async {
    print('🔄 [OWNER] Refreshing...');
    await fetchApartments();
  }

  // ═══════════════════════════════════════════════════════════
  // NAVIGATE TO APARTMENT DETAILS
  // ═══════════════════════════════════════════════════════════

  void navigateToDetails(ApartmentModel apartment) {
    print('🏠 [OWNER] Navigating to apartment details: ${apartment.title}');
    
    Get.to(
      () => ApartmentDetailsScreen(),
      arguments: {'apartmentId': apartment.id},
    );
  }

  @override
  void onClose() {
    print('👋 [OWNER] OwnerHomeController closed');
    super.onClose();
  }
}