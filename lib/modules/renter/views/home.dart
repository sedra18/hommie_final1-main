import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/modules/renter/controllers/home_controller.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/modules/renter/views/apartments_screen.dart';
import 'package:hommie/modules/shared/views/chat_screen.dart';
import 'package:hommie/modules/renter/views/custom_navbar.dart';
import 'package:hommie/modules/shared/views/favorites_screen.dart';
import 'package:hommie/modules/shared/views/filter_screen.dart';
import 'package:hommie/modules/shared/views/profile_screen.dart';

class RenterHomeScreen extends StatelessWidget {
  const RenterHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    final List<Widget> pages = [
      const ApartmentsScreen(),
      const FilterScreen(),
<<<<<<< HEAD
      FavoritesScreen(),
      const ChatScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          "Hommie",
          style: TextStyle(color: AppColors.textPrimaryDark, fontSize: 32),
        ),
        centerTitle: true,
      ),

      // backgroundColor: AppColors.backgroundLight,
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: pages,
      ),

      bottomNavigationBar: Obx(
        () => CustomNavBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTabIndex,
        ),
      ),
    );
  }
}
=======
       FavoritesScreen(),
      const ChatScreen(),
      const ProfileScreen(),   
    ];

    return Scaffold(
      appBar: AppBar(backgroundColor: AppColors.primary,title:Text("Hommie",style: TextStyle(color: AppColors.textPrimaryDark,fontSize: 32)) ,centerTitle: true,),
      backgroundColor: AppColors.backgroundLight,

      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(), 
        children: pages,
      ),
      
      bottomNavigationBar: Obx(() => CustomNavBar(
        currentIndex: controller.currentIndex.value,
        onTap: controller.changeTabIndex,
      )),
    );
  }
}
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
