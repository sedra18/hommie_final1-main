import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/app/utils/app_colors.dart';

import 'package:hommie/data/models/bookings/bookings_request_model.dart';

import 'package:hommie/modules/shared/controllers/review_controller.dart';
import 'package:intl/intl.dart';

class AddReviewScreen extends StatefulWidget {
  final BookingRequestModel booking;

  const AddReviewScreen({super.key, required this.booking});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen>
    with SingleTickerProviderStateMixin {
  final controller = Get.find<ReviewController>();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void onInit() {
    super.initState();
    controller.resetReviewForm();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Write Review',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking info card
            _buildBookingInfoCard(isDark),

            const SizedBox(height: 32),

            // Rating section
            _buildRatingSection(isDark),

            const SizedBox(height: 32),

            // Comment section
            _buildCommentSection(isDark),

            const SizedBox(height: 32),

            // Submit button
            _buildSubmitButton(isDark),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BOOKING INFO CARD
  // ═══════════════════════════════════════════════════════════

  Widget _buildBookingInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2235) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.apartment_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.booking.apartmentTitle ?? 'Apartment',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Booking #${widget.booking.id}',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Divider(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildQuickInfo(
                  icon: Icons.calendar_today_rounded,
                  label: _formatDate(widget.booking.startDate),
                  isDark: isDark,
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: isDark ? Colors.white30 : Colors.black26,
              ),
              Expanded(
                child: _buildQuickInfo(
                  icon: Icons.event_rounded,
                  label: _formatDate(widget.booking.endDate),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: isDark ? Colors.white60 : Colors.black54),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // RATING SECTION
  // ═══════════════════════════════════════════════════════════

  Widget _buildRatingSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2235) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'How was your experience?',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Tap on the stars to rate',
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 24),

          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starNumber = index + 1;
                final isSelected =
                    controller.selectedRating.value >= starNumber;

                return GestureDetector(
                  onTap: () {
                    controller.setRating(starNumber);
                    _animateStarTap();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Icon(
                        isSelected
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 48,
                        color: isSelected
                            ? const Color(0xFFFFB800)
                            : (isDark ? Colors.white30 : Colors.black26),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 16),

          Obx(() {
            if (controller.selectedRating.value > 0) {
              return AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getRatingText(controller.selectedRating.value),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  void _animateStarTap() {
    _animationController.reset();
    _animationController.forward();
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor Experience';
      case 2:
        return 'Below Average';
      case 3:
        return 'Average Experience';
      case 4:
        return 'Good Experience';
      case 5:
        return 'Excellent Experience!';
      default:
        return '';
    }
  }

  // ═══════════════════════════════════════════════════════════
  // COMMENT SECTION
  // ═══════════════════════════════════════════════════════════

  Widget _buildCommentSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2235) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.comment_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Additional Comments (Optional)',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          TextField(
            controller: controller.commentController,
            maxLines: 5,
            maxLength: 500,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: 'Share your thoughts about your stay...',
              hintStyle: TextStyle(
                color: isDark ? AppColors.backgroundLight : Colors.black38,
                fontSize: 15,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.02),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              counterStyle: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SUBMIT BUTTON
  // ═══════════════════════════════════════════════════════════

  Widget _buildSubmitButton(bool isDark) {
    return Obx(() {
      final isSubmitting = controller.isSubmitting.value;
      final hasRating = controller.selectedRating.value > 0;

      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: hasRating && !isSubmitting ? () => _submitReview() : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            disabledForegroundColor: isDark ? Colors.white30 : Colors.black38,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: hasRating ? 4 : 0,
            shadowColor: AppColors.primary.withOpacity(0.4),
          ),
          child: isSubmitting
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send_rounded, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      hasRating ? 'Submit Review' : 'Select a Rating First',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════
  // SUBMIT REVIEW
  // ═══════════════════════════════════════════════════════════

  void _submitReview() {
    final comment = controller.commentController.text.trim();

    controller.submitReview(
      bookingId: widget.booking.id!,
      rating: controller.selectedRating.value,
      comment: comment.isNotEmpty ? comment : null,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
