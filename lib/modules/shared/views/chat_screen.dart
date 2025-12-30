import 'package:flutter/material.dart';
import 'package:hommie/app/utils/app_colors.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Scaffold(
      body: Center(child: Text('Chat Content', style: TextStyle(fontSize: 24))),
    );
  }
}
=======
    return const Center(
      child: Text(
        'Chat Content',
        style: TextStyle(fontSize: 24, color: AppColors.textPrimaryLight),
      ),
    );
  }
}
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
