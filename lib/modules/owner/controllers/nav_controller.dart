import 'package:get/get.dart';

class NavController extends GetxController {
  // Observable index to track the current tab
  var currentIndex = 0.obs;

  // Method to update the index safely
  void changeTab(int index) {
    print('🔄 Navigating to Tab Index: $index');
    currentIndex.value = index;
  }

  // Optional: Method to jump back to Home from anywhere
  void goToHome() {
    currentIndex.value = 0;
  }
}