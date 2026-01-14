import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/data/models/apartment/apartment_model.dart';
import 'package:hommie/modules/owner/views/my_apartments_screen.dart';
import 'package:hommie/modules/renter/controllers/renter_home_controller.dart';
import 'package:hommie/modules/renter/views/custom_navbar.dart';
import 'package:hommie/modules/renter/views/my_bookings_screen.dart';
import 'package:hommie/modules/shared/views/profile_screen.dart';
import 'package:hommie/modules/shared/views/filter_screen.dart';
import 'package:hommie/widgets/apartment_card.dart';

// ═══════════════════════════════════════════════════════════
// RENTER HOME SCREEN - ENHANCED WITH SEARCH AND FILTERS
// ✅ Search bar at the top (like Owner)
// ✅ Working filters that actually filter apartments
// ✅ Filter chips display
// ✅ Clear all filters button
// ═══════════════════════════════════════════════════════════

class RenterHomeScreen extends StatefulWidget {
  const RenterHomeScreen({super.key});

  @override
  State<RenterHomeScreen> createState() => _RenterHomeScreenState();
}

class _RenterHomeScreenState extends State<RenterHomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, dynamic>? _appliedFilters;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RenterHomeController());

    return Scaffold(
      appBar: _currentIndex == 0 ? _buildAppBar(controller) : null,
      body: _buildBody(controller),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: _handleNavigation,
      ),
    );
  }

  AppBar _buildAppBar(RenterHomeController controller) {
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

  Widget _buildBody(RenterHomeController controller) {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab(controller);
      case 1:
        return const MyBookingsScreen();
      case 2:
        return _buildFavoritesTab(controller);
      case 3:
        return _buildChatTab(controller);
      case 4:
        return const ProfileScreen();
      default:
        return _buildHomeTab(controller);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // HOME TAB WITH SEARCH AND FILTERS
  // ✅ Search bar at top
  // ✅ Filter button with badge
  // ✅ Active filters chips
  // ✅ Filtered apartments list
  // ═══════════════════════════════════════════════════════════

  Widget _buildHomeTab(RenterHomeController controller) {
    return Column(
      children: [
        // ✅ SEARCH BAR AT THE TOP
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              // Search TextField
              TextField(
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
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.textSecondaryLight,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
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
                            onPressed: _openFilterScreen,
                            tooltip: 'Filters',
                          ),

                          // Active filters badge
                          if (_appliedFilters != null && _getActiveFiltersCount() > 0)
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
                                    '${_getActiveFiltersCount()}',
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
              if (_appliedFilters != null && _getActiveFiltersCount() > 0) ...[
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
                      '${_getActiveFiltersCount()} active filter(s)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _clearAllFilters,
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
                _buildActiveFiltersChips(),
              ],
            ],
          ),
        ),

        // APARTMENTS LIST
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading apartments...'),
                  ],
                ),
              );
            }

            // ✅ APPLY FILTERS AND SEARCH
            final filteredApartments = _filterApartments(
              controller.apartments.toList(),
            );

            if (filteredApartments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _searchQuery.isNotEmpty || _appliedFilters != null
                          ? Icons.search_off
                          : Icons.home_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isNotEmpty || _appliedFilters != null
                          ? 'No apartments found'
                          : 'No apartments available',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searchQuery.isNotEmpty || _appliedFilters != null
                          ? 'Try adjusting your search or filters'
                          : 'Pull down to refresh',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    if (_appliedFilters != null) ...[
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _clearAllFilters,
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

            return RefreshIndicator(
              onRefresh: controller.refresh,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                children: [
                  // Header with count
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _searchQuery.isNotEmpty || _appliedFilters != null
                              ? '${filteredApartments.length} result${filteredApartments.length == 1 ? '' : 's'}'
                              : '${filteredApartments.length} Apartment${filteredApartments.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Colors.green.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Available',
                                style: TextStyle(
                                  color: Colors.green.shade700,
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

                  // Apartments List
                  ...filteredApartments.map((apartment) {
                    return UnifiedApartmentCard(
                      apartment: apartment,
                      showOwnerActions: false,
                      onFavoriteToggle: () {
                        print('❤️ Favorite toggled for: ${apartment.title}');

                        Get.snackbar(
                          'Favorite',
                          apartment.isFavorite == true
                              ? 'Removed from favorites'
                              : 'Added to favorites',
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                    );
                  }).toList(),

                  const SizedBox(height: 80),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // FILTER APARTMENTS
  // ✅ Filters by search query AND filter criteria
  // ═══════════════════════════════════════════════════════════

  List<ApartmentModel> _filterApartments(List<ApartmentModel> apartments) {
    return apartments.where((apartment) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final title = apartment.title.toLowerCase();
        final city = apartment.city.toLowerCase();
        final governorate = apartment.governorate.toLowerCase();

        final matchesSearch = title.contains(_searchQuery) ||
            city.contains(_searchQuery) ||
            governorate.contains(_searchQuery);

        if (!matchesSearch) return false;
      }

      // Location filters
      if (_appliedFilters != null) {
        // City filter
        if (_appliedFilters!['city'] != null &&
            (_appliedFilters!['city'] as String).isNotEmpty) {
          final filterCity = (_appliedFilters!['city'] as String).toLowerCase();
          if (!apartment.city.toLowerCase().contains(filterCity)) {
            return false;
          }
        }

        // Governorate filter
        if (_appliedFilters!['governorate'] != null &&
            (_appliedFilters!['governorate'] as String).isNotEmpty) {
          final filterGov =
              (_appliedFilters!['governorate'] as String).toLowerCase();
          if (!apartment.governorate.toLowerCase().contains(filterGov)) {
            return false;
          }
        }

        // Address filter
        if (_appliedFilters!['address'] != null &&
            (_appliedFilters!['address'] as String).isNotEmpty) {
          final filterAddress =
              (_appliedFilters!['address'] as String).toLowerCase();
          final aptAddress = apartment.address?.toLowerCase() ?? '';
          if (!aptAddress.contains(filterAddress)) {
            return false;
          }
        }

        // Price filter
        final minPrice = _appliedFilters!['minPrice'] as double?;
        final maxPrice = _appliedFilters!['maxPrice'] as double?;

        if (minPrice != null && apartment.pricePerDay < minPrice) {
          return false;
        }
        if (maxPrice != null && apartment.pricePerDay > maxPrice) {
          return false;
        }

        // Rooms filter
        final minRooms = _appliedFilters!['minRooms'] as int?;
        final maxRooms = _appliedFilters!['maxRooms'] as int?;

        if (minRooms != null && apartment.roomsCount < minRooms) {
          return false;
        }
        if (maxRooms != null && apartment.roomsCount > maxRooms) {
          return false;
        }

        // Size filter
        final minSize = _appliedFilters!['minSize'] as double?;
        final maxSize = _appliedFilters!['maxSize'] as double?;

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
  // OPEN FILTER SCREEN
  // ═══════════════════════════════════════════════════════════

  Future<void> _openFilterScreen() async {
    final result = await Get.to(() => const FilterScreen());

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _appliedFilters = result;
      });

      print('🔍 Filters applied:');
      print('   ${result}');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // CLEAR ALL FILTERS
  // ═══════════════════════════════════════════════════════════

  void _clearAllFilters() {
    setState(() {
      _appliedFilters = null;
      _searchQuery = '';
      _searchController.clear();
    });

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
  // GET ACTIVE FILTERS COUNT
  // ═══════════════════════════════════════════════════════════

  int _getActiveFiltersCount() {
    if (_appliedFilters == null) return 0;

    int count = 0;

    if (_appliedFilters!['city'] != null &&
        (_appliedFilters!['city'] as String).isNotEmpty) count++;

    if (_appliedFilters!['governorate'] != null &&
        (_appliedFilters!['governorate'] as String).isNotEmpty) count++;

    if (_appliedFilters!['address'] != null &&
        (_appliedFilters!['address'] as String).isNotEmpty) count++;

    if (_appliedFilters!['minPrice'] != null ||
        _appliedFilters!['maxPrice'] != null) count++;

    if (_appliedFilters!['minRooms'] != null ||
        _appliedFilters!['maxRooms'] != null) count++;

    if (_appliedFilters!['minSize'] != null ||
        _appliedFilters!['maxSize'] != null) count++;

    return count;
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD ACTIVE FILTERS CHIPS
  // ═══════════════════════════════════════════════════════════

  Widget _buildActiveFiltersChips() {
    final chips = <Widget>[];

    if (_appliedFilters!['city'] != null &&
        (_appliedFilters!['city'] as String).isNotEmpty) {
      chips.add(_buildFilterChip('City: ${_appliedFilters!['city']}'));
    }

    if (_appliedFilters!['governorate'] != null &&
        (_appliedFilters!['governorate'] as String).isNotEmpty) {
      chips.add(_buildFilterChip('Gov: ${_appliedFilters!['governorate']}'));
    }

    if (_appliedFilters!['address'] != null &&
        (_appliedFilters!['address'] as String).isNotEmpty) {
      chips.add(_buildFilterChip('Address: ${_appliedFilters!['address']}'));
    }

    if (_appliedFilters!['minPrice'] != null ||
        _appliedFilters!['maxPrice'] != null) {
      final min = _appliedFilters!['minPrice']?.toString() ?? 'Any';
      final max = _appliedFilters!['maxPrice']?.toString() ?? 'Any';
      chips.add(_buildFilterChip('Price: $min - $max'));
    }

    if (_appliedFilters!['minRooms'] != null ||
        _appliedFilters!['maxRooms'] != null) {
      final min = _appliedFilters!['minRooms']?.toString() ?? 'Any';
      final max = _appliedFilters!['maxRooms']?.toString() ?? 'Any';
      chips.add(_buildFilterChip('Rooms: $min - $max'));
    }

    if (_appliedFilters!['minSize'] != null ||
        _appliedFilters!['maxSize'] != null) {
      final min = _appliedFilters!['minSize']?.toString() ?? 'Any';
      final max = _appliedFilters!['maxSize']?.toString() ?? 'Any';
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
  // OTHER TABS (Unchanged)
  // ═══════════════════════════════════════════════════════════

  Widget _buildFavoritesTab(RenterHomeController controller) {
    if (!controller.canAccessFavorites()) {
      return _buildApprovalRequiredScreen('Favorites');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the heart icon on apartments to save them',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTab(RenterHomeController controller) {
    if (!controller.canAccessChat()) {
      return _buildApprovalRequiredScreen('Chat');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start chatting with apartment owners',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalRequiredScreen(String featureName) {
    return Scaffold(
      appBar: AppBar(
        title: Text(featureName),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Approval Required',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your account must be approved to access $featureName',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentIndex = 0;
                  });
                },
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNavigation(int index) {
    setState(() {
      _currentIndex = index;
    });

    print('📱 Navigated to tab $index');
  }
}