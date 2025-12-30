import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/models/apartment/apartment_model.dart';
import 'package:hommie/data/services/apartments_service.dart';

// ═══════════════════════════════════════════════════════════
// RENTER HOME CONTROLLER - FIXED
// Added goToDetails method
// ═══════════════════════════════════════════════════════════

class RenterHomeController extends GetxController {
  final apartments = <ApartmentModel>[].obs;
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🏘️ RENTER HOME CONTROLLER - INITIALIZING');
    print('═══════════════════════════════════════════════════════════');
    fetchApartments();
  }
  
  // ═══════════════════════════════════════════════════════════
  // FETCH ALL APARTMENTS
  // ═══════════════════════════════════════════════════════════
  
  Future<void> fetchApartments() async {
    if (isLoading.value) {
      print('⚠️  Already loading apartments');
      return;
    }
    
    isLoading.value = true;
    
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📥 LOADING APARTMENTS FOR RENTER');
    print('═══════════════════════════════════════════════════════════');
    
    try {
      final allApartments = await ApartmentsService.fetchApartments();
      apartments.value = allApartments;
      
      print('');
      print('✅ APARTMENTS LOADED:');
      print('   Total apartments: ${apartments.length}');
      print('═══════════════════════════════════════════════════════════');
      
    } catch (e) {
      print('');
      print('❌ ERROR LOADING APARTMENTS');
      print('   Error: $e');
      print('═══════════════════════════════════════════════════════════');
      
      Get.snackbar(
        'Error',
        'Failed to load apartments',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // ═══════════════════════════════════════════════════════════
  // GO TO APARTMENT DETAILS
  // ═══════════════════════════════════════════════════════════
  
  void goToDetails(ApartmentModel apartment) {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📱 NAVIGATING TO APARTMENT DETAILS');
    print('   Apartment: ${apartment.title}');
    print('   ID: ${apartment.id}');
    print('═══════════════════════════════════════════════════════════');
    
    // Navigate to apartment details screen
    Get.toNamed('/apartment-details', arguments: apartment);
    
    // OR if using direct navigation:
    // Get.to(() => ApartmentDetailsScreen(), arguments: apartment);
  }
  
  // ═══════════════════════════════════════════════════════════
  // REFRESH
  // ═══════════════════════════════════════════════════════════
  
  Future<void> refresh() async {
    if (isRefreshing.value) return;
    
    isRefreshing.value = true;
    
    print('');
    print('🔄 REFRESHING APARTMENTS...');
    
    try {
      await fetchApartments();
      print('✅ Refresh complete');
      
    } catch (e) {
      print('❌ Refresh failed: $e');
    } finally {
      isRefreshing.value = false;
    }
  }
  
  @override
  void onClose() {
    print('🏘️ Renter Home Controller closed');
    super.onClose();
  }
}