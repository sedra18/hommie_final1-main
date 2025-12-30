import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/modules/renter/controllers/home_controller.dart';
import 'package:hommie/modules/renter/views/custom_navbar.dart';
import 'package:hommie/modules/shared/views/profile_screen.dart';
import 'package:hommie/widgets/apartment_card.dart';
import 'package:hommie/app/utils/app_colors.dart';

// ═══════════════════════════════════════════════════════════
// RENTER HOME SCREEN - WITH CUSTOM NAVBAR
// Shows all available apartments
// Includes bottom navigation for all sections
// ═══════════════════════════════════════════════════════════

class RenterHomeScreen extends StatefulWidget {
  const RenterHomeScreen({super.key});

  @override
  State<RenterHomeScreen> createState() => _RenterHomeScreenState();
}

class _RenterHomeScreenState extends State<RenterHomeScreen> {
  int _currentIndex = 0; // Start at Home tab

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RenterHomeController());

    return Scaffold(
      appBar: _currentIndex == 0 ? _buildAppBar(controller) : null,
      
      body: _buildBody(controller),
      
      // ✅ Custom NavBar
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: _handleNavigation,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD APP BAR (only for Home tab)
  // ═══════════════════════════════════════════════════════════
  
  AppBar _buildAppBar(RenterHomeController controller) {
    return AppBar(
      title: const Text('Available Apartments'),
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
  // Show different content based on selected tab
  // ═══════════════════════════════════════════════════════════
  
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
  // ═══════════════════════════════════════════════════════════
  
  Widget _buildHomeTab(RenterHomeController controller) {
    return Obx(() {
      // Loading state
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
      
      // Empty state
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
      
      // Apartments list
      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
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
            
            // Apartments List
            ...controller.apartments.map((apartment) {
              return ApartmentCard(
                apartment: apartment,
                isMyApartment: false,  // Renter never owns apartments
                showOwnerActions: false,  // Renter has no edit/delete
                onTap: () {
                  // Navigate to apartment details
                  controller.goToDetails(apartment);
                },
              );
            }).toList(),
            
            const SizedBox(height: 80),
          ],
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════
  // SEARCH TAB
  // ═══════════════════════════════════════════════════════════
  
  Widget _buildSearchTab() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Apartments'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // ✅ No back button
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

  // ═══════════════════════════════════════════════════════════
  // FAVORITES TAB
  // ═══════════════════════════════════════════════════════════
  
  Widget _buildFavoritesTab(RenterHomeController controller) {
    // Check if user can access favorites
    if (!controller.canAccessFavorites()) {
      return _buildApprovalRequiredScreen('Favorites');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // ✅ No back button
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

  // ═══════════════════════════════════════════════════════════
  // CHAT TAB
  // ═══════════════════════════════════════════════════════════
  
  Widget _buildChatTab(RenterHomeController controller) {
    // Check if user can access chat
    if (!controller.canAccessChat()) {
      return _buildApprovalRequiredScreen('Chat');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // ✅ No back button
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

  // ═══════════════════════════════════════════════════════════
  // APPROVAL REQUIRED SCREEN
  // Shows when user tries to access feature without approval
  // ═══════════════════════════════════════════════════════════
  
  Widget _buildApprovalRequiredScreen(String featureName) {
    return Scaffold(
      appBar: AppBar(
        title: Text(featureName),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // ✅ No back button
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
                  // Navigate back to home
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

  // ═══════════════════════════════════════════════════════════
  // HANDLE NAVIGATION
  // Switch between tabs
  // ═══════════════════════════════════════════════════════════
  
  void _handleNavigation(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    print('📱 Navigated to tab $index');
  }
}