import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/models/apartment/apartment_model.dart';
import 'package:hommie/data/repositories/apartment_repository.dart';
import 'package:hommie/data/services/approval_status_service.dart';
import 'package:hommie/modules/renter/views/apartment_details_screen.dart';

// ═══════════════════════════════════════════════════════════
// OWNER HOME CONTROLLER - ENHANCED WITH FILTERS
// ✅ Uses browseAllApartments() to see ALL apartments
// ✅ With delete functionality
// ✅ Filter support (same as Renter)
// ═══════════════════════════════════════════════════════════

class OwnerHomeController extends GetxController {
  final _apartmentRepo = ApartmentRepository();
  final _approvalService = Get.put(ApprovalStatusService());

  final apartments = <ApartmentModel>[].obs;
  final isLoading = false.obs;
  final isApproved = true.obs;
  
  // ✅ NEW: Filter observables
  final appliedFilters = Rx<Map<String, dynamic>?>(null);
  final searchQuery = ''.obs;

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
  // APPLY FILTERS
  // ✅ NEW: Apply filter criteria
  // ═══════════════════════════════════════════════════════════

  void applyFilters(Map<String, dynamic>? filters) {
    appliedFilters.value = filters;
    print('🔍 [OWNER] Filters applied: $filters');
  }

  // ═══════════════════════════════════════════════════════════
  // SET SEARCH QUERY
  // ✅ NEW: Update search query
  // ═══════════════════════════════════════════════════════════

  void setSearchQuery(String query) {
    searchQuery.value = query;
    print('🔍 [OWNER] Search query: $query');
  }

  // ═══════════════════════════════════════════════════════════
  // CLEAR ALL FILTERS
  // ✅ NEW: Clear both filters and search
  // ═══════════════════════════════════════════════════════════

  void clearAllFilters() {
    appliedFilters.value = null;
    searchQuery.value = '';
    print('🗑️ [OWNER] All filters and search cleared');
  }

  // ═══════════════════════════════════════════════════════════
  // GET ACTIVE FILTERS COUNT
  // ✅ NEW: Count active filters
  // ═══════════════════════════════════════════════════════════

  int getActiveFiltersCount() {
    if (appliedFilters.value == null) return 0;

    int count = 0;
    final filters = appliedFilters.value!;

    if (filters['city'] != null && (filters['city'] as String).isNotEmpty) {
      count++;
    }
    if (filters['governorate'] != null && 
        (filters['governorate'] as String).isNotEmpty) {
      count++;
    }
    if (filters['address'] != null && 
        (filters['address'] as String).isNotEmpty) {
      count++;
    }
    if (filters['minPrice'] != null || filters['maxPrice'] != null) {
      count++;
    }
    if (filters['minRooms'] != null || filters['maxRooms'] != null) {
      count++;
    }
    if (filters['minSize'] != null || filters['maxSize'] != null) {
      count++;
    }

    return count;
  }

  // ═══════════════════════════════════════════════════════════
  // FILTER APARTMENTS
  // ✅ NEW: Apply search and filter logic
  // ═══════════════════════════════════════════════════════════

  List<ApartmentModel> filterApartments(List<ApartmentModel> apartmentsList) {
    return apartmentsList.where((apartment) {
      // Search filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        final title = apartment.title.toLowerCase();
        final city = apartment.city.toLowerCase();
        final governorate = apartment.governorate.toLowerCase();

        final matchesSearch = title.contains(query) ||
            city.contains(query) ||
            governorate.contains(query);

        if (!matchesSearch) return false;
      }

      // Location filters
      if (appliedFilters.value != null) {
        final filters = appliedFilters.value!;

        // City filter
        if (filters['city'] != null && 
            (filters['city'] as String).isNotEmpty) {
          final filterCity = (filters['city'] as String).toLowerCase();
          if (!apartment.city.toLowerCase().contains(filterCity)) {
            return false;
          }
        }

        // Governorate filter
        if (filters['governorate'] != null &&
            (filters['governorate'] as String).isNotEmpty) {
          final filterGov = (filters['governorate'] as String).toLowerCase();
          if (!apartment.governorate.toLowerCase().contains(filterGov)) {
            return false;
          }
        }

        // Address filter
        if (filters['address'] != null &&
            (filters['address'] as String).isNotEmpty) {
          final filterAddress = (filters['address'] as String).toLowerCase();
          final aptAddress = apartment.address?.toLowerCase() ?? '';
          if (!aptAddress.contains(filterAddress)) {
            return false;
          }
        }

        // Price filter
        final minPrice = filters['minPrice'] as double?;
        final maxPrice = filters['maxPrice'] as double?;

        if (minPrice != null && apartment.pricePerDay < minPrice) {
          return false;
        }
        if (maxPrice != null && apartment.pricePerDay > maxPrice) {
          return false;
        }

        // Rooms filter
        final minRooms = filters['minRooms'] as int?;
        final maxRooms = filters['maxRooms'] as int?;

        if (minRooms != null && apartment.roomsCount < minRooms) {
          return false;
        }
        if (maxRooms != null && apartment.roomsCount > maxRooms) {
          return false;
        }

        // Size filter
        final minSize = filters['minSize'] as double?;
        final maxSize = filters['maxSize'] as double?;

        if (minSize != null && apartment.apartmentSize < minSize) {
          return false;
        }
        if (maxSize != null && apartment.apartmentSize > maxSize) {
          return false;
        }
      }

      return true;
    }).toList();
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