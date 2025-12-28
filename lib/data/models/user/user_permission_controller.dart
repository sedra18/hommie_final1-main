import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/app/utils/app_colors.dart';


class UserPermissionsController extends GetxController {
  final box = GetStorage();

  // Current user approval status
  final RxBool isApproved = false.obs;
  final RxString userRole = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🔐 [UserPermissions] Controller Initialized');
    print('═══════════════════════════════════════════════════════════');
    
    // Load cached approval status
    loadApprovalStatus();
  }

  /// Load approval status from storage
  void loadApprovalStatus() {
    final approved = box.read('is_approved') ?? false;
    final role = box.read('role') ?? '';
    
    isApproved.value = approved;
    userRole.value = role;

    print('📦 [UserPermissions] Loaded from storage:');
    print('   Is Approved: $approved');
    print('   Role: $role');
    print('   Can Book: $canBook');
    print('   Can Post: $canPostApartments');
  }

  /// Update approval status (called after login/signup)
  void updateApprovalStatus(bool approved, String role) {
    isApproved.value = approved;
    userRole.value = role;
    
    // Save to storage
    box.write('is_approved', approved);
    box.write('role', role);

    print('');
    print('✅ [UserPermissions] Status Updated:');
    print('   Is Approved: $approved');
    print('   Role: $role');
    print('   Can Book: $canBook');
    print('   Can Post: $canPostApartments');
  }



  
  bool get canBook {
    final can = isApproved.value && userRole.value == 'renter';
    print('🔍 [UserPermissions] Can book: $can (approved=${isApproved.value}, role=${userRole.value})');
    return can;
  }

  /// Can user post apartments? (Owner + Approved)
  bool get canPostApartments {
    final can = isApproved.value && userRole.value == 'owner';
    print('🔍 [UserPermissions] Can post apartments: $can (approved=${isApproved.value}, role=${userRole.value})');
    return can;
  }

  /// Is user pending approval?
  bool get isPending {
    return !isApproved.value;
  }

  /// Is user owner?
  bool get isOwner {
    return userRole.value == 'owner';
  }

  /// Is user renter?
  bool get isRenter {
    return userRole.value == 'renter';
  }

  /// Check permission and show message if denied
  bool checkPermission(String action, {bool showMessage = true}) {
    bool hasPermission = false;
    String? denialMessage;

    switch (action.toLowerCase()) {
      case 'book':
        hasPermission = canBook;
        if (!hasPermission && isRenter) {
          denialMessage = '⏳ Your account is pending approval.\nYou cannot book apartments yet.';
        }
        break;
        
      case 'post':
      case 'post apartment':
        hasPermission = canPostApartments;
        if (!hasPermission && isOwner) {
          denialMessage = '⏳ Your account is pending approval.\nYou cannot post apartments yet.';
        }
        break;
        
      default:
        hasPermission = true;
    }

    if (!hasPermission && showMessage && denialMessage != null) {
      print('');
      print('🚫 [UserPermissions] Permission Denied: $action');
      print('   Reason: $denialMessage');
      
      Get.snackbar(
        '⏳ Pending Approval',
        denialMessage,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.hourglass_empty, color: Colors.white),
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }

    return hasPermission;
  }

  void showPendingApprovalMessage() {
    if (!isPending) return;

    final message = isRenter
        ? 'Your account is pending approval.\nYou can browse apartments but cannot book yet.'
        : 'Your account is pending approval.\nYou can view the app but cannot post apartments yet.';

    Get.snackbar(
      '⏳ Account Pending Approval',
      message,
      backgroundColor: AppColors.warning,
      colorText: AppColors.backgroundLight,
      icon: const Icon(Icons.hourglass_empty, color: Colors.white),
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
    );
  }

  /// Clear approval status (on logout)
  void clearApprovalStatus() {
    isApproved.value = false;
    userRole.value = '';
    box.remove('is_approved');
    box.remove('role');
    
    print('🗑️  [UserPermissions] Status cleared');
  }
}