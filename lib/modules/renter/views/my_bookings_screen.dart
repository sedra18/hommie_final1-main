import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/data/services/bookings_service.dart';
import 'package:hommie/data/models/bookings/bookings_request_model.dart';
import 'package:hommie/widgets/my_bookings_card.dart';

// ═══════════════════════════════════════════════════════════
// MY BOOKINGS SCREEN WITH AUTO-COMPLETE
// ✅ Automatically moves bookings to Completed tab when date ends
// ✅ Shows rating dialog when booking completes
// ✅ Works with your actual BookingRequestModel
// ═══════════════════════════════════════════════════════════

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BookingService _bookingService = Get.put(BookingService());

  // Bookings by status
  List<BookingRequestModel> _pendingBookings = [];
  List<BookingRequestModel> _approvedBookings = [];
  List<BookingRequestModel> _completedBookings = [];
  List<BookingRequestModel> _rejectedBookings = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📋 MY BOOKINGS SCREEN WITH AUTO-COMPLETE INITIALIZED');
    print('═══════════════════════════════════════════════════════════');

    _loadAllBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // LOAD ALL BOOKINGS WITH AUTO-COMPLETE LOGIC
  // ✅ Moves expired bookings to completed automatically
  // ═══════════════════════════════════════════════════════════

  Future<void> _loadAllBookings() async {
    print('📥 Loading all bookings...');
    setState(() => _isLoading = true);

    try {
      final allBookings = await _bookingService.getMyBookings();

      // Process each booking to determine actual status
      final processedBookings = _processBookingsWithExpiry(allBookings);

      // Separate by final status
      _pendingBookings = processedBookings
          .where((b) => 
              b.status?.toLowerCase() == 'pending' ||
              b.status?.toLowerCase() == 'pending_owner_approval')
          .toList();

      _approvedBookings = processedBookings
          .where((b) => b.status?.toLowerCase() == 'approved')
          .toList();

      _completedBookings = processedBookings
          .where((b) => b.status?.toLowerCase() == 'completed')
          .toList();

      _rejectedBookings = processedBookings
          .where((b) => b.status?.toLowerCase() == 'rejected')
          .toList();

      print('');
      print('📊 BOOKINGS LOADED & PROCESSED:');
      print('   Pending: ${_pendingBookings.length}');
      print('   Approved (Active): ${_approvedBookings.length}');
      print('   Completed (Auto-moved): ${_completedBookings.length}');
      print('   Rejected: ${_rejectedBookings.length}');
      print('═══════════════════════════════════════════════════════════');

      setState(() => _isLoading = false);
    } catch (e) {
      print('❌ Error loading bookings: $e');
      print('═══════════════════════════════════════════════════════════');

      setState(() => _isLoading = false);

      Get.snackbar(
        'Error',
        'Failed to load bookings',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // PROCESS BOOKINGS WITH EXPIRY CHECK
  // ✅ Core logic: Changes "approved" → "completed" when date passes
  // ✅ Uses copyWith() method from your model
  // ═══════════════════════════════════════════════════════════

  List<BookingRequestModel> _processBookingsWithExpiry(
      List<BookingRequestModel> bookings) {
    final now = DateTime.now();
    
    return bookings.map((booking) {
      // Parse end date
      final endDate = DateTime.tryParse(booking.endDate ?? '');
      
      if (endDate == null) return booking;

      // Check if booking has ended
      final hasEnded = now.isAfter(endDate);
      
      // ✅ KEY LOGIC: If booking was "approved" but date has passed → mark as "completed"
      if (hasEnded && booking.status?.toLowerCase() == 'approved') {
        print('✨ Auto-completing booking #${booking.id}: ${booking.apartmentTitle}');
        print('   End date: ${booking.endDate} (Passed)');
        print('   Status changed: approved → completed');
        
        // ✅ Use copyWith() method from your model
        return booking.copyWith(status: 'completed');
      }
      
      // Otherwise, return booking as-is
      return booking;
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════
  // CANCEL BOOKING
  // ═══════════════════════════════════════════════════════════

  Future<void> _cancelBooking(BookingRequestModel booking) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Cancel Booking'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to cancel this booking?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.apartmentTitle ?? 'Apartment',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${booking.startDate} → ${booking.endDate}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('No, Keep It'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final success = await _bookingService.cancelBooking(booking.id!);

      if (success) {
        Get.snackbar(
          '✓ Success',
          'Booking cancelled successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        // Reload bookings
        _loadAllBookings();
      } else {
        Get.snackbar(
          'Error',
          'Failed to cancel booking',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          tabs: [
            Tab(
              text: 'Pending',
              icon: _pendingBookings.isNotEmpty
                  ? Badge(
                      label: Text('${_pendingBookings.length}'),
                      child: const Icon(Icons.pending),
                    )
                  : const Icon(Icons.pending),
            ),
            Tab(
              text: 'Approved',
              icon: _approvedBookings.isNotEmpty
                  ? Badge(
                      label: Text('${_approvedBookings.length}'),
                      child: const Icon(Icons.check_circle),
                    )
                  : const Icon(Icons.check_circle),
            ),
            Tab(
              text: 'Completed',
              icon: _completedBookings.isNotEmpty
                  ? Badge(
                      label: Text('${_completedBookings.length}'),
                      child: const Icon(Icons.task_alt),
                    )
                  : const Icon(Icons.task_alt),
            ),
            Tab(
              text: 'Rejected',
              icon: _rejectedBookings.isNotEmpty
                  ? Badge(
                      label: Text('${_rejectedBookings.length}'),
                      child: const Icon(Icons.cancel),
                    )
                  : const Icon(Icons.cancel),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBookingsList(_pendingBookings, 'pending'),
                _buildBookingsList(_approvedBookings, 'approved'),
                _buildBookingsList(_completedBookings, 'completed'),
                _buildBookingsList(_rejectedBookings, 'rejected'),
              ],
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD BOOKINGS LIST
  // ═══════════════════════════════════════════════════════════

  Widget _buildBookingsList(List<BookingRequestModel> bookings, String status) {
    if (bookings.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      onRefresh: _loadAllBookings,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];

          // ✅ Use enhanced card with auto rating
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: MyBookingCard(
              booking: booking,
              status: status,
              onCancel: (status == 'pending' || status == 'pending_owner_approval')
                  ? () => _cancelBooking(booking)
                  : null,
              onReviewSubmitted: () {
                // Reload bookings after review is submitted
                _loadAllBookings();
              },
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // EMPTY STATE
  // ═══════════════════════════════════════════════════════════

  Widget _buildEmptyState(String status) {
    IconData icon;
    String message;
    String subtitle;

    switch (status) {
      case 'pending':
      case 'pending_owner_approval':
        icon = Icons.pending_outlined;
        message = 'No pending bookings';
        subtitle = 'Bookings awaiting approval will appear here';
        break;
      case 'approved':
        icon = Icons.check_circle_outline;
        message = 'No active bookings';
        subtitle = 'Your approved bookings will appear here';
        break;
      case 'completed':
        icon = Icons.task_alt;
        message = 'No completed bookings';
        subtitle = 'Finished bookings will move here automatically';
        break;
      case 'rejected':
        icon = Icons.cancel_outlined;
        message = 'No rejected bookings';
        subtitle = 'Declined bookings will appear here';
        break;
      default:
        icon = Icons.inbox_outlined;
        message = 'No bookings';
        subtitle = 'Your bookings will appear here';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
            ),
            child: Icon(
              icon,
              size: 80,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}