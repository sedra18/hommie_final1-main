import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/modules/owner/controllers/owner_home_controller.dart';
import 'package:hommie/modules/shared/views/apartment_card_home.dart';
import 'package:hommie/modules/shared/views/filter_screen.dart';
import 'package:hommie/app/utils/app_colors.dart';

// ═══════════════════════════════════════════════════════════
// OWNER HOME SCREEN - FIXED WITH PROPER RXLIST HANDLING
// Shows ALL apartments with search at top
// Uses apartment_card_home for navigation to details
// ═══════════════════════════════════════════════════════════

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
        // ✅ SEARCH BAR AT THE TOP
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
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
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textSecondaryLight),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    ),
                  
                  // Filter button
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: AppColors.primary),
                    onPressed: () async {
                      final result = await Get.to(() => const FilterScreen());
                      if (result != null) {
                        print('Filters applied: $result');
                      }
                    },
                    tooltip: 'Filters',
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
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
            
            // ✅ FIXED: Get apartments as List, not RxList
            final allApartments = controller.apartments.toList();
            
            // Filter by search query
            final filteredApartments = _searchQuery.isEmpty
                ? allApartments
                : allApartments.where((apt) {
                    final title = apt.title.toLowerCase();
                    final city = apt.city.toLowerCase();
                    final governorate = apt.governorate.toLowerCase();
                    return title.contains(_searchQuery) ||
                           city.contains(_searchQuery) ||
                           governorate.contains(_searchQuery);
                  }).toList();
            
            // Empty state
            if (filteredApartments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _searchQuery.isNotEmpty ? Icons.search_off : Icons.home_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isNotEmpty 
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
                      _searchQuery.isNotEmpty
                          ? 'Try a different search term'
                          : 'Pull down to refresh',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
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
                          _searchQuery.isNotEmpty
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
                      showFavoriteButton: true,
                      onFavoriteToggle: () {
                        // TODO: Implement favorite toggle
                        print('Toggle favorite for: ${apartment.title}');
                      },
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
}