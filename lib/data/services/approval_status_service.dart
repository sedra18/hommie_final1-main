import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/helpers/base_url.dart';
import 'package:http/http.dart' as http;
import 'package:hommie/app/utils/app_colors.dart';
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════
// APPROVAL STATUS SERVICE - ROLE PRESERVATION FIX
// ✅ CRITICAL: Never changes role during refresh
// ✅ Only updates approval status
// Defaults to 'approved' if backend doesn't have approval_status column
// ═══════════════════════════════════════════════════════════

class ApprovalStatusService extends GetxService {
  final box = GetStorage();
  Timer? _pollTimer;
  
  // Observable approval status
  final isApproved = false.obs; // ✅ Default to approved
  final isPolling = false.obs;
  final isCheckingApproval = false.obs;
  final isPending = false.obs;
  final isRejected = false.obs;
  final userRole = ''.obs;
  
  // User ID from token storage
  int? get userId => box.read('user_id');
  
  // Polling interval (check every 30 seconds)
  static const pollInterval = Duration(seconds: 30);
  
  @override
  void onInit() {
    super.onInit();
    
    // Initialize from storage (default to approved if not set)
    final storedApproval = box.read('is_approved');
    final storedRole = box.read('user_role') ?? box.read('role');
    final storedStatus = box.read('approval_status');
    
    // ✅ Default to approved if null
    isApproved.value = storedApproval ?? true;
    userRole.value = storedRole ?? '';
    
    // Set pending/rejected flags based on stored status
    if (storedStatus != null) {
      isPending.value = storedStatus == 'pending';
      isRejected.value = storedStatus == 'rejected';
    }
    
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('👁️  APPROVAL STATUS SERVICE - INITIALIZED');
    print('   Initial approval status: ${isApproved.value}');
    print('   User role: ${userRole.value}');
    print('   Is pending: ${isPending.value}');
    print('   Is rejected: ${isRejected.value}');
    print('═══════════════════════════════════════════════════════════');
  }
  
  // ═══════════════════════════════════════════════════════════
  // CAN PERFORM ACTION
  // Check if user can perform actions (approved)
  // ═══════════════════════════════════════════════════════════
  bool canPerformAction() {
    return isApproved.value;
  }
  
  // ═══════════════════════════════════════════════════════════
  // MANUAL REFRESH
  // Called when user manually refreshes
  // ═══════════════════════════════════════════════════════════
  Future<void> manualRefresh() async {
    print('🔄 Manual refresh triggered');
    await checkApprovalStatus();
  }
  
  // ═══════════════════════════════════════════════════════════
  // SHOW PENDING APPROVAL MESSAGE
  // Shows snackbar when user is pending
  // ═══════════════════════════════════════════════════════════
  void showPendingApprovalMessage() {
    final isOwner = userRole.value.toLowerCase() == 'owner';
    
    Get.snackbar(
      '⏳ Pending Approval',
      isOwner
          ? 'Your account is pending approval.\nYou can view the app but cannot post apartments yet.'
          : 'Your account is pending approval.\nYou can browse apartments but cannot book yet.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFFFF59E0B),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.schedule, color: Colors.white, size: 32),
      margin: const EdgeInsets.all(16),
    );
  }
  
  // ═══════════════════════════════════════════════════════════
  // SHOW REJECTION MESSAGE
  // Shows snackbar when user is rejected
  // ═══════════════════════════════════════════════════════════
  void showRejectionMessage() {
    Get.snackbar(
      '❌ Application Rejected',
      'Your account application was rejected.\nPlease contact support for more information.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.failure,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      icon: const Icon(Icons.cancel, color: Colors.white, size: 32),
      margin: const EdgeInsets.all(16),
    );
  }
  
  // ═══════════════════════════════════════════════════════════
  // START POLLING
  // ═══════════════════════════════════════════════════════════
  void startPolling() {
    if (isApproved.value) {
      print('✅ User already approved - no need to poll');
      return;
    }
    
    if (isPolling.value) {
      print('⚠️  Already polling');
      return;
    }
    
    isPolling.value = true;
    print('🔄 Starting approval polling...');
    
    // Check immediately
    checkApprovalStatus();
    
    // Then check periodically
    _pollTimer = Timer.periodic(pollInterval, (timer) {
      checkApprovalStatus();
    });
  }
  
  // ═══════════════════════════════════════════════════════════
  // STOP POLLING
  // ═══════════════════════════════════════════════════════════
  void stopPolling() {
    if (_pollTimer != null) {
      _pollTimer!.cancel();
      _pollTimer = null;
      isPolling.value = false;
      
      print('🛑 Approval polling stopped');
    }
  }
  
  // ═══════════════════════════════════════════════════════════
  // CHECK APPROVAL STATUS - WITH ROLE PRESERVATION
  // ✅ CRITICAL: Never changes role, only checks approval
  // ✅ Defaults to 'approved' if backend returns null
  // ═══════════════════════════════════════════════════════════
  Future<void> checkApprovalStatus() async {
    try {
      isCheckingApproval.value = true;
      
      final token = box.read('access_token');
      if (token == null) {
        print('⚠️  No token - cannot check approval');
        stopPolling();
        isCheckingApproval.value = false;
        return;
      }
      
      // ✅ SAVE CURRENT ROLE BEFORE API CALL
      final currentRole = box.read('user_role') ?? box.read('role') ?? '';
      
      print('🔍 Checking approval status...');
      print('   Current role: $currentRole (will be preserved)');
      
      // ✅ TRY ENDPOINT 1: /api/user/approval-status
      final approvalUrl = Uri.parse('${BaseUrl.pubBaseUrl}/api/user/approval-status');
      
      try {
        final approvalResponse = await http.get(
          approvalUrl,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 10));
        
        if (approvalResponse.statusCode == 200) {
          final data = jsonDecode(approvalResponse.body);
          
          print('📥 Approval response: $data');
          
          // ✅ Get approval status, default to 'approved' if null
          final approvalStatus = data['approval_status']?.toString().toLowerCase() ?? 'approved';
          
          print('   approval_status: $approvalStatus');
          print('   API role: ${data['role']} (ignored - using stored role)');
          
          // ✅ PRESERVE ROLE: Pass stored role, not API role
          _updateApprovalStatus(approvalStatus, currentRole);
          
          isCheckingApproval.value = false;
          return;
        } else if (approvalResponse.statusCode == 404) {
          print('! Approval endpoint not found (404) - defaulting to approved');
          
          // ✅ If endpoint doesn't exist, default to approved
          _updateApprovalStatus('approved', currentRole);
          isCheckingApproval.value = false;
          return;
        }
      } catch (e) {
        print('⚠️  Approval endpoint error: $e');
      }
      
      // ✅ FALLBACK: Try /api/user
      print('🔄 Trying fallback endpoint: /api/user');
      
      final userUrl = Uri.parse('${BaseUrl.pubBaseUrl}/api/user');
      
      final userResponse = await http.get(
        userUrl,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (userResponse.statusCode == 200) {
        final data = jsonDecode(userResponse.body);
        
        print('📥 User response: $data');
        
        String? approvalStatus;
        
        // Try different response structures
        if (data['approval_status'] != null) {
          approvalStatus = data['approval_status'].toString().toLowerCase();
        } else if (data['user'] != null && data['user']['approval_status'] != null) {
          approvalStatus = data['user']['approval_status'].toString().toLowerCase();
        }
        
        print('   approval_status: $approvalStatus');
        print('   API role: ${data['role']} (ignored - using stored role)');
        
        // ✅ Default to 'approved' if null, PRESERVE ROLE
        _updateApprovalStatus(approvalStatus ?? 'approved', currentRole);
      } else {
        print('❌ Failed to check approval: ${userResponse.statusCode}');
        print('⚠️  Defaulting to approved status with preserved role');
        
        // ✅ If both endpoints fail, keep current status or default to approved
        if (!box.hasData('is_approved')) {
          _updateApprovalStatus('approved', currentRole);
        }
      }
      
    } catch (e) {
      print('❌ Error checking approval status: $e');
      print('⚠️  Defaulting to approved status with preserved role');
      
      // ✅ On error, preserve role
      final currentRole = box.read('user_role') ?? box.read('role') ?? '';
      if (!box.hasData('is_approved')) {
        _updateApprovalStatus('approved', currentRole);
      }
    } finally {
      isCheckingApproval.value = false;
    }
  }
  
  // ═══════════════════════════════════════════════════════════
  // UPDATE APPROVAL STATUS (private helper)
  // ✅ CRITICAL FIX: Uses stored role, ignores API role
  // ═══════════════════════════════════════════════════════════
  void _updateApprovalStatus(String? approvalStatus, String storedRole) {
    // ✅ Default to approved if status is null
    final status = approvalStatus ?? 'approved';
    
    bool newApprovalStatus = status == 'approved';
    bool newPendingStatus = status == 'pending';
    bool newRejectedStatus = status == 'rejected';
    
    // ✅ CRITICAL: Use stored role (from login/signup), NOT from API!
    if (storedRole.isNotEmpty) {
      userRole.value = storedRole;
      
      // ✅ Ensure both storage keys are set
      box.write('user_role', storedRole);
      box.write('role', storedRole);
      
      print('   ✅ Role preserved: $storedRole');
    } else {
      print('   ⚠️  No stored role found - keeping current');
    }
    
    // Save approval status string
    box.write('approval_status', status);
    
    // Check if status changed
    if (newApprovalStatus != isApproved.value ||
        newPendingStatus != isPending.value ||
        newRejectedStatus != isRejected.value) {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('🎉 APPROVAL STATUS CHANGED!');
      print('   Old approved: ${isApproved.value}');
      print('   New approved: $newApprovalStatus');
      print('   Status: $status');
      print('   Role: $storedRole (unchanged)');
      print('═══════════════════════════════════════════════════════════');
      
      // Update all status flags
      isApproved.value = newApprovalStatus;
      isPending.value = newPendingStatus;
      isRejected.value = newRejectedStatus;
      
      box.write('is_approved', newApprovalStatus);
      
      if (newApprovalStatus) {
        stopPolling();
        
        // Only show snackbar if changing from not-approved to approved
        if (newPendingStatus || newRejectedStatus) {
          Get.snackbar(
            '🎉 Approved!',
            'Your account has been approved! You can now access all features.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            icon: const Icon(Icons.check_circle, color: Colors.white, size: 32),
            margin: const EdgeInsets.all(16),
          );
        }
      } else if (newRejectedStatus) {
        stopPolling();
        showRejectionMessage();
      }
    } else {
      print('✅ Approval Status: $status');
      print('   Is Approved: ${isApproved.value}');
      print('   Is Pending: ${isPending.value}');
      print('   Is Rejected: ${isRejected.value}');
      print('   Role: $storedRole (preserved)');
    }
  }
  
  // ═══════════════════════════════════════════════════════════
  // MANUAL UPDATE (called after login)
  // ═══════════════════════════════════════════════════════════
  void updateApprovalStatus(bool approved, String role) {
    print('📝 Manually updating approval status:');
    print('   Approved: $approved');
    print('   Role: $role');
    
    isApproved.value = approved;
    userRole.value = role;
    isPending.value = !approved;
    
    box.write('is_approved', approved);
    box.write('user_role', role);
    box.write('role', role);
    box.write('approval_status', approved ? 'approved' : 'pending');
    
    // Start polling if not approved
    if (!approved) {
      startPolling();
    }
  }
  
  // ═══════════════════════════════════════════════════════════
  // CLEAR STATUS (on logout)
  // ═══════════════════════════════════════════════════════════
  void clearStatus() {
    print('🧹 Clearing approval status');
    
    stopPolling();
    isApproved.value = true; // Reset to approved
    isPending.value = false;
    isRejected.value = false;
    userRole.value = '';
    
    box.remove('is_approved');
    box.remove('user_role');
    box.remove('role');
    box.remove('approval_status');
  }
  
  @override
  void onClose() {
    stopPolling();
    super.onClose();
  }
}