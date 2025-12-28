import 'package:flutter/material.dart';
import 'package:hommie/app/utils/app_colors.dart';

class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: AppColors.backgroundLight,
      body: const Center(
        child: Text(
          'Filter options will be added here.',
          style: TextStyle(fontSize: 18, color: AppColors.textSecondaryLight),
        ),
      ),
    );
  }
}
