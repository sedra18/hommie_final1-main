import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/modules/renter/controllers/renter_home_controller.dart';
import 'package:hommie/modules/renter/views/custom_navbar.dart';
import 'package:hommie/modules/shared/views/profile_screen.dart';
import 'package:hommie/widgets/apartment_card.dart';  
import 'package:hommie/app/utils/app_colors.dart';

// ═══════════════════════════════════════════════════════════
// RENTER HOME SCREEN - FIXED
// ✅ Uses UnifiedApartmentCard correctly
// ✅ Shows favorites button for renters
// ═══════════════════════════════════════════════════════════

class RenterHomeScreen extends StatefulWidget {
  const RenterHomeScreen({super.key});

  @override
  State<RenterHomeScreen> createState() => _RenterHomeScreenState();
}

class _RenterHomeScreenState extends State<RenterHomeScreen> {
  int _currentIndex = 0;

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
        return _buildSearchTab();
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
  // HOME TAB - All Apartments
  // ✅ FIXED: Uses UnifiedApartmentCard correctly
  // ═══════════════════════════════════════════════════════════
  
  Widget _buildHomeTab(RenterHomeController controller) {
    return Obx(() {
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
      
      if (controller.apartments.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.home_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No apartments available',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pull down to refresh',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        );
      }
      
      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${controller.apartments.length} Apartments',
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
            
            // ✅ FIXED: Apartments List with correct parameters
            ...controller.apartments.map((apartment) {
              return UnifiedApartmentCard(
                apartment: apartment,
                showOwnerActions: false,  // ✅ Renter can't edit/delete
                onFavoriteToggle: () {
                  // ✅ Handle favorite toggle
                  print('❤️ Favorite toggled for: ${apartment.title}');
                  
                  // TODO: Update favorite status in backend
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
    });
  }

  Widget _buildSearchTab() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Apartments'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
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
              'Search Feature',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon...',
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