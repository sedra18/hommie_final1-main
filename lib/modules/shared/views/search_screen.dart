import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/modules/shared/controllers/filter_controller.dart';
import 'package:hommie/modules/shared/views/filter_screen.dart';

// ═══════════════════════════════════════════════════════════
// SEARCH SCREEN
// Search apartments with filters
// Works for both Owner and Renter programs
// ═══════════════════════════════════════════════════════════

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final filterController = Get.put(FilterController());
  
  String searchQuery = '';
  Map<String, dynamic>? appliedFilters;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // OPEN FILTER SCREEN
  // ═══════════════════════════════════════════════════════════
  
  Future<void> _openFilterScreen() async {
    final result = await Get.to(() => const FilterScreen());
    
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        appliedFilters = result;
      });
      
      // Here you would typically call your search/filter API
      _performSearch();
    }
  }

  // ═══════════════════════════════════════════════════════════
  // PERFORM SEARCH
  // ═══════════════════════════════════════════════════════════
  
  void _performSearch() {
    print('🔍 Performing search:');
    print('   Query: ${searchQuery.isEmpty ? "None" : searchQuery}');
    
    if (appliedFilters != null) {
      print('   Filters:');
      appliedFilters!.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          print('     $key: $value');
        }
      });
    }
    
    // TODO: Call your search API here with searchQuery and appliedFilters
    // Example:
    // final controller = Get.find<RenterHomeController>();
    // controller.searchApartments(query: searchQuery, filters: appliedFilters);
  }

  // ═══════════════════════════════════════════════════════════
  // CLEAR SEARCH
  // ═══════════════════════════════════════════════════════════
  
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      searchQuery = '';
      appliedFilters = null;
    });
    
    filterController.clearFilters();
    
    Get.snackbar(
      'Search Cleared',
      'All search filters have been reset',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF6B7280),
      colorText: const Color(0xFFFFFFFF),
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(color: AppColors.backgroundLight),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.backgroundLight,
        automaticallyImplyLeading: false, // No back button when used in navbar
      ),
      body: Column(
        children: [
          // Search Bar Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search TextField
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for property...',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondaryLight.withOpacity(0.6),
                    ),
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Clear search button
                        if (searchQuery.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textSecondaryLight),
                            onPressed: () {
                              _searchController.clear();
                            },
                            tooltip: 'Clear search',
                          ),
                        
                        // Filter button with badge
                        Stack(
                          children: [
                            IconButton(
                              iconSize: 28,
                              onPressed: _openFilterScreen,
                              icon: const Icon(Icons.filter_list, color: AppColors.primary),
                              tooltip: 'Filters',
                            ),
                            
                            // Active filters badge
                            Obx(() {
                              final count = filterController.getActiveFiltersCount();
                              if (count == 0) return const SizedBox.shrink();
                              
                              return Positioned(
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
                                      '$count',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
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
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundLight,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                
                const SizedBox(height: 12),
                
                // Active Filters Display
                Obx(() {
                  if (!filterController.hasActiveFilters.value) {
                    return const SizedBox.shrink();
                  }
                  
                  return Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.filter_alt,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${filterController.getActiveFiltersCount()} active filter(s)',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _clearSearch,
                            child: const Text(
                              'Clear all',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.failure,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildActiveFiltersChips(),
                    ],
                  );
                }),
              ],
            ),
          ),
          
          // Search Results Section
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD ACTIVE FILTERS CHIPS
  // ═══════════════════════════════════════════════════════════
  
  Widget _buildActiveFiltersChips() {
    final chips = <Widget>[];
    
    if (filterController.city.value.isNotEmpty) {
      chips.add(_buildFilterChip('City: ${filterController.city.value}'));
    }
    
    if (filterController.governorate.value.isNotEmpty) {
      chips.add(_buildFilterChip('Gov: ${filterController.governorate.value}'));
    }
    
    if (filterController.minPrice.value.isNotEmpty || filterController.maxPrice.value.isNotEmpty) {
      final min = filterController.minPrice.value.isEmpty ? 'Any' : filterController.minPrice.value;
      final max = filterController.maxPrice.value.isEmpty ? 'Any' : filterController.maxPrice.value;
      chips.add(_buildFilterChip('Price: $min - $max'));
    }
    
    if (filterController.minRooms.value.isNotEmpty || filterController.maxRooms.value.isNotEmpty) {
      final min = filterController.minRooms.value.isEmpty ? 'Any' : filterController.minRooms.value;
      final max = filterController.maxRooms.value.isEmpty ? 'Any' : filterController.maxRooms.value;
      chips.add(_buildFilterChip('Rooms: $min - $max'));
    }
    
    if (filterController.minSize.value.isNotEmpty || filterController.maxSize.value.isNotEmpty) {
      final min = filterController.minSize.value.isEmpty ? 'Any' : filterController.minSize.value;
      final max = filterController.maxSize.value.isEmpty ? 'Any' : filterController.maxSize.value;
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

  // ═══════════════════════════════════════════════════════════
  // BUILD SEARCH RESULTS
  // ═══════════════════════════════════════════════════════════
  
  Widget _buildSearchResults() {
    // Empty state when no search
    if (searchQuery.isEmpty && !filterController.hasActiveFilters.value) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Search for apartments',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use the search bar and filters above',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }
    
    // TODO: Replace with actual search results from your controller
    // Example:
    // return Obx(() {
    //   final results = controller.searchResults;
    //   if (results.isEmpty) {
    //     return _buildNoResults();
    //   }
    //   return ListView.builder(...);
    // });
    
    return _buildNoResults();
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD NO RESULTS
  // ═══════════════════════════════════════════════════════════
  
  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No apartments found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _clearSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Clear filters',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}