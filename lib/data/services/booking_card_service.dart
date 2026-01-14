import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/models/apartment/apartment_model.dart';
import 'package:hommie/data/services/token_storage_service.dart';
import 'package:hommie/data/services/approval_status_service.dart';

// ═══════════════════════════════════════════════════════════
// BOOKING CARD SERVICE - FIXED
// ✅ Fixed belongsToUser method call
// Prevents owners from booking their own apartments
// Checks approval status before allowing bookings
// Shows appropriate messages for different scenarios
// ═══════════════════════════════════════════════════════════

class BookingCardService extends GetxService {
  final _tokenService = Get.put(TokenStorageService());
  final _approvalService = Get.put(ApprovalStatusService());

  // ═══════════════════════════════════════════════════════════
  // CAN BOOK APARTMENT
  // Returns true if user can book, false otherwise
  // Shows appropriate snackbar message for each case
  // ═══════════════════════════════════════════════════════════
  
  Future<bool> canBookApartment(ApartmentModel apartment) async {
    // 1. Check if user is approved
    if (!_approvalService.canPerformAction()) {
      return false; // Message already shown by approval service
    }

    // 2. Get current user ID
    final currentUserId = await _tokenService.getUserId();
    
    if (currentUserId == null) {
      _showErrorSnackbar(
        'Authentication Error',
        'Please log in again to continue.',
      );
      return false;
    }

    // 3. ✅ FIXED: Check if user is trying to book their own apartment
    // Compare userId directly instead of using belongsToUser()
    if (apartment.userId != null && apartment.userId == currentUserId) {
      _showOwnerCannotBookSnackbar();
      return false;
    }

    // All checks passed
    return true;
  }

  // ═══════════════════════════════════════════════════════════
  // CAN ACCESS FEATURE
  // Generic check for feature access based on approval status
  // ═══════════════════════════════════════════════════════════
  
  bool canAccessFeature() {
    return _approvalService.canPerformAction();
  }

  // ═══════════════════════════════════════════════════════════
  // SHOW OWNER CANNOT BOOK SNACKBAR
  // Specific message when owner tries to book own apartment
  // ═══════════════════════════════════════════════════════════
  
  void _showOwnerCannotBookSnackbar() {
    Get.snackbar(
      'Cannot Book',
      'You cannot book your own apartment. This listing belongs to you.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      backgroundColor: const Color(0xFFF59E0B),
      colorText: const Color(0xFFFFFFFF),
      icon: const Icon(
        Icons.block,
        color: Color(0xFFFFFFFF),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SHOW ERROR SNACKBAR
  // Generic error message
  // ═══════════════════════════════════════════════════════════
  
  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      backgroundColor: const Color(0xFFEF4444),
      colorText: const Color(0xFFFFFFFF),
      icon: const Icon(
        Icons.error_outline,
        color: Color(0xFFFFFFFF),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SHOW PENDING APPROVAL WARNING
  // Specific message for pending requests screen
  // ✅ FIXED: Added .value to access RxBool
  // ═══════════════════════════════════════════════════════════
  
  void showPendingRequestsWarning() {
    // ✅ FIX: Added .value to access RxBool
    if (_approvalService.isPending.value) {
      Get.snackbar(
        'Approval Required',
        'Your account is pending approval. Pending requests will appear here once your account is approved.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
        backgroundColor: const Color(0xFFF59E0B),
        colorText: const Color(0xFFFFFFFF),
        icon: const Icon(
          Icons.schedule,
          color: Color(0xFFFFFFFF),
        ),
      );
    }
  }
}