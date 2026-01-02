import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/modules/owner/controllers/nav_controller.dart';
import 'package:hommie/modules/owner/views/owner_home_screen.dart';
import 'package:hommie/modules/owner/views/post_ad_screen.dart';
import 'package:hommie/modules/shared/views/chat_screen.dart';
import 'package:hommie/modules/shared/views/favorites_screen.dart';
import 'package:hommie/modules/shared/views/profile_screen.dart';

// ═══════════════════════════════════════════════════════════
// ALTERNATIVE FIX - Using StatefulWidget
// More reliable with ConvexAppBar's internal state management
// ═══════════════════════════════════════════════════════════

class MainNavView extends StatefulWidget {
  const MainNavView({super.key});

  @override
  State<MainNavView> createState() => _MainNavViewState();
}

class _MainNavViewState extends State<MainNavView> {
  final nav = Get.put(NavController());

  final pages = [
    OwnerHomeScreen(),
    ChatScreen(),
    FavoritesScreen(),
    PostAdScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        body: pages[nav.currentIndex.value],
        bottomNavigationBar: ConvexAppBar(
          style: TabStyle.fixedCircle,
          backgroundColor: AppColors.primary,
          color: AppColors.backgroundLight.withOpacity(0.6),
          activeColor: AppColors.backgroundLight,
          elevation: 8,
          curveSize: 90,
          top: -28,
          height: 60,
          
          // Current index synced with GetX
          initialActiveIndex: nav.currentIndex.value,
          
          onTap: (index) {
            setState(() {
              nav.changeTab(index);
            });
          },
          
          items: const [
            TabItem(icon: Icons.home_outlined, title: 'Home'),
            TabItem(icon: Icons.message_outlined, title: 'Messages'),
            TabItem(icon: Icons.favorite_border, title: 'Favorite'),
            TabItem(icon: Icons.post_add_outlined, title: 'Post Ad'),
            TabItem(icon: Icons.person_outline, title: 'Profile'),
          ],
        ),
      );
    });
  }
}