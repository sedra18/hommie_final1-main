import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingHelper  {
  static void show() {
    Get.dialog(
      Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );
  }

  static void hide() {
  Get.back(closeOverlays: true);
    }
  }
