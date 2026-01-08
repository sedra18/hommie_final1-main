import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/models/bookings/bookings_request_model.dart';
import 'package:hommie/data/services/bookings_service.dart';

// ═══════════════════════════════════════════════════════════
// OWNER DASHBOARD CONTROLLER - FULLY CORRECTED
// ✅ Uses correct BookingService method: getOwnerBookings()
// ✅ Filters pending requests after loading
// ✅ Null safety checks for request.id
// ✅ Better error handling
// ═══════════════════════════════════════════════════════════

class OwnerDashboardController extends GetxController {
  final BookingService _bookingService = Get.find<BookingService>();

  final RxList<BookingRequestModel> pendingRequests =
      <BookingRequestModel>[].obs;
  final RxList<BookingRequestModel> approvedRequests =
      <BookingRequestModel>[].obs;
  final RxList<BookingRequestModel> rejectedRequests =
      <BookingRequestModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllRequests();
  }

  // ═══════════════════════════════════════════════════════════
  // LOAD ALL BOOKING REQUESTS
  // ✅ USES: getMyBookings() which works for both owner and renter
  // ✅ Backend determines owner/renter from token
  // ✅ Then filters by status on client side
  // ═══════════════════════════════════════════════════════════

  Future<void> loadAllRequests() async {
    isLoading.value = true;

    try {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('🔍 [OWNER DASHBOARD] Loading all booking requests...');
      print('═══════════════════════════════════════════════════════════');

      // ✅ UNIFIED METHOD: Backend determines owner/renter from token
      final allRequests = await _bookingService.getMyBookings();

      print('📦 Received ${allRequests.length} total requests');

      // ✅ Filter by status
      pendingRequests.value = allRequests.where((b) {
        final status = b.status?.toLowerCase() ?? '';
        return status == 'pending_owner_approval' || status == 'pending';
      }).toList();

      approvedRequests.value = allRequests.where((b) {
        final status = b.status?.toLowerCase() ?? '';
        return status == 'approved' || status == 'confirmed';
      }).toList();

      rejectedRequests.value = allRequests.where((b) {
        final status = b.status?.toLowerCase() ?? '';
        return status == 'rejected' || status == 'declined';
      }).toList();

      print('');
      print('📊 REQUESTS BY STATUS:');
      print('   Pending: ${pendingRequests.length}');
      print('   Approved: ${approvedRequests.length}');
      print('   Rejected: ${rejectedRequests.length}');
      
      if (pendingRequests.isNotEmpty) {
        print('\n   Pending requests:');
        for (var req in pendingRequests) {
          print('     - ${req.userName ?? "Unknown"} (ID: ${req.id})');
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
    await loadAllRequests();
    isRefreshing.value = false;
  }

  // Alias for compatibility
  Future<void> loadPendingRequests() async {
    await loadAllRequests();
  }

  // ═══════════════════════════════════════════════════════════
  // APPROVE A BOOKING REQUEST
  // ✅ Uses approveBooking() which exists in BookingService
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

        // Remove from pending list and refresh
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
  // ✅ Uses rejectBooking() which exists in BookingService
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

        // Refresh all lists
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

  /// Get count of approved requests
  int get approvedCount => approvedRequests.length;

  /// Get count of rejected requests
  int get rejectedCount => rejectedRequests.length;

  /// Check if there are any pending requests
  bool get hasPendingRequests => pendingRequests.isNotEmpty;
}