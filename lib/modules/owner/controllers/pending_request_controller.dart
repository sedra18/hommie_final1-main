import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/models/bookings/bookings_request_model.dart';
import 'package:hommie/data/services/bookings_service.dart';

// ═══════════════════════════════════════════════════════════
// OWNER DASHBOARD CONTROLLER - CORRECTED
// ✅ Uses correct BookingService method names:
//    - getPendingBookings() instead of getPendingRequests()
//    - approveBooking() instead of approveRequest()
//    - rejectBooking() instead of rejectRequest()
// ✅ Null safety checks for request.id
// ✅ Better error handling
// ═══════════════════════════════════════════════════════════

class OwnerDashboardController extends GetxController {
  final BookingService _bookingService = Get.put(BookingService());

  final RxList<BookingRequestModel> pendingRequests =
      <BookingRequestModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPendingRequests();
  }

  // ═══════════════════════════════════════════════════════════
  // LOAD PENDING BOOKING REQUESTS
  // ✅ FIXED: Uses getPendingBookings() instead of getPendingRequests()
  // ═══════════════════════════════════════════════════════════

  Future<void> loadPendingRequests() async {
    isLoading.value = true;

    try {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('🔍 [OWNER DASHBOARD] Loading pending requests...');
      print('═══════════════════════════════════════════════════════════');

      // ✅ FIXED: Changed from getPendingRequests() to getPendingBookings()
      final requests = await _bookingService.getPendingBookings();
      pendingRequests.value = requests;

      print('✅ Loaded ${requests.length} pending requests');
      for (var req in requests) {
        print('   • ${req.userName ?? "Unknown"} - ${req.dateRange}');
      }
      print('═══════════════════════════════════════════════════════════');
    } catch (e) {
      print('❌ Error loading pending requests: $e');
      print('═══════════════════════════════════════════════════════════');

      Get.snackbar(
        'Error',
        'Failed to load pending requests',
        backgroundColor: Colors.red,
        colorText: Colors.white,
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
    await loadPendingRequests();
    isRefreshing.value = false;
  }

  // ═══════════════════════════════════════════════════════════
  // APPROVE A BOOKING REQUEST
  // ✅ FIXED: Uses approveBooking() instead of approveRequest()
  // ═══════════════════════════════════════════════════════════

  Future<void> approveRequest(BookingRequestModel request) async {
    // ✅ Check if ID exists
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
      print('   Dates: ${request.dateRange}');
      print('──────────────────────────────────────────────────────────');

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // ✅ FIXED: Changed from approveRequest() to approveBooking()
      final success = await _bookingService.approveBooking(request.id!);
      Get.back(); // Close loading dialog

      if (success) {
        print('✅ Booking approved successfully');
        print('═══════════════════════════════════════════════════════════');

        // Remove from pending list
        pendingRequests.removeWhere((r) => r.id == request.id);

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
  // ✅ FIXED: Uses rejectBooking() instead of rejectRequest()
  // ═══════════════════════════════════════════════════════════

  Future<void> rejectRequest(BookingRequestModel request) async {
    // ✅ Check if ID exists
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
      print('   Dates: ${request.dateRange}');
      print('──────────────────────────────────────────────────────────');

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // ✅ FIXED: Changed from rejectRequest() to rejectBooking()
      final success = await _bookingService.rejectBooking(request.id!);
      Get.back(); // Close loading dialog

      if (success) {
        print('✅ Booking rejected successfully');
        print('═══════════════════════════════════════════════════════════');

        // Remove from pending list
        pendingRequests.removeWhere((r) => r.id == request.id);

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
    // ✅ Check if userId exists
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
    // TODO: Update route name if different
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
  // HELPER GETTERS
  // ═══════════════════════════════════════════════════════════

  /// Get count of pending requests
  int get pendingCount => pendingRequests.length;

  /// Check if there are any pending requests
  bool get hasPendingRequests => pendingRequests.isNotEmpty;
}
