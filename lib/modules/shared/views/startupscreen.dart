<<<<<<< HEAD
=======

>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/modules/shared/controllers/startupscreen_controller.dart';

class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    Get.put(StartupscreenController());
    return Scaffold(
      //backgroundColor:Colors.white,
=======
     Get.put(StartupscreenController());
    return Scaffold(backgroundColor:Colors.white,
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
<<<<<<< HEAD
              image: AssetImage("assets/images/logopage.png"),
=======
              image: AssetImage(
                  "assets/images/logopage.png"), 
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> af917e11cc23fa74f5a0f47311b19cfd234f1c54
