import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/modules/shared/controllers/logout_controller.dart';
import 'package:hommie/app/utils/app_colors.dart';

class ProfileScreen extends StatelessWidget {
 const ProfileScreen({super.key});

@override
Widget build(BuildContext context) {
final LogoutController controller = Get.put(LogoutController()); 

return Scaffold(
        backgroundColor: Colors.white,
 body: Center(
 child: Column(
 mainAxisAlignment: MainAxisAlignment.center,
 children: [
 const Text(
'Profile Content',
 style: TextStyle(fontSize: 24, color: AppColors.textPrimaryLight),
 ),
const SizedBox(height: 50),
 Obx(() => 
SizedBox(
height: 50,
 width: 250,
 child: ElevatedButton(
onPressed: controller.isLoggingOut.value ? null : controller.handleLogout,
style: ElevatedButton.styleFrom(
 backgroundColor: Colors.red,
 shape: RoundedRectangleBorder(
 borderRadius: BorderRadius.circular(10),), ),child: controller.isLoggingOut.value
? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3): const Text( 'Log Out',style: TextStyle(color: Colors.white, fontSize: 18), ), ),
 ),
),
 ],
),
 ),
 );
}
}