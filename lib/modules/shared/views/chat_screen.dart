import 'package:flutter/material.dart';
import 'package:hommie/app/utils/app_colors.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Chat Content',
        style: TextStyle(fontSize: 24, color: AppColors.textPrimaryLight),
      ),
    );
  }
}