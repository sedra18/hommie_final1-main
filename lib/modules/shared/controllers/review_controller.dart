import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/models/bookings/bookings_request_model.dart';
import 'package:hommie/data/services/bookings_service.dart';

class ReviewController extends GetxController {
  final BookingService _bookingService = Get.find<BookingService>();

  // Observable lists
  final RxList<BookingRequestModel> pendingReviews = <BookingRequestModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  // For add review form
  final RxInt selectedRating = 0.obs;
  final RxString reviewComment = ''.obs;
  final TextEditingController commentController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadPendingReviews();
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }

  // ═══════════════════════════════════════════════════════════
  // LOAD PENDING REVIEWS
  // ═══════════════════════════════════════════════════════════

  Future<void> loadPendingReviews() async {
    try {
      isLoading.value = true;

      print('');
      print('═══════════════════════════════════════════════════════════');
      print('📋 LOADING PENDING REVIEWS');
      print('──────────────────────────────────────────────────────────');

      final reviews = await _bookingService.getPendingReviews();
      
      pendingReviews.value = reviews;

      print('✅ Loaded ${reviews.length} pending reviews');
      print('═══════════════════════════════════════════════════════════');
    } catch (e) {
      print('❌ Error loading pending reviews: $e');
      Get.snackbar(
        'Error',
        'Failed to load pending reviews',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // SUBMIT REVIEW
  // ═══════════════════════════════════════════════════════════

  Future<void> submitReview({
    required int bookingId,
    required int rating,
    String? comment,
  }) async {
    if (rating < 1 || rating > 5) {
      Get.snackbar(
        'Invalid Rating',
        'Please select a rating between 1 and 5 stars',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade400,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      isSubmitting.value = true;

      print('');
      print('═══════════════════════════════════════════════════════════');
      print('⭐ SUBMITTING REVIEW');
      print('   Booking ID: $bookingId');
      print('   Rating: $rating');
      print('   Comment: ${comment ?? 'None'}');
      print('──────────────────────────────────────────────────────────');

      final result = await _bookingService.addReview(
        bookingId: bookingId,
        rating: rating,
        comment: comment,
      );

      if (result['success'] == true) {
        print('✅ Review submitted successfully');
        print('═══════════════════════════════════════════════════════════');

        Get.snackbar(
          '✓ Success',
          'Your review has been submitted!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade400,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );

        // Remove the booking from pending reviews
        pendingReviews.removeWhere((b) => b.id == bookingId);

        // Reset form
        resetReviewForm();

        // Go back to pending reviews list
        Get.back();
      } else {
        print('❌ Failed to submit review: ${result['error']}');
        print('═══════════════════════════════════════════════════════════');

        Get.snackbar(
          'Error',
          result['error'] ?? 'Failed to submit review',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('❌ Error submitting review: $e');
      Get.snackbar(
        'Error',
        'An error occurred while submitting your review',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // SET RATING
  // ═══════════════════════════════════════════════════════════

  void setRating(int rating) {
    selectedRating.value = rating;
  }

  // ═══════════════════════════════════════════════════════════
  // RESET FORM
  // ═══════════════════════════════════════════════════════════

  void resetReviewForm() {
    selectedRating.value = 0;
    reviewComment.value = '';
    commentController.clear();
  }

  // ═══════════════════════════════════════════════════════════
  // HELPER: CHECK IF BOOKING DATE IS COMPLETED
  // ═══════════════════════════════════════════════════════════

  bool isBookingCompleted(BookingRequestModel booking) {
    try {
      final endDate = DateTime.parse(booking.endDate);
      final now = DateTime.now();
      return now.isAfter(endDate);
    } catch (e) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // HELPER: GET DAYS SINCE BOOKING ENDED
  // ═══════════════════════════════════════════════════════════

  int getDaysSinceCompleted(BookingRequestModel booking) {
    try {
      final endDate = DateTime.parse(booking.endDate);
      final now = DateTime.now();
      return now.difference(endDate).inDays;
    } catch (e) {
      return 0;
    }
  }
}