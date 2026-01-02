import 'package:get/get.dart';
import 'package:hommie/data/models/apartment/apartment_model.dart';
import 'package:hommie/data/repositories/apartment_repository.dart';
import 'package:hommie/data/services/approval_status_service.dart';
import 'package:hommie/data/services/booking_card_service.dart';

// ═══════════════════════════════════════════════════════════
// RENTER HOME CONTROLLER - FIXED
// ✅ Uses browseAllApartments() to see ALL apartments
// ✅ Automatically refreshes when approval status changes
// ═══════════════════════════════════════════════════════════

class RenterHomeController extends GetxController {
  final _apartmentRepo = Get.put(ApartmentRepository());
  final _approvalService = Get.put(ApprovalStatusService());
  
  // Make BookingCardService optional since it might not be initialized yet
  BookingCardService? get _bookingService {
    try {
      return Get.put(BookingCardService());
    } catch (e) {
      return null;
    }
  }

  // Observables
  final apartments = <ApartmentModel>[].obs;
  final isLoading = false.obs;
  final selectedGovernorate = ''.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
    _setupApprovalListener();
  }

  // ═══════════════════════════════════════════════════════════
  // SETUP APPROVAL LISTENER
  // Automatically refresh apartments when approval status changes
  // ═══════════════════════════════════════════════════════════
  
  void _setupApprovalListener() {
    ever(_approvalService.isApproved, (isApproved) {
      print('🔔 Approval status changed to: $isApproved');
      if (isApproved) {
        print('✅ User approved! Refreshing apartments...');
        fetchApartments();
      }
    });
  }

  // ═══════════════════════════════════════════════════════════
  // INITIALIZE CONTROLLER
  // ═══════════════════════════════════════════════════════════
  
  Future<void> _initializeController() async {
    await _approvalService.checkApprovalStatus();
    await fetchApartments();
  }

  // ═══════════════════════════════════════════════════════════
  // FETCH APARTMENTS
  // ✅ FIXED: Uses browseAllApartments() to see ALL apartments
  // ═══════════════════════════════════════════════════════════
  
  Future<void> fetchApartments() async {
    try {
      isLoading.value = true;
      print('📥 [RENTER] Fetching all apartments...');
      
      // ✅ CHANGED: Use browseAllApartments() instead of getAllApartments()
      final result = await _apartmentRepo.browseAllApartments();
      apartments.value = result;
      
      print('✅ [RENTER] Loaded ${apartments.length} apartments');
      
      // Force UI update
      apartments.refresh();
      
    } catch (e) {
      print('❌ [RENTER] Error loading apartments: $e');
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
  // GO TO DETAILS
  // Navigate to apartment details screen
  // ═══════════════════════════════════════════════════════════
  
  void goToDetails(ApartmentModel apartment) {
    print('📍 Navigating to details for: ${apartment.title}');
    
    Get.toNamed(
      '/apartment_details',
      arguments: apartment,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // REFRESH
  // Called by pull-to-refresh and manual refresh
  // ═══════════════════════════════════════════════════════════
  
  Future<void> refresh() async {
    print('🔄 [RENTER] Manual refresh triggered...');
    
    await _approvalService.checkApprovalStatus();
    await fetchApartments();
    
    print('✅ [RENTER] Refresh complete!');
  }

  // ═══════════════════════════════════════════════════════════
  // CAN ACCESS FAVORITES
  // ═══════════════════════════════════════════════════════════
  
  bool canAccessFavorites() {
    if (!_approvalService.isApproved.value) {
      if (_approvalService.isPending.value) {
        _approvalService.showPendingApprovalMessage();
      } else if (_approvalService.isRejected.value) {
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
      if (_approvalService.isPending.value) {
        _approvalService.showPendingApprovalMessage();
      } else if (_approvalService.isRejected.value) {
        _approvalService.showRejectionMessage();
      }
      return false;
    }
    return true;
  }

  // ═══════════════════════════════════════════════════════════
  // CAN BOOK APARTMENT
  // ═══════════════════════════════════════════════════════════
  
  Future<bool> canBookApartment(ApartmentModel apartment) async {
    if (_bookingService == null) {
      return _approvalService.canPerformAction();
    }
    return await _bookingService!.canBookApartment(apartment);
  }

  // ═══════════════════════════════════════════════════════════
  // TOGGLE FAVORITE
  // ═══════════════════════════════════════════════════════════
  
  Future<void> toggleFavorite(ApartmentModel apartment) async {
    if (!canAccessFavorites()) {
      return;
    }

    try {
      final newFavoriteStatus = !(apartment.isFavorite ?? false);
      
      final index = apartments.indexWhere((a) => a.id == apartment.id);
      if (index != -1) {
        apartments[index].isFavorite = newFavoriteStatus;
        apartments.refresh();
      }

      // TODO: Call API to update favorite status
      
      Get.snackbar(
        newFavoriteStatus ? 'Added to Favorites' : 'Removed from Favorites',
        apartment.title,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('❌ Error toggling favorite: $e');
      final index = apartments.indexWhere((a) => a.id == apartment.id);
      if (index != -1) {
        apartments[index].isFavorite = !(apartment.isFavorite ?? false);
        apartments.refresh();
      }
    }
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
    super.onClose();
  }
}