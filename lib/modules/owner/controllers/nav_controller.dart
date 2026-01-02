

import 'package:get/get.dart';

class NavController extends GetxController {
  final currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
    // Force update to ensure UI rebuilds
    update();
  }
}