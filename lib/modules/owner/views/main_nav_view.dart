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

class MainNavView extends StatelessWidget {
  const MainNavView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the new separate controller
    final NavController nav = Get.put(NavController());

    // List of screens corresponding to the bottom bar items
    final List<Widget> pages = [
      const OwnerHomeScreen(),
      const ChatScreen(),
      const FavoritesScreen(),
      const PostAdScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      // Obx listens to nav.currentIndex and rebuilds only the body/bar
      body: Obx(() => IndexedStack(
            index: nav.currentIndex.value,
            children: pages,
          )),
      bottomNavigationBar: Obx(() => ConvexAppBar(
            style: TabStyle.fixedCircle,
            backgroundColor: AppColors.primary,
            color: AppColors.backgroundLight.withOpacity(0.6),
            activeColor: AppColors.backgroundLight,
            elevation: 8,
            curveSize: 90,
            top: -28,
            height: 60,
            
            // Sync current index with Controller
            initialActiveIndex: nav.currentIndex.value,
            
            onTap: (index) => nav.changeTab(index),
            
            items: const [
              TabItem(icon: Icons.home_outlined, title: 'Home'),
              TabItem(icon: Icons.message_outlined, title: 'Messages'),
              TabItem(icon: Icons.favorite_border, title: 'Favorite'),
              TabItem(icon: Icons.post_add_outlined, title: 'Post Ad'),
              TabItem(icon: Icons.person_outline, title: 'Profile'),
            ],
          )),
    );
  }
}