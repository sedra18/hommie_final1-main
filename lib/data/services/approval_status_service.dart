import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/helpers/base_url.dart';
import 'package:http/http.dart' as http;
import 'package:hommie/data/services/token_storage_service.dart';

// ═══════════════════════════════════════════════════════════
// APPROVAL STATUS SERVICE - FIXED VERSION
// Properly refreshes UI after approval status changes
// ═══════════════════════════════════════════════════════════

class ApprovalStatusService extends GetxService {
  static  String _baseUrl = '${BaseUrl.pubBaseUrl}/api'; // ✅ Use 10.0.2.2 for emulator
  
  // ✅ Observable (Rx) instead of static variable
  final isApproved = false.obs;
  final _isCheckingApproval = false.obs;
  final _userRole = ''.obs;
  final _approvalStatus = 'unknown'.obs; // 'pending', 'approved', 'rejected', 'unknown'
  
  bool get isCheckingApproval => _isCheckingApproval.value;
  String get userRole => _userRole.value;
  String get approvalStatus => _approvalStatus.value;
  
  bool get isPending => _approvalStatus.value == 'pending';
  bool get isRejected => _approvalStatus.value == 'rejected';

  // ═══════════════════════════════════════════════════════════
  // CHECK USER APPROVAL STATUS
  // Called on login and can be refreshed on demand
  // ═══════════════════════════════════════════════════════════
  
  Future<void> checkApprovalStatus() async {
    try {
      _isCheckingApproval.value = true;
      
      final tokenService = Get.put(TokenStorageService());
      final token = await tokenService.getAccessToken();
      
      if (token == null) {
        print('⚠️ No token found, cannot check approval status');
        _approvalStatus.value = 'unknown';
        isApproved.value = false;
        return;
      }

      print('🔍 Checking approval status...');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/user/approval-status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Parse approval status from backend
        final status = data['approval_status'] ?? 'unknown';
        _userRole.value = data['role'] ?? '';
        _approvalStatus.value = status.toString().toLowerCase();
        
        // Update isApproved observable
        final wasApproved = isApproved.value;
        isApproved.value = (_approvalStatus.value == 'approved');
        
        print('✅ Approval Status: ${_approvalStatus.value}');
        print('✅ User Role: ${_userRole.value}');
        print('✅ Is Approved: ${isApproved.value}');
        
        // ✅ Force UI update if status changed
        if (wasApproved != isApproved.value) {
          print('🔄 Approval status changed! Forcing UI update...');
          isApproved.refresh();
        }
      } else if (response.statusCode == 404) {
        print('⚠️ Approval endpoint not found (404)');
        _approvalStatus.value = 'unknown';
        isApproved.value = false;
      } else {
        print('⚠️ Failed to check approval status: ${response.statusCode}');
        _approvalStatus.value = 'unknown';
        isApproved.value = false;
      }
    } catch (e) {
      print('❌ Error checking approval status: $e');
      _approvalStatus.value = 'unknown';
      isApproved.value = false;
    } finally {
      _isCheckingApproval.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // REFRESH APPROVAL STATUS
  // Used in PendingApprovalScreen and when user manually refreshes
  // ═══════════════════════════════════════════════════════════
  
  Future<void> refreshApprovalStatus() async {
    print('🔄 Manual refresh triggered...');
    
    await checkApprovalStatus();
    
    // ✅ Force UI rebuild
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Show appropriate message based on new status
    if (isApproved.value) {
      Get.snackbar(
        'Approved!',
        'Your account has been approved. You can now access all features.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF22C55E),
        colorText: const Color(0xFFFFFFFF),
        icon: const Icon(
          Icons.check_circle,
          color: Color(0xFFFFFFFF),
        ),
        duration: const Duration(seconds: 3),
      );
      
      // ✅ Close any pending approval dialogs/screens
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      // ✅ Trigger complete app refresh
      print('🔄 Triggering app-wide refresh...');
      Get.forceAppUpdate();
      
    } else if (isPending) {
      Get.snackbar(
        'Still Pending',
        'Your account is still pending approval. Please check back later.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFF59E0B),
        colorText: const Color(0xFFFFFFFF),
        icon: const Icon(
          Icons.schedule,
          color: Color(0xFFFFFFFF),
        ),
      );
    } else if (isRejected) {
      showRejectionMessage();
    }
  }

  // ═══════════════════════════════════════════════════════════
  // MANUAL REFRESH (for PendingApprovalWidget)
  // Same as refreshApprovalStatus but different name for compatibility
  // ═══════════════════════════════════════════════════════════
  
  Future<void> manualRefresh() async {
    await refreshApprovalStatus();
  }

  // ═══════════════════════════════════════════════════════════
  // SHOW APPROVAL PENDING MESSAGE
  // Returns snackbar message based on user role
  // ═══════════════════════════════════════════════════════════
  
  void showPendingApprovalMessage() {
    final message = _userRole.value == 'owner'
        ? 'Your owner account is pending approval. You cannot add apartments or access certain features until approved.'
        : 'Your renter account is pending approval. You cannot book apartments or access certain features until approved.';
    
    Get.snackbar(
      'Approval Pending',
      message,
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

  // ═══════════════════════════════════════════════════════════
  // SHOW REJECTION MESSAGE
  // ═══════════════════════════════════════════════════════════
  
  void showRejectionMessage() {
    Get.snackbar(
      'Account Rejected',
      'Your account has been rejected. Please contact support for more information.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      backgroundColor: const Color(0xFFEF4444),
      colorText: const Color(0xFFFFFFFF),
      icon: const Icon(
        Icons.cancel,
        color: Color(0xFFFFFFFF),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // RESET STATUS (for logout)
  // ═══════════════════════════════════════════════════════════
  
  void resetStatus() {
    _approvalStatus.value = 'unknown';
    isApproved.value = false;
    _userRole.value = '';
    print('🔄 Approval status reset');
  }

  // ═══════════════════════════════════════════════════════════
  // CHECK IF USER CAN PERFORM ACTION
  // Returns true if approved, shows message if not
  // ═══════════════════════════════════════════════════════════
  
  bool canPerformAction() {
    if (isPending) {
      showPendingApprovalMessage();
      return false;
    }
    
    if (isRejected) {
      showRejectionMessage();
      return false;
    }
    
    return isApproved.value;
  }
}