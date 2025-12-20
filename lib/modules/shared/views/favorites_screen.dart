import 'package:flutter/material.dart';
import 'package:hommie/app/utils/app_colors.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Favorites Content',
        style: TextStyle(fontSize: 24, color: AppColors.textPrimaryLight),
      ),
    );
  }
}