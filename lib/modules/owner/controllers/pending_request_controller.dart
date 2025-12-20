import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/models/bookings/bookings_request_model.dart';
import 'package:hommie/data/services/bookings_service.dart';


class OwnerDashboardController extends GetxController {
  final BookingService _bookingService = Get.find<BookingService>();

  final RxList<BookingRequestModel> pendingRequests = <BookingRequestModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPendingRequests();
  }

  /// Load pending booking requests
  Future<void> loadPendingRequests() async {
    isLoading.value = true;

    try {
      print('🔍 Loading pending requests...');
      final requests = await _bookingService.getPendingRequests();
      pendingRequests.value = requests;
      print('✅ Loaded ${requests.length} pending requests');
    } catch (e) {
      print('❌ Error loading pending requests: $e');
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

  /// Refresh requests
  Future<void> refreshRequests() async {
    isRefreshing.value = true;
    await loadPendingRequests();
    isRefreshing.value = false;
  }

  /// Approve a booking request
  Future<void> approveRequest(BookingRequestModel request) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final success = await _bookingService.approveRequest(request.id);
      Get.back(); // Close loading dialog

      if (success) {
        // Remove from pending list
        pendingRequests.removeWhere((r) => r.id == request.id);

        Get.snackbar(
          'Success',
          'Booking request approved for ${request.userName}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to approve request',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      print('❌ Error approving: $e');
      Get.snackbar(
        'Error',
        'An error occurred',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Reject a booking request
  Future<void> rejectRequest(BookingRequestModel request) async {
    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Reject Request'),
        content: Text('Are you sure you want to reject ${request.userName}\'s booking request?'),
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
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final success = await _bookingService.rejectRequest(request.id);
      Get.back(); // Close loading dialog

      if (success) {
        // Remove from pending list
        pendingRequests.removeWhere((r) => r.id == request.id);

        Get.snackbar(
          'Rejected',
          'Booking request rejected',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to reject request',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      print('❌ Error rejecting: $e');
      Get.snackbar(
        'Error',
        'An error occurred',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Go to messages with this user
  void goToMessages(BookingRequestModel request) {
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
}