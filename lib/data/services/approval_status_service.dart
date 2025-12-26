import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/helpers/base_url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ═══════════════════════════════════════════════════════════
// APPROVAL STATUS SERVICE
// Periodically checks if owner is approved and updates app state
// ═══════════════════════════════════════════════════════════

class ApprovalStatusService extends GetxService {
  final box = GetStorage();
  Timer? _pollTimer;
  
  // Observable approval status
  final isApproved = false.obs;
  final isPolling = false.obs;
  
  // Polling interval (check every 30 seconds)
  static const pollInterval = Duration(seconds: 30);
  
  @override
  void onInit() {
    super.onInit();
    
    // Initialize from storage
    final storedApproval = box.read('is_approved');
    isApproved.value = storedApproval == true;
    
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('👁️  APPROVAL STATUS SERVICE - INITIALIZED');
    print('   Initial approval status: ${isApproved.value}');
    print('═══════════════════════════════════════════════════════════');
  }
  
  // ═══════════════════════════════════════════════════════════
  // START POLLING (call when owner is not approved)
  // ═══════════════════════════════════════════════════════════
  void startPolling() {
    if (isApproved.value) {
      print('✅ Already approved - no need to poll');
      return;
    }
    
    if (_pollTimer != null && _pollTimer!.isActive) {
      print('⚠️  Polling already active');
      return;
    }
    
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🔄 STARTING APPROVAL POLLING');
    print('   Interval: ${pollInterval.inSeconds} seconds');
    print('═══════════════════════════════════════════════════════════');
    
    isPolling.value = true;
    
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
  // CHECK APPROVAL STATUS (API call)
  // ═══════════════════════════════════════════════════════════
  Future<void> checkApprovalStatus() async {
    try {
      final token = box.read('access_token');
      if (token == null) {
        print('⚠️  No token - cannot check approval');
        stopPolling();
        return;
      }
      
      print('🔍 Checking approval status...');
      
      final url = Uri.parse('${BaseUrl.pubBaseUrl}/api/user/profile');
      
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Extract approval status
        bool newApprovalStatus = false;
        
        if (data['user'] != null) {
          newApprovalStatus = data['user']['is_approved'] == true ||
                             data['user']['is_approved'] == 1;
        } else if (data['is_approved'] != null) {
          newApprovalStatus = data['is_approved'] == true ||
                             data['is_approved'] == 1;
        }
        
        // Check if status changed
        if (newApprovalStatus != isApproved.value) {
          print('');
          print('═══════════════════════════════════════════════════════════');
          print('🎉 APPROVAL STATUS CHANGED!');
          print('   Old: ${isApproved.value}');
          print('   New: $newApprovalStatus');
          print('═══════════════════════════════════════════════════════════');
          
          // Update status
          isApproved.value = newApprovalStatus;
          box.write('is_approved', newApprovalStatus);
          
          if (newApprovalStatus) {
            // Stop polling when approved
            stopPolling();
            
            // Show success message
            Get.snackbar(
              '🎉 تهانينا!',
              'تمت الموافقة على حسابك! يمكنك الآن إضافة شقق',
              snackPosition: SnackPosition.TOP,
              backgroundColor: AppColors.success,
              colorText: AppColors.backgroundLight,
              duration: const Duration(seconds: 5),
              icon: const Icon(Icons.check_circle, color: Colors.white, size: 32),
              margin: const EdgeInsets.all(16),
            );
          }
        } else {
          print('   Status unchanged: ${isApproved.value}');
        }
      } else {
        print('⚠️  Check failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error checking approval: $e');
    }
  }
  
  // ═══════════════════════════════════════════════════════════
  // MANUAL REFRESH (for "Check Status" button)
  // ═══════════════════════════════════════════════════════════
  Future<void> manualRefresh() async {
    print('🔄 Manual approval status refresh requested');
    await checkApprovalStatus();
  }
  
  @override
  void onClose() {
    stopPolling();
    super.onClose();
  }
}

// ═══════════════════════════════════════════════════════════
// HELPER TO INITIALIZE SERVICE IN MAIN
// ═══════════════════════════════════════════════════════════
// Add to main.dart:
// Get.put(ApprovalStatusService());