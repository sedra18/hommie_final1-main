import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/data/models/bookings/bookings_request_model.dart';
import 'package:hommie/data/services/bookings_service.dart';
import 'package:intl/intl.dart';

// ═══════════════════════════════════════════════════════════
// ENHANCED MY BOOKING CARD - COMPLETE VERSION
// ✅ Fixed UI (no overflow)
// ✅ Auto rating for completed bookings
// ✅ Update button for pending bookings
// ✅ Cancel button
// ✅ All statuses supported including cancelled
// ═══════════════════════════════════════════════════════════

class MyBookingCard extends StatefulWidget {
  final BookingRequestModel booking;
  final String status;
  final VoidCallback? onCancel;
  final VoidCallback? onUpdate;
  final VoidCallback? onReviewSubmitted;

  const MyBookingCard({
    super.key,
    required this.booking,
    required this.status,
    this.onCancel,
    this.onUpdate,
    this.onReviewSubmitted,
  });

  @override
  State<MyBookingCard> createState() => _MyBookingCardState();
}

class _MyBookingCardState extends State<MyBookingCard> {
  bool _hasShownRatingDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowRatingDialog();
    });
  }

  void _checkAndShowRatingDialog() {
    if (_hasShownRatingDialog) return;
    
    final endDate = DateTime.tryParse(widget.booking.endDate ?? '');
    if (endDate == null) return;

    final now = DateTime.now();
    final hasEnded = now.isAfter(endDate);

    if (hasEnded && 
        (widget.status.toLowerCase() == 'approved' || 
         widget.status.toLowerCase() == 'completed')) {
      _hasShownRatingDialog = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showRatingDialog();
        }
      });
    }
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RatingDialog(
        booking: widget.booking,
        onReviewSubmitted: () {
          if (widget.onReviewSubmitted != null) {
            widget.onReviewSubmitted!();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final endDate = DateTime.tryParse(widget.booking.endDate ?? '');
    final hasEnded = endDate != null && DateTime.now().isAfter(endDate);
    
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getStatusColor().withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _getStatusText(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '#${widget.booking.id ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Apartment title
                  Row(
                    children: [
                      Icon(
                        Icons.home,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.booking.apartmentTitle ?? 'Apartment',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Dates
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        // Check In
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Check In',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatDate(widget.booking.startDate ?? 'N/A'),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        // Check Out
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.event,
                              size: 16,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Check Out',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatDate(widget.booking.endDate ?? 'N/A'),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Payment & Duration
                  Row(
                    children: [
                      if (widget.booking.paymentMethod != null)
                        Expanded(
                          child: _buildInfoChip(
                            icon: widget.booking.paymentMethod == 'cash'
                                ? Icons.money
                                : Icons.credit_card,
                            label: widget.booking.paymentMethod == 'cash'
                                ? 'Cash'
                                : 'Card',
                            color: Colors.green,
                          ),
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoChip(
                          icon: Icons.nights_stay,
                          label: '${_calculateDuration()}N',
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),

                  // Completed/Ended booking - Rating
                  if (hasEnded && 
                      (widget.status.toLowerCase() == 'approved' || 
                       widget.status.toLowerCase() == 'completed')) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange.shade700,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Your stay has ended. Rate your experience!',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showRatingDialog,
                        icon: const Icon(Icons.star_rounded, size: 18),
                        label: const Text(
                          'Rate Apartment',
                          style: TextStyle(fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Cancelled booking notice
                  if (widget.status.toLowerCase() == 'cancelled') ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.red.shade700,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'This booking was cancelled.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Action buttons for pending bookings
                  if (widget.status.toLowerCase() == 'pending' || 
                      widget.status.toLowerCase() == 'pending_owner_approval') ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Update button
                        if (widget.onUpdate != null && !hasEnded)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: widget.onUpdate,
                              icon: const Icon(Icons.edit_calendar, size: 18),
                              label: const Text('Update'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        
                        if (widget.onUpdate != null && widget.onCancel != null)
                          const SizedBox(width: 12),

                        // Cancel button
                        if (widget.onCancel != null && !hasEnded)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: widget.onCancel,
                              icon: const Icon(Icons.cancel, size: 18),
                              label: const Text('Cancel'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],

                  // Cancel button for approved bookings
                  if (widget.status.toLowerCase() == 'approved' && 
                      !hasEnded && 
                      widget.onCancel != null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: widget.onCancel,
                        icon: const Icon(Icons.cancel, size: 18),
                        label: const Text('Cancel Booking'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr.length > 20 ? '${dateStr.substring(0, 17)}...' : dateStr;
    }
  }

  Color _getStatusColor() {
    switch (widget.status.toLowerCase()) {
      case 'pending':
      case 'pending_owner_approval':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.status.toLowerCase()) {
      case 'pending':
      case 'pending_owner_approval':
        return Icons.pending;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'completed':
        return Icons.task_alt;
      case 'cancelled':
        return Icons.block;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText() {
    switch (widget.status.toLowerCase()) {
      case 'pending':
      case 'pending_owner_approval':
        return 'Pending Approval';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  int _calculateDuration() {
    try {
      final start = DateTime.parse(widget.booking.startDate ?? '');
      final end = DateTime.parse(widget.booking.endDate ?? '');
      return end.difference(start).inDays;
    } catch (e) {
      return 0;
    }
  }
}

// Rating Dialog - Same as before
class RatingDialog extends StatefulWidget {
  final BookingRequestModel booking;
  final VoidCallback? onReviewSubmitted;

  const RatingDialog({
    super.key,
    required this.booking,
    this.onReviewSubmitted,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> with SingleTickerProviderStateMixin {
  int _selectedRating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
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
    _commentController.dispose();
    super.dispose();
  }

  void _animateStarTap() {
    _animationController.reset();
    _animationController.forward();
  }

  Future<void> _submitReview() async {
    if (_selectedRating == 0) {
      Get.snackbar(
        'Rating Required',
        'Please select a rating',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final bookingService = Get.find<BookingService>();
      final result = await bookingService.addReview(
        bookingId: widget.booking.id!,
        rating: _selectedRating,
        comment: _commentController.text.trim().isEmpty 
            ? null 
            : _commentController.text.trim(),
      );

      if (result['success'] == true) {
        Get.back();
        
        Get.snackbar(
          '✓ Success',
          'Thank you for your review!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 3),
        );

        if (widget.onReviewSubmitted != null) {
          widget.onReviewSubmitted!();
        }
      } else {
        throw Exception(result['error'] ?? 'Failed to submit review');
      }
    } catch (e) {
      Get.back();
      
      Get.snackbar(
        'Error',
        'Failed to submit review: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Rate Your Stay',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.apartment, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.booking.apartmentTitle ?? 'Apartment',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'How was your experience?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starNumber = index + 1;
                  final isSelected = _selectedRating >= starNumber;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedRating = starNumber);
                      _animateStarTap();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Icon(
                          isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 48,
                          color: isSelected 
                              ? const Color(0xFFFFB800)
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              if (_selectedRating > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getRatingText(_selectedRating),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              TextField(
                controller: _commentController,
                maxLines: 3,
                maxLength: 300,
                decoration: InputDecoration(
                  hintText: 'Add a comment (optional)...',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting || _selectedRating == 0
                      ? null
                      : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit Review',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor Experience';
      case 2:
        return 'Below Average';
      case 3:
        return 'Average';
      case 4:
        return 'Good Experience';
      case 5:
        return 'Excellent!';
      default:
        return '';
    }
  }
}