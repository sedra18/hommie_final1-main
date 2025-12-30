import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/models/apartment/apartment_model.dart';
import 'package:hommie/data/repositories/apartment_repository.dart';
import 'package:hommie/data/services/approval_status_service.dart';
import 'package:hommie/data/services/token_storage_service.dart';

// ═══════════════════════════════════════════════════════════
// OWNER HOME CONTROLLER - WITH AUTO-REFRESH
// Automatically refreshes apartments when approval status changes
// ═══════════════════════════════════════════════════════════

class OwnerHomeController extends GetxController {
  final _apartmentRepo = Get.find<ApartmentRepository>();
  final _approvalService = Get.find<ApprovalStatusService>();
  final _tokenService = Get.find<TokenStorageService>();

  // Observables
  final apartments = <ApartmentModel>[].obs;
  final isLoading = false.obs;
  final selectedGovernorate = ''.obs;
  final searchQuery = ''.obs;

  // User ID (cached)
  int? _currentUserId;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
    _setupApprovalListener(); // ✅ Listen for approval changes
  }

  // ═══════════════════════════════════════════════════════════
  // SETUP APPROVAL LISTENER
  // Automatically refresh apartments when approval status changes
  // ═══════════════════════════════════════════════════════════
  
  void _setupApprovalListener() {
    // ✅ Watch for approval status changes
    ever(_approvalService.isApproved, (isApproved) {
      print('🔔 [OWNER] Approval status changed to: $isApproved');
      if (isApproved) {
        print('✅ [OWNER] User approved! Refreshing apartments...');
        fetchApartments();
      }
    });
  }

  // ═══════════════════════════════════════════════════════════
  // INITIALIZE CONTROLLER
  // ═══════════════════════════════════════════════════════════
  
  Future<void> _initializeController() async {
    await _loadCurrentUserId();
    await _approvalService.checkApprovalStatus();
    await fetchApartments();
  }

  // ═══════════════════════════════════════════════════════════
  // LOAD CURRENT USER ID
  // ═══════════════════════════════════════════════════════════
  
  Future<void> _loadCurrentUserId() async {
    _currentUserId = await _tokenService.getUserId();
    print('✅ [OWNER] Current User ID: $_currentUserId');
  }

  // ═══════════════════════════════════════════════════════════
  // FETCH APARTMENTS
  // ═══════════════════════════════════════════════════════════
  
  Future<void> fetchApartments() async {
    try {
      isLoading.value = true;
      print('📥 [OWNER] Fetching apartments...');
      
      final result = await _apartmentRepo.getAllApartments();
      apartments.value = result;
      
      print('✅ [OWNER] Loaded ${apartments.length} apartments');
      print('   - My apartments: ${myApartments.length}');
      print('   - Other apartments: ${otherApartments.length}');
      
      // ✅ Force UI update
      apartments.refresh();
      
    } catch (e) {
      print('❌ [OWNER] Error loading apartments: $e');
      Get.snackbar(
        'Error',
        'Failed to load apartments. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // DELETE APARTMENT
  // ═══════════════════════════════════════════════════════════
  
  Future<void> deleteApartment(int apartmentId) async {
    try {
      print('🗑️ [OWNER] Deleting apartment ID: $apartmentId');

      // Call API to delete
      final success = await _apartmentRepo.deleteApartment(apartmentId);

      if (success) {
        // Remove from local list
        apartments.removeWhere((apt) => apt.id == apartmentId);
        apartments.refresh();

        Get.snackbar(
          'Success',
          'Apartment deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF22C55E),
          colorText: const Color(0xFFFFFFFF),
          icon: const Icon(
            Icons.check_circle,
            color: Color(0xFFFFFFFF),
          ),
        );

        print('✅ [OWNER] Apartment deleted successfully');
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete apartment. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: const Color(0xFFFFFFFF),
        );
        print('❌ [OWNER] Failed to delete apartment');
      }
    } catch (e) {
      print('❌ [OWNER] Error deleting apartment: $e');
      Get.snackbar(
        'Error',
        'An error occurred while deleting the apartment.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: const Color(0xFFFFFFFF),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // GET ALL APARTMENTS
  // Returns all apartments (for "All" tab or general viewing)
  // ═══════════════════════════════════════════════════════════
  
  List<ApartmentModel> get allApartments {
    return apartments;
  }

  // ═══════════════════════════════════════════════════════════
  // GET MY APARTMENTS
  // Filter apartments that belong to current user
  // ═══════════════════════════════════════════════════════════
  
  List<ApartmentModel> get myApartments {
    if (_currentUserId == null) return [];
    
    return apartments
        .where((apt) => apt.belongsToUser(_currentUserId))
        .toList();
  }

  // ═══════════════════════════════════════════════════════════
  // GET OTHER APARTMENTS (not owned by current user)
  // Used in home screen to show other owners' apartments
  // ═══════════════════════════════════════════════════════════
  
  List<ApartmentModel> get otherApartments {
    if (_currentUserId == null) return apartments;
    
    return apartments
        .where((apt) => !apt.belongsToUser(_currentUserId))
        .toList();
  }

  // ═══════════════════════════════════════════════════════════
  // CHECK IF APARTMENT IS MINE
  // ═══════════════════════════════════════════════════════════
  
  bool isMyApartment(ApartmentModel apartment) {
    if (_currentUserId == null) return false;
    return apartment.belongsToUser(_currentUserId);
  }

  // ═══════════════════════════════════════════════════════════
  // REFRESH
  // Called by pull-to-refresh and manual refresh button
  // ═══════════════════════════════════════════════════════════
  
  Future<void> refresh() async {
    print('🔄 [OWNER] Manual refresh triggered...');
    
    // ✅ Check approval status first
    await _approvalService.checkApprovalStatus();
    
    // ✅ Then refresh apartments
    await fetchApartments();
    
    print('✅ [OWNER] Refresh complete!');
  }

  // ═══════════════════════════════════════════════════════════
  // CAN ADD APARTMENT
  // ═══════════════════════════════════════════════════════════
  
  bool canAddApartment() {
    if (!_approvalService.isApproved.value) {
      if (_approvalService.isPending) {
        Get.snackbar(
          'Approval Pending',
          'Your owner account is pending approval. You cannot add apartments until approved.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
          backgroundColor: const Color(0xFFF59E0B),
          colorText: const Color(0xFFFFFFFF),
          icon: const Icon(
            Icons.schedule,
            color: Color(0xFFFFFFFF),
          ),
        );
      } else if (_approvalService.isRejected) {
        _approvalService.showRejectionMessage();
      }
      return false;
    }
    return true;
  }

  // ═══════════════════════════════════════════════════════════
  // CAN ACCESS FAVORITES
  // ═══════════════════════════════════════════════════════════
  
  bool canAccessFavorites() {
    if (!_approvalService.isApproved.value) {
      if (_approvalService.isPending) {
        _approvalService.showPendingApprovalMessage();
      } else if (_approvalService.isRejected) {
        _approvalService.showRejectionMessage();
      }
      return false;
    }
    return true;
  }

  // ═══════════════════════════════════════════════════════════
  // CAN ACCESS CHAT
  // ═══════════════════════════════════════════════════════════
  
  bool canAccessChat() {
    if (!_approvalService.isApproved.value) {
      if (_approvalService.isPending) {
        _approvalService.showPendingApprovalMessage();
      } else if (_approvalService.isRejected) {
        _approvalService.showRejectionMessage();
      }
      return false;
    }
    return true;
  }

  // ═══════════════════════════════════════════════════════════
  // CAN ACCESS PENDING REQUESTS
  // ═══════════════════════════════════════════════════════════
  
  bool canAccessPendingRequests() {
    if (!_approvalService.isApproved.value) {
      if (_approvalService.isPending) {
        _approvalService.showPendingApprovalMessage();
      } else if (_approvalService.isRejected) {
        _approvalService.showRejectionMessage();
      }
      return false;
    }
    return true;
  }

  // ═══════════════════════════════════════════════════════════
  // FILTER BY GOVERNORATE AND SEARCH
  // ═══════════════════════════════════════════════════════════
  
  List<ApartmentModel> get filteredApartments {
    if (selectedGovernorate.value.isEmpty && searchQuery.value.isEmpty) {
      return apartments;
    }

    return apartments.where((apartment) {
      final matchesGovernorate = selectedGovernorate.value.isEmpty ||
          apartment.governorate
              .toLowerCase()
              .contains(selectedGovernorate.value.toLowerCase());

      final matchesSearch = searchQuery.value.isEmpty ||
          apartment.title
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()) ||
          apartment.city
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase());

      return matchesGovernorate && matchesSearch;
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════
  // SEARCH APARTMENTS
  // ═══════════════════════════════════════════════════════════
  
  void searchApartments(String query) {
    searchQuery.value = query;
  }

  // ═══════════════════════════════════════════════════════════
  // FILTER BY GOVERNORATE
  // ═══════════════════════════════════════════════════════════
  
  void filterByGovernorate(String governorate) {
    selectedGovernorate.value = governorate;
  }

  // ═══════════════════════════════════════════════════════════
  // CLEAR FILTERS
  // ═══════════════════════════════════════════════════════════
  
  void clearFilters() {
    selectedGovernorate.value = '';
    searchQuery.value = '';
  }

  @override
  void onClose() {
    // Clean up
    super.onClose();
  }
}