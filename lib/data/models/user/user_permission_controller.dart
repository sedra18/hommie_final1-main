import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/app/utils/app_colors.dart';



class UserPermissionsController extends GetxController {
  final box = GetStorage();

  final RxBool isApproved = true.obs;
  final RxString userRole = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('');
    print('═══════════════════════════════════════════════════════════');
    print(' [UserPermissions] Controller Initialized');
    print('═══════════════════════════════════════════════════════════');
    
    loadApprovalStatus();
  }

  void loadApprovalStatus() {
    final approved = box.read('is_approved') ?? true;
    final role = box.read('role') ?? '';
    
    isApproved.value = approved;
    userRole.value = role;

    print('📦 [UserPermissions] Loaded from storage:');
    print('   Is Approved: $approved');
    print('   Role: $role');
    print('   Can Book: $canBook');
    print('   Can Post: $canPostApartments');
  }

  void updateApprovalStatus(bool approved, String role) {
    isApproved.value = approved;
    userRole.value = role;
    
    box.write('is_approved', approved);
    box.write('role', role);

    print('');
    print(' [UserPermissions] Status Updated:');
    print('   Is Approved: $approved');
    print('   Role: $role');
    print('   Can Book: $canBook');
    print('   Can Post: $canPostApartments');
  }

  //  FIXED: Both owners and renters can book apartments

  bool get canBook {
    // Anyone who is approved can book (owners OR renters)
    final can = isApproved.value && (userRole.value == 'renter' || userRole.value == 'owner');
    print('🔍 [UserPermissions] Can book: $can (approved=${isApproved.value}, role=${userRole.value})');
    return can;
  }

  /// Can user post apartments? (Owner + Approved only)
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

  // ═══════════════════════════════════════════════════════════
  //  UPDATED: Check if user can book a specific apartment
  // Prevents owners from booking their own apartments
  // ═══════════════════════════════════════════════════════════
  bool canBookApartment(int? apartmentOwnerId) {
    // Must be approved first
    if (!isApproved.value) {
      return false;
    }
    
    // Get current user ID from storage
    final currentUserId = box.read('user_id') as int?;
    
    // If we don't know the apartment owner, allow booking
    // (The backend will validate ownership)
    if (apartmentOwnerId == null || currentUserId == null) {
      return isApproved.value;
    }
    
    // Can't book your own apartment
    if (apartmentOwnerId == currentUserId) {
      print(' Cannot book own apartment');
      return false;
    }
    
    // Approved users can book other people's apartments
    return true;
  }

  /// Check permission and show message if denied
  bool checkPermission(String action, {bool showMessage = true, int? apartmentOwnerId}) {
    bool hasPermission = false;
    String? denialMessage;

    switch (action.toLowerCase()) {
      case 'book':
        // Check if user can book this specific apartment
        if (apartmentOwnerId != null) {
          hasPermission = canBookApartment(apartmentOwnerId);
          
          if (!hasPermission && isApproved.value) {
            final currentUserId = box.read('user_id') as int?;
            if (apartmentOwnerId == currentUserId) {
              denialMessage = '❌ You cannot book your own apartment.';
            }
          } else if (!hasPermission && !isApproved.value) {
            denialMessage = '⏳ Your account is pending approval.\nYou cannot book apartments yet.';
          }
        } else {
          // General booking permission (no specific apartment)
          hasPermission = canBook;
          if (!hasPermission) {
            denialMessage = '⏳ Your account is pending approval.\nYou cannot book apartments yet.';
          }
        }
        break;
        
      case 'post':
      case 'post apartment':
        hasPermission = canPostApartments;
        if (!hasPermission && isOwner) {
          denialMessage = '⏳ Your account is pending approval.\nYou cannot post apartments yet.';
        } else if (!hasPermission && isRenter) {
          denialMessage = '❌ Only property owners can post apartments.';
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
        denialMessage.contains('⏳') ? '⏳ Pending Approval' : '❌ Not Allowed',
        denialMessage,
        backgroundColor: denialMessage.contains('⏳') ? Colors.orange : Colors.red,
        colorText: Colors.white,
        icon: Icon(
          denialMessage.contains('⏳') ? Icons.hourglass_empty : Icons.block,
          color: Colors.white,
        ),
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

  void clearApprovalStatus() {
    isApproved.value = false;
    userRole.value = '';
    box.remove('is_approved');
    box.remove('role');
    
    print('🗑️  [UserPermissions] Status cleared');
  }
}