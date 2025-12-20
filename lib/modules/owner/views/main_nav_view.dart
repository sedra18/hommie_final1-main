



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
    final nav = Get.find<NavController>();

    final pages = const [
      OwnerHomeScreen(),
      ChatScreen(),
      FavoritesScreen(),
      PostAdScreen(),
      ProfileScreen(),
    ];

    return Obx(() {
      return Scaffold(
        body: pages[nav.currentIndex.value],
    
        bottomNavigationBar: BottomNavigationBar(
              backgroundColor: AppColors.primary,
          currentIndex: nav.currentIndex.value,
          onTap: nav.changeTab,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home,color: AppColors.backgroundLight,), label: "Home"
            
            ),
            BottomNavigationBarItem(icon: Icon(Icons.message,color: AppColors.backgroundLight), label: "Messages"),
            BottomNavigationBarItem(icon: Icon(Icons.favorite,color: AppColors.backgroundLight), label: "Favorite"),
            BottomNavigationBarItem(icon: Icon(Icons.post_add,color: AppColors.backgroundLight), label: "PostAd"),
            BottomNavigationBarItem(icon: Icon(Icons.person,color: AppColors.backgroundLight), label: "Profile"),
          ],
        ),
      );
    });
  }
}