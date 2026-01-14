import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/models/bookings/bookings_request_model.dart';
import 'package:hommie/data/services/bookings_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/helpers/base_url.dart';

// ═══════════════════════════════════════════════════════════
// OWNER DASHBOARD CONTROLLER - WITH PROFILE DATA
// ✅ Fetches user profile data for each booking
// ✅ Gets name and avatar from profile API
// ✅ Updates booking model with profile data
// ═══════════════════════════════════════════════════════════

class OwnerDashboardController extends GetxController {
  final BookingService _bookingService = Get.find<BookingService>();
  final box = GetStorage();

  final RxList<BookingRequestModel> pendingRequests =
      <BookingRequestModel>[].obs;
  final RxList<BookingRequestModel> approvedRequests =
      <BookingRequestModel>[].obs;
  final RxList<BookingRequestModel> rejectedRequests =
      <BookingRequestModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;

  // ✅ Cache for user profile data
  final RxMap<int, Map<String, dynamic>> userProfileCache = 
      <int, Map<String, dynamic>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllRequests();
  }

  // ═══════════════════════════════════════════════════════════
  // FETCH USER PROFILE DATA
  // ✅ Gets profile data from API
  // ✅ Caches results to avoid duplicate requests
  // ═══════════════════════════════════════════════════════════

  Future<Map<String, dynamic>?> fetchUserProfile(int userId) async {
    try {
      // Check cache first
      if (userProfileCache.containsKey(userId)) {
        print('   ✅ Using cached profile for user $userId');
        return userProfileCache[userId];
      }

      final token = box.read('access_token');
      if (token == null) {
        print('   ❌ No access token');
        return null;
      }

      print('   📡 Fetching profile for user $userId...');

      final response = await http.get(
        Uri.parse('${BaseUrl.pubBaseUrl}/api/users/$userId/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final profileData = {
          'name': data['data']?['name'] ?? 'Unknown User',
          'avatar': data['data']?['avatar'],
          'email': data['data']?['email'],
          'phone': data['data']?['phone'],
        };
        
        // Cache the result
        userProfileCache[userId] = profileData;
        
        print('   ✅ Profile fetched: ${profileData['name']}');
        return profileData;
      } else {
        print('   ⚠️ Failed to fetch profile: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('   ❌ Error fetching profile: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // GET AVATAR URL
  // ✅ Returns full URL for avatar or null
  // ═══════════════════════════════════════════════════════════

  String? getAvatarUrl(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) return null;
    
    // If already a full URL
    if (avatarPath.startsWith('http')) {
      return avatarPath;
    }
    
    // Build full URL
    return '${BaseUrl.pubBaseUrl}/$avatarPath';
  }

  // ═══════════════════════════════════════════════════════════
  // ENRICH BOOKING WITH PROFILE DATA
  // ✅ Fetches profile and updates booking model
  // ═══════════════════════════════════════════════════════════

  Future<BookingRequestModel> enrichBookingWithProfile(
    BookingRequestModel booking,
  ) async {
    if (booking.userId == null) {
      return booking;
    }

    final profile = await fetchUserProfile(booking.userId!);
    
    if (profile != null) {
      // Update the booking model with profile data
      booking.userName = profile['name'];
      booking.userAvatar = getAvatarUrl(profile['avatar']);
    }
    
    return booking;
  }

  // ═══════════════════════════════════════════════════════════
  // LOAD ALL BOOKING REQUESTS
  // ✅ Fetches bookings and enriches with profile data
  // ═══════════════════════════════════════════════════════════

  Future<void> loadAllRequests() async {
    isLoading.value = true;

    try {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('🔍 [OWNER DASHBOARD] Loading all booking requests...');
      print('═══════════════════════════════════════════════════════════');

      // Get all bookings
      final allRequests = await _bookingService.getMyBookings();
      print('📦 Received ${allRequests.length} total requests');

      // ✅ Enrich each booking with profile data
      print('\n📥 Fetching user profiles...');
      final enrichedRequests = <BookingRequestModel>[];
      
      for (var booking in allRequests) {
        final enriched = await enrichBookingWithProfile(booking);
        enrichedRequests.add(enriched);
      }

      // Filter by status
      pendingRequests.value = enrichedRequests.where((b) {
        final status = b.status?.toLowerCase() ?? '';
        return status == 'pending_owner_approval' || status == 'pending';
      }).toList();

      approvedRequests.value = enrichedRequests.where((b) {
        final status = b.status?.toLowerCase() ?? '';
        return status == 'approved' || status == 'confirmed';
      }).toList();

      rejectedRequests.value = enrichedRequests.where((b) {
        final status = b.status?.toLowerCase() ?? '';
        return status == 'rejected' || status == 'declined';
      }).toList();

      print('');
      print('📊 REQUESTS BY STATUS:');
      print('   Pending: ${pendingRequests.length}');
      print('   Approved: ${approvedRequests.length}');
      print('   Rejected: ${rejectedRequests.length}');
      
      if (pendingRequests.isNotEmpty) {
        print('\n   📋 Pending requests:');
        for (var req in pendingRequests) {
          print('     - ${req.userName ?? "Unknown"} (ID: ${req.id})');
          if (req.userAvatar != null) {
            print('       Avatar: ${req.userAvatar}');
          }
        }
      }
      print('═══════════════════════════════════════════════════════════');
    } catch (e, stackTrace) {
      print('❌ Error loading requests: $e');
      print('Stack trace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
      print('═══════════════════════════════════════════════════════════');

      Get.snackbar(
        'Error',
        'Failed to load booking requests',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // REFRESH REQUESTS
  // ═══════════════════════════════════════════════════════════

  Future<void> refreshRequests() async {
    isRefreshing.value = true;
    
    // Clear cache to get fresh data
    userProfileCache.clear();
    
    await loadAllRequests();
    isRefreshing.value = false;
  }

  // Alias for compatibility
  Future<void> loadPendingRequests() async {
    await loadAllRequests();
  }

  // ═══════════════════════════════════════════════════════════
  // APPROVE A BOOKING REQUEST
  // ═══════════════════════════════════════════════════════════

  Future<void> approveRequest(BookingRequestModel request) async {
    if (request.id == null) {
      print('❌ Cannot approve request: ID is null');
      Get.snackbar(
        'Error',
        'Invalid booking request',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('✅ [APPROVE] Approving booking request');
      print('   Request ID: ${request.id}');
      print('   User: ${request.userName ?? "Unknown"}');
      print('──────────────────────────────────────────────────────────');

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final success = await _bookingService.approveBooking(request.id!);
      Get.back(); // Close loading dialog

      if (success) {
        print('✅ Booking approved successfully');
        print('═══════════════════════════════════════════════════════════');

        // Refresh lists
        await loadAllRequests();

        Get.snackbar(
          'Success',
          'Booking request approved for ${request.userName ?? "user"}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 2),
        );
      } else {
        print('❌ Failed to approve booking');
        print('═══════════════════════════════════════════════════════════');

        Get.snackbar(
          'Error',
          'Failed to approve request',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Error approving: $e');
      print('═══════════════════════════════════════════════════════════');

      Get.back(); // Close loading dialog if still open
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // REJECT A BOOKING REQUEST
  // ═══════════════════════════════════════════════════════════

  Future<void> rejectRequest(BookingRequestModel request) async {
    if (request.id == null) {
      print('❌ Cannot reject request: ID is null');
      Get.snackbar(
        'Error',
        'Invalid booking request',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Reject Request'),
        content: Text(
          'Are you sure you want to reject ${request.userName ?? "this user"}\'s booking request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('❌ [REJECT] Rejecting booking request');
      print('   Request ID: ${request.id}');
      print('   User: ${request.userName ?? "Unknown"}');
      print('──────────────────────────────────────────────────────────');

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final success = await _bookingService.rejectBooking(request.id!);
      Get.back(); // Close loading dialog

      if (success) {
        print('✅ Booking rejected successfully');
        print('═══════════════════════════════════════════════════════════');

        // Refresh lists
        await loadAllRequests();

        Get.snackbar(
          'Rejected',
          'Booking request rejected',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          icon: const Icon(Icons.block, color: Colors.white),
          duration: const Duration(seconds: 2),
        );
      } else {
        print('❌ Failed to reject booking');
        print('═══════════════════════════════════════════════════════════');

        Get.snackbar(
          'Error',
          'Failed to reject request',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Error rejecting: $e');
      print('═══════════════════════════════════════════════════════════');

      Get.back(); // Close loading dialog if still open
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // GO TO MESSAGES WITH USER
  // ═══════════════════════════════════════════════════════════

  void goToMessages(BookingRequestModel request) {
    if (request.userId == null) {
      print('❌ Cannot open messages: User ID is null');
      Get.snackbar(
        'Error',
        'User information not available',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    print('💬 Opening messages with ${request.userName ?? "user"}');

    // Navigate to messages screen with user ID
    Get.toNamed(
      '/messages',
      arguments: {
        'userId': request.userId,
        'userName': request.userName,
        'userAvatar': request.userAvatar,
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CLEAR PROFILE CACHE
  // ✅ Useful when user data might have changed
  // ═══════════════════════════════════════════════════════════

  void clearProfileCache() {
    userProfileCache.clear();
    print('🗑️ Profile cache cleared');
  }

  // ═══════════════════════════════════════════════════════════
  // HELPER GETTERS
  // ═══════════════════════════════════════════════════════════

  /// Get count of pending requests
  int get pendingCount => pendingRequests.length;

  /// Get count of approved requests
  int get approvedCount => approvedRequests.length;

  /// Get count of rejected requests
  int get rejectedCount => rejectedRequests.length;

  /// Check if there are any pending requests
  bool get hasPendingRequests => pendingRequests.isNotEmpty;
}