import 'package:flutter/material.dart';
import 'package:hommie/app/utils/app_colors.dart';

class OwnerHomeScreen extends StatelessWidget {
  const OwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Owner Dashboard"),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "Welcome Owner! Content will be added here.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}