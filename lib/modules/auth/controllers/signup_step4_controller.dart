import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/modules/owner/views/main_nav_view.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/signup/signup_step4_model.dart';
import '../../../data/services/signup_step4_service.dart';
import 'package:hommie/modules/renter/views/renter_home_screen.dart';

// ═══════════════════════════════════════════════════════════
// SIGNUP STEP 4 CONTROLLER - ULTIMATE FIX
// ✅ Handles ACTUAL backend response format
// ✅ Saves user data even without token
// ✅ Generates temporary token for persistence
// ═══════════════════════════════════════════════════════════

class SignupStep4Controller extends GetxController {
  late final int pendingUserId;

  final RxString personalImagePath = ''.obs;
  final RxString nationalIdImagePath = ''.obs;
  final isLoading = false.obs;
  final box = GetStorage();
  final picker = ImagePicker();
  final SignupStep4Service service = SignupStep4Service();

  final RxBool isPickingImage = false.obs;

  @override
  void onInit() {
    pendingUserId = Get.arguments['pendingUserId'];
    super.onInit();
  }

  // ═══════════════════════════════════════════════════════════
  // PICK IMAGE
  // ═══════════════════════════════════════════════════════════
  
  Future<void> pickImage(bool isAvatar) async {
    if (isPickingImage.value) {
      print('⚠️ Image picker already active, ignoring request');
      return;
    }

    try {
      isPickingImage.value = true;
      
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('📸 Picking ${isAvatar ? "Avatar" : "ID"} Image');
      print('═══════════════════════════════════════════════════════════');
      
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (picked != null) {
        if (isAvatar) {
          personalImagePath.value = picked.path;
          print('✅ Avatar selected: ${picked.path}');
        } else {
          nationalIdImagePath.value = picked.path;
          print('✅ ID image selected: ${picked.path}');
        }
        print('═══════════════════════════════════════════════════════════');
      } else {
        print('❌ No image selected');
        print('═══════════════════════════════════════════════════════════');
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      print('═══════════════════════════════════════════════════════════');
      
      Get.snackbar(
        'Error',
        'Failed to pick image. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      isPickingImage.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // UPLOAD IMAGES - ULTIMATE FIX
  // ✅ Saves role permanently BEFORE navigation
  // ═══════════════════════════════════════════════════════════
  
  Future<bool> uploadImages() async {
    if (personalImagePath.value.isEmpty || nationalIdImagePath.value.isEmpty) {
      Get.snackbar("Error", "Please select both images");
      return false;
    }

    isLoading.value = true;

    try {
      final model = SignupStep4Model(
        pendingUserId: pendingUserId,
        avatarPath: personalImagePath.value,
        idImagePath: nationalIdImagePath.value,
      );

      final result = await service.uploadImages(model);

      isLoading.value = false;

      if (result["success"] == true) {
        Get.snackbar(
          "Success", 
          "Images uploaded successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // ✅ Get role
        final storedRole = box.read('temp_signup_role') ?? 'renter';
        
        print('');
        print('═══════════════════════════════════════════════════════════');
        print('📝 [SIGNUP] Saving User Data');
        print('   Pending User ID: $pendingUserId');
        print('   Selected Role: $storedRole');
        print('──────────────────────────────────────────────────────────');

        // ✅ SAVE EVERYTHING PERMANENTLY - BEFORE NAVIGATION!
        box.write('role', storedRole);
        box.write('user_role', storedRole);
        box.write('user_id', pendingUserId); // ✅ Save the pending user ID!
        box.write('is_approved', false);
        
        // ✅ Generate temporary access token for persistence
        // (Backend will replace this with real token on approval)
        final tempToken = 'temp_${pendingUserId}_${DateTime.now().millisecondsSinceEpoch}';
        box.write('access_token', tempToken);

        print('✅ Data saved to storage:');
        print('   role: ${box.read('role')}');
        print('   user_role: ${box.read('user_role')}');
        print('   user_id: ${box.read('user_id')}');
        print('   access_token: ${tempToken.substring(0, 20)}...');
        print('   is_approved: ${box.read('is_approved')}');
        print('═══════════════════════════════════════════════════════════');

        // Remove temp role
        box.remove('temp_signup_role');

        // Finalize account in background
        finalizeAccount();

        // ✅ Navigate based on role
        if (storedRole == 'owner') {
          print('🏠 Navigating to Owner Dashboard...');
          Get.offAll(() => const MainNavView());
        } else {
          print('🏠 Navigating to Renter Home...');
          Get.offAll(() => const RenterHomeScreen());
        }
        
        return true;
      } else {
        Get.snackbar(
          "Error", 
          "Upload failed. Please try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      
      print('❌ Exception uploading images: $e');
      
      Get.snackbar(
        "Error",
        "An error occurred: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // FINALIZE ACCOUNT - ULTIMATE FIX
  // ✅ Handles the ACTUAL backend response format
  // ✅ Saves data from "user" object at root level
  // ═══════════════════════════════════════════════════════════
  
  Future<void> finalizeAccount() async {
    isLoading.value = true;

    try {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('🔐 [SIGNUP] Finalizing Account');
      print('   Pending User ID: $pendingUserId');
      print('──────────────────────────────────────────────────────────');
      
      final result = await service.finalizeAccount(pendingUserId);
      
      isLoading.value = false;

      print('📥 Finalization Response Keys:');
      print('   ${result.keys.toList()}');
      print('──────────────────────────────────────────────────────────');

      if (result["success"] == true) {
        
        // ✅ SAVE TOKEN IF PROVIDED (at root level or inside data)
        if (result.containsKey('token')) {
          final token = result['token'] as String;
          box.write('access_token', token);
          print('✅ Token saved from root: ${token.substring(0, 20)}...');
        } else if (result.containsKey('data') && 
                   result['data'] is Map && 
                   (result['data'] as Map).containsKey('token')) {
          final token = result['data']['token'] as String;
          box.write('access_token', token);
          print('✅ Token saved from data: ${token.substring(0, 20)}...');
        }

        // ✅ SAVE USER INFO - Check root level FIRST
        Map<String, dynamic>? userData;
        
        if (result.containsKey('user') && result['user'] is Map) {
          // User object at root level (YOUR CASE!)
          userData = result['user'] as Map<String, dynamic>;
          print('✅ Found user data at root level');
        } else if (result.containsKey('data') && 
                   result['data'] is Map && 
                   (result['data'] as Map).containsKey('user')) {
          // User object inside data
          userData = result['data']['user'] as Map<String, dynamic>;
          print('✅ Found user data inside data object');
        }

        if (userData != null) {
          print('📦 User Data Keys: ${userData.keys.toList()}');
          
          if (userData.containsKey('id')) {
            box.write('user_id', userData['id']);
            print('✅ User ID saved: ${userData['id']}');
          }
          
          if (userData.containsKey('role')) {
            box.write('role', userData['role']);
            box.write('user_role', userData['role']);
            print('✅ Role confirmed from backend: ${userData['role']}');
          }
          
          if (userData.containsKey('status')) {
            final isPending = userData['status'] == 'pending';
            box.write('is_approved', !isPending);
            print('✅ Approval status: ${!isPending ? "Approved" : "Pending"}');
          }
          
          // ✅ Save additional user info
          if (userData.containsKey('first_name')) {
            box.write('user_first_name', userData['first_name']);
          }
          if (userData.containsKey('last_name')) {
            box.write('user_last_name', userData['last_name']);
          }
          if (userData.containsKey('email')) {
            box.write('user_email', userData['email']);
          }
        }

        print('═══════════════════════════════════════════════════════════');
        print('✅ Account finalized successfully!');
        print('   Access Token: ${box.read('access_token') != null ? "✅ Saved" : "❌ Not saved"}');
        print('   User ID: ${box.read('user_id')}');
        print('   Role: ${box.read('role')}');
        print('   Approved: ${box.read('is_approved')}');
        print('   Name: ${box.read('user_first_name')} ${box.read('user_last_name')}');
        print('═══════════════════════════════════════════════════════════');

        Get.snackbar(
          "Success",
          "Account created. Waiting for admin approval.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        print('❌ Finalization failed');
        print('   Response: $result');
        print('═══════════════════════════════════════════════════════════');
        
        Get.snackbar(
          "Error",
          "Failed to finalize account.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      isLoading.value = false;

      print('❌ Exception finalizing account: $e');
      print('   Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      print('═══════════════════════════════════════════════════════════');

      Get.snackbar(
        "Error",
        "An error occurred: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> completeSignup() async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🚀 [SIGNUP] Starting Complete Signup Process');
    print('═══════════════════════════════════════════════════════════');
    
    bool uploaded = await uploadImages();
    
    if (uploaded) {
      print('✅ Images uploaded, proceeding to finalize...');
      await finalizeAccount();
    } else {
      print('❌ Image upload failed, signup not completed');
    }
  }

  @override
  void onClose() {
    isPickingImage.value = false;
    super.onClose();
  }
}