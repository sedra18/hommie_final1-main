import 'package:get/get.dart';
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════
// FILTER CONTROLLER
// Manages filter state for apartment search
// Works for both Owner and Renter programs
// ═══════════════════════════════════════════════════════════

class FilterController extends GetxController {
  // Text editing controllers for input fields
  final cityController = TextEditingController();
  final governorateController = TextEditingController();
  final addressController = TextEditingController();
  
  final minPriceController = TextEditingController();
  final maxPriceController = TextEditingController();
  
  final minRoomsController = TextEditingController();
  final maxRoomsController = TextEditingController();
  
  final minSizeController = TextEditingController();
  final maxSizeController = TextEditingController();
  
  // Observables for reactive UI
  var city = ''.obs;
  var governorate = ''.obs;
  var address = ''.obs;
  
  var minPrice = ''.obs;
  var maxPrice = ''.obs;
  
  var minRooms = ''.obs;
  var maxRooms = ''.obs;
  
  var minSize = ''.obs;
  var maxSize = ''.obs;
  
  // Track if filters are active
  var hasActiveFilters = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Listen to text field changes
    cityController.addListener(() => city.value = cityController.text);
    governorateController.addListener(() => governorate.value = governorateController.text);
    addressController.addListener(() => address.value = addressController.text);
    
    minPriceController.addListener(() => minPrice.value = minPriceController.text);
    maxPriceController.addListener(() => maxPrice.value = maxPriceController.text);
    
    minRoomsController.addListener(() => minRooms.value = minRoomsController.text);
    maxRoomsController.addListener(() => maxRooms.value = maxRoomsController.text);
    
    minSizeController.addListener(() => minSize.value = minSizeController.text);
    maxSizeController.addListener(() => maxSize.value = maxSizeController.text);
    
    print('✅ FilterController initialized');
  }

  // ═══════════════════════════════════════════════════════════
  // VALIDATE FILTERS
  // ═══════════════════════════════════════════════════════════
  
  bool validateFilters() {
    // Validate price range
    if (minPrice.value.isNotEmpty && maxPrice.value.isNotEmpty) {
      final min = double.tryParse(minPrice.value);
      final max = double.tryParse(maxPrice.value);
      
      if (min != null && max != null && min > max) {
        Get.snackbar(
          'Invalid Range',
          'Minimum price cannot be greater than maximum price',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: const Color(0xFFFFFFFF),
        );
        return false;
      }
    }
    
    // Validate rooms range
    if (minRooms.value.isNotEmpty && maxRooms.value.isNotEmpty) {
      final min = int.tryParse(minRooms.value);
      final max = int.tryParse(maxRooms.value);
      
      if (min != null && max != null && min > max) {
        Get.snackbar(
          'Invalid Range',
          'Minimum rooms cannot be greater than maximum rooms',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: const Color(0xFFFFFFFF),
        );
        return false;
      }
    }
    
    // Validate size range
    if (minSize.value.isNotEmpty && maxSize.value.isNotEmpty) {
      final min = double.tryParse(minSize.value);
      final max = double.tryParse(maxSize.value);
      
      if (min != null && max != null && min > max) {
        Get.snackbar(
          'Invalid Range',
          'Minimum size cannot be greater than maximum size',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: const Color(0xFFFFFFFF),
        );
        return false;
      }
    }
    
    return true;
  }

  // ═══════════════════════════════════════════════════════════
  // APPLY FILTERS
  // ═══════════════════════════════════════════════════════════
  
  void applyFilters() {
    if (!validateFilters()) {
      return;
    }
    
    print('🔍 Applying filters:');
    print('   City: ${city.value.isEmpty ? "Any" : city.value}');
    print('   Governorate: ${governorate.value.isEmpty ? "Any" : governorate.value}');
    print('   Address: ${address.value.isEmpty ? "Any" : address.value}');
    print('   Price: ${minPrice.value.isEmpty ? "No min" : minPrice.value} - ${maxPrice.value.isEmpty ? "No max" : maxPrice.value}');
    print('   Rooms: ${minRooms.value.isEmpty ? "No min" : minRooms.value} - ${maxRooms.value.isEmpty ? "No max" : maxRooms.value}');
    print('   Size: ${minSize.value.isEmpty ? "No min" : minSize.value} - ${maxSize.value.isEmpty ? "No max" : maxSize.value}');
    
    // Update active filters flag
    hasActiveFilters.value = city.value.isNotEmpty ||
                             governorate.value.isNotEmpty ||
                             address.value.isNotEmpty ||
                             minPrice.value.isNotEmpty ||
                             maxPrice.value.isNotEmpty ||
                             minRooms.value.isNotEmpty ||
                             maxRooms.value.isNotEmpty ||
                             minSize.value.isNotEmpty ||
                             maxSize.value.isNotEmpty;
    
    // Return filter data to previous screen
    Get.back(result: getFilterData());
    
    Get.snackbar(
      'Filters Applied',
      hasActiveFilters.value ? 'Filters have been applied' : 'All filters cleared',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF22C55E),
      colorText: const Color(0xFFFFFFFF),
      duration: const Duration(seconds: 2),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // GET FILTER DATA
  // Returns a map of current filter values
  // ═══════════════════════════════════════════════════════════
  
  Map<String, dynamic> getFilterData() {
    return {
      'city': city.value,
      'governorate': governorate.value,
      'address': address.value,
      'minPrice': minPrice.value.isEmpty ? null : double.tryParse(minPrice.value),
      'maxPrice': maxPrice.value.isEmpty ? null : double.tryParse(maxPrice.value),
      'minRooms': minRooms.value.isEmpty ? null : int.tryParse(minRooms.value),
      'maxRooms': maxRooms.value.isEmpty ? null : int.tryParse(maxRooms.value),
      'minSize': minSize.value.isEmpty ? null : double.tryParse(minSize.value),
      'maxSize': maxSize.value.isEmpty ? null : double.tryParse(maxSize.value),
    };
  }

  // ═══════════════════════════════════════════════════════════
  // CLEAR FILTERS
  // ═══════════════════════════════════════════════════════════
  
  void clearFilters() {
    cityController.clear();
    governorateController.clear();
    addressController.clear();
    
    minPriceController.clear();
    maxPriceController.clear();
    
    minRoomsController.clear();
    maxRoomsController.clear();
    
    minSizeController.clear();
    maxSizeController.clear();
    
    city.value = '';
    governorate.value = '';
    address.value = '';
    
    minPrice.value = '';
    maxPrice.value = '';
    
    minRooms.value = '';
    maxRooms.value = '';
    
    minSize.value = '';
    maxSize.value = '';
    
    hasActiveFilters.value = false;
    
    print('🗑️ Filters cleared');
    
    Get.snackbar(
      'Filters Cleared',
      'All filters have been reset',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF6B7280),
      colorText: const Color(0xFFFFFFFF),
      duration: const Duration(seconds: 2),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // GET ACTIVE FILTERS COUNT
  // Returns number of active filters
  // ═══════════════════════════════════════════════════════════
  
  int getActiveFiltersCount() {
    int count = 0;
    
    if (city.value.isNotEmpty) count++;
    if (governorate.value.isNotEmpty) count++;
    if (address.value.isNotEmpty) count++;
    if (minPrice.value.isNotEmpty || maxPrice.value.isNotEmpty) count++;
    if (minRooms.value.isNotEmpty || maxRooms.value.isNotEmpty) count++;
    if (minSize.value.isNotEmpty || maxSize.value.isNotEmpty) count++;
    
    return count;
  }

  @override
  void onClose() {
    // Dispose controllers
    cityController.dispose();
    governorateController.dispose();
    addressController.dispose();
    minPriceController.dispose();
    maxPriceController.dispose();
    minRoomsController.dispose();
    maxRoomsController.dispose();
    minSizeController.dispose();
    maxSizeController.dispose();
    
    super.onClose();
  }
}