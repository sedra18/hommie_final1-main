import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:hommie/app/utils/app_colors.dart';

// ═══════════════════════════════════════════════════════════
// CUSTOM CONVEX BOTTOM BAR
// ✅ Modern curved design
// ✅ Smooth animations
// ✅ Custom colors
// ═══════════════════════════════════════════════════════════

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
      // ═══════════════════════════════════════════════════════
      // STYLE & APPEARANCE
      // ═══════════════════════════════════════════════════════
      
      style: TabStyle.fixedCircle,  // ✅ Curved with circle in middle
      
      backgroundColor: AppColors.primary,  // Background color
      color: Colors.white70,  // Inactive icon color
      activeColor: Colors.white,  // Active icon color
      
      // Elevated button (middle icon)
      curveSize: 90,  // Size of the curve
      top: -28,  // How far the middle button pops up
      height: 60,  // Total height of the bar
      
      // ═══════════════════════════════════════════════════════
      // GRADIENT FOR ELEVATED BUTTON (Optional)
      // ═══════════════════════════════════════════════════════
      
      gradient: const LinearGradient(
        colors: [
          Color(0xFF3A7AFE),  // AppColors.primary
          Color(0xFF5B8EFF),  // Lighter shade
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      
      // ═══════════════════════════════════════════════════════
      // NAVIGATION
      // ═══════════════════════════════════════════════════════
      
      initialActiveIndex: currentIndex,
      onTap: onTap,
      
      // ═══════════════════════════════════════════════════════
      // ITEMS
      // ═══════════════════════════════════════════════════════
      
      items: const [
        // Home
        TabItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          title: 'Home',
        ),
        
        // Search
        TabItem(
          icon: Icons.apartment_outlined,
          activeIcon: Icons.apartment,
          title: 'MyApa',
        ),
        
        // Favorites (MIDDLE - ELEVATED)
        TabItem(
          icon: Icons.favorite,
          title: 'Favorites',
        ),
        
        // Chat
        TabItem(
          icon: Icons.chat_bubble_outline,
          activeIcon: Icons.chat_bubble,
          title: 'Chat',
        ),
        
        // Profile
        TabItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          title: 'Profile',
        ),
      ],
    );
  }
}