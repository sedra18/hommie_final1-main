  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import 'package:hommie/modules/owner/controllers/owner_home_controller.dart';
  import 'package:hommie/modules/shared/views/apartment_card_home.dart';
  import 'package:hommie/modules/shared/views/filter_screen.dart';
  import 'package:hommie/app/utils/app_colors.dart';

  // ═══════════════════════════════════════════════════════════
  // OWNER HOME SCREEN - ENHANCED WITH FILTERS
  // ✅ Search bar at top (like Renter)
  // ✅ Working filters with badge
  // ✅ Active filters chips display
  // ✅ Clear all filters button
  // ✅ Filter count indicator
  // ═══════════════════════════════════════════════════════════

  class OwnerHomeScreen extends StatefulWidget {
    const OwnerHomeScreen({super.key});

    @override
    State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
  }

  class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
    final TextEditingController _searchController = TextEditingController();

    @override
    void dispose() {
      _searchController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      final controller = Get.put(OwnerHomeController());

      return Scaffold(
        appBar: _buildAppBar(controller),
        body: _buildBody(controller),
      );
    }

    // ═══════════════════════════════════════════════════════════
    // BUILD APP BAR
    // ═══════════════════════════════════════════════════════════
    
    AppBar _buildAppBar(OwnerHomeController controller) {
      return AppBar(
        title: const Text('Home'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refresh(),
            tooltip: 'Refresh',
          ),
        ],
      );
    }

    // ═══════════════════════════════════════════════════════════
    // BUILD BODY
    // ═══════════════════════════════════════════════════════════
    
    Widget _buildBody(OwnerHomeController controller) {
      return Column(
        children: [
          // ✅ SEARCH BAR AND FILTERS AT THE TOP
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Obx(() => Column(
              children: [
                // Search TextField with Filter Button
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    controller.setSearchQuery(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search apartments...',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondaryLight.withOpacity(0.6),
                    ),
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Clear search button
                        if (controller.searchQuery.value.isNotEmpty)
                          IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: AppColors.textSecondaryLight,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              controller.setSearchQuery('');
                            },
                          ),
                        
                        // Filter button with badge
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.filter_list,
                                color: AppColors.primary,
                              ),
                              onPressed: () => _openFilterScreen(controller),
                              tooltip: 'Filters',
                            ),
                            
                            // Active filters badge
                            if (controller.getActiveFiltersCount() > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${controller.getActiveFiltersCount()}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundLight,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),

                // Active filters chips
                if (controller.appliedFilters.value != null && 
                    controller.getActiveFiltersCount() > 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.filter_alt,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${controller.getActiveFiltersCount()} active filter(s)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _clearAllFilters(controller),
                        child: const Text(
                          'Clear all',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildActiveFiltersChips(controller),
                ],
              ],
            )),
          ),
          
          // APARTMENTS LIST
          Expanded(
            child: Obx(() {
              // Loading state
              if (controller.isLoading.value) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 16),
                      Text('Loading apartments...'),
                    ],
                  ),
                );
              }
              
              // ✅ Get all apartments
              final allApartments = controller.apartments.toList();
              
              // ✅ Apply filters and search
              final filteredApartments = controller.filterApartments(allApartments);
              
              // Empty state
              if (filteredApartments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        controller.searchQuery.value.isNotEmpty || 
                        controller.appliedFilters.value != null
                            ? Icons.search_off
                            : Icons.home_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.searchQuery.value.isNotEmpty || 
                        controller.appliedFilters.value != null
                            ? 'No apartments found'
                            : 'No apartments yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.searchQuery.value.isNotEmpty || 
                        controller.appliedFilters.value != null
                            ? 'Try adjusting your search or filters'
                            : 'Pull down to refresh',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      if (controller.appliedFilters.value != null) ...[
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _clearAllFilters(controller),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text(
                            'Clear filters',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }
              
              // Apartments list
              return RefreshIndicator(
                onRefresh: controller.refresh,
                color: AppColors.primary,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Header with count
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            controller.searchQuery.value.isNotEmpty || 
                            controller.appliedFilters.value != null
                                ? '${filteredApartments.length} result${filteredApartments.length == 1 ? '' : 's'}'
                                : '${filteredApartments.length} Apartment${filteredApartments.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.home_work,
                                  size: 16,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Owner',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Apartments Grid/List
                    ...filteredApartments.map((apartment) {
                      return ApartmentCardHome(
                        apartment: apartment,
                      );
                    }).toList(),
                    
                    const SizedBox(height: 80), // Bottom padding
                  ],
                ),
              );
            }),
          ),
        ],
      );
    }

    // ═══════════════════════════════════════════════════════════
    // OPEN FILTER SCREEN
    // ═══════════════════════════════════════════════════════════

    Future<void> _openFilterScreen(OwnerHomeController controller) async {
      final result = await Get.to(() => const FilterScreen());

      if (result != null && result is Map<String, dynamic>) {
        controller.applyFilters(result);
        
        print('🔍 [OWNER] Filters applied: $result');
      }
    }

    // ═══════════════════════════════════════════════════════════
    // CLEAR ALL FILTERS
    // ═══════════════════════════════════════════════════════════

    void _clearAllFilters(OwnerHomeController controller) {
      _searchController.clear();
      controller.clearAllFilters();

      Get.snackbar(
        'Filters Cleared',
        'All search and filters have been reset',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF6B7280),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }

    // ═══════════════════════════════════════════════════════════
    // BUILD ACTIVE FILTERS CHIPS
    // ═══════════════════════════════════════════════════════════

    Widget _buildActiveFiltersChips(OwnerHomeController controller) {
      final chips = <Widget>[];
      final filters = controller.appliedFilters.value!;

      if (filters['city'] != null && (filters['city'] as String).isNotEmpty) {
        chips.add(_buildFilterChip('City: ${filters['city']}'));
      }

      if (filters['governorate'] != null &&
          (filters['governorate'] as String).isNotEmpty) {
        chips.add(_buildFilterChip('Gov: ${filters['governorate']}'));
      }

      if (filters['address'] != null &&
          (filters['address'] as String).isNotEmpty) {
        chips.add(_buildFilterChip('Address: ${filters['address']}'));
      }

      if (filters['minPrice'] != null || filters['maxPrice'] != null) {
        final min = filters['minPrice']?.toString() ?? 'Any';
        final max = filters['maxPrice']?.toString() ?? 'Any';
        chips.add(_buildFilterChip('Price: $min - $max'));
      }

      if (filters['minRooms'] != null || filters['maxRooms'] != null) {
        final min = filters['minRooms']?.toString() ?? 'Any';
        final max = filters['maxRooms']?.toString() ?? 'Any';
        chips.add(_buildFilterChip('Rooms: $min - $max'));
      }

      if (filters['minSize'] != null || filters['maxSize'] != null) {
        final min = filters['minSize']?.toString() ?? 'Any';
        final max = filters['maxSize']?.toString() ?? 'Any';
        chips.add(_buildFilterChip('Size: $min - $max m²'));
      }

      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: chips,
      );
    }

    // ═══════════════════════════════════════════════════════════
    // BUILD FILTER CHIP
    // ═══════════════════════════════════════════════════════════

    Widget _buildFilterChip(String label) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
  }