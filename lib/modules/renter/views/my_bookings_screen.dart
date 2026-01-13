// ═══════════════════════════════════════════════════════════
// MY BOOKINGS SCREEN (FOR RENTERS) - WITH ALL TAB ADDED
// ✅ Added "All" tab to show all bookings
// ✅ All tab updates when bookings are modified
// ═══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/app/utils/app_colors.dart';

import 'package:hommie/data/models/bookings/bookings_request_model.dart';
import 'package:hommie/data/services/bookings_service.dart';

import 'package:hommie/widgets/my_bookings_card.dart';
import 'package:intl/intl.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BookingService _bookingService = Get.put(BookingService());

  // ✅ Added list for all bookings
  List<BookingRequestModel> _allBookings = [];
  List<BookingRequestModel> _pendingBookings = [];
  List<BookingRequestModel> _approvedBookings = [];
  List<BookingRequestModel> _completedBookings = [];
  List<BookingRequestModel> _rejectedBookings = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // ✅ Changed from 4 to 5 tabs (added "All" tab)
    _tabController = TabController(length: 5, vsync: this);

    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📋 MY BOOKINGS SCREEN WITH AUTO-COMPLETE INITIALIZED');
    print('✅ ALL TAB FEATURE ENABLED');
    print('═══════════════════════════════════════════════════════════');

    _loadAllBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllBookings() async {
    print('📥 Loading all bookings...');
    setState(() => _isLoading = true);

    try {
      final allBookings = await _bookingService.getMyBookings();
      final processedBookings = _processBookingsWithExpiry(allBookings);

      // ✅ Store ALL bookings for the "All" tab
      _allBookings = processedBookings;

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
      print('   All: ${_allBookings.length}'); // ✅ Added
      print('   Pending: ${_pendingBookings.length}');
      print('   Approved (Active): ${_approvedBookings.length}');
      print('   Completed (Auto-moved): ${_completedBookings.length}');
      print('   Rejected: ${_rejectedBookings.length}');
      print('═══════════════════════════════════════════════════════════');

      setState(() => _isLoading = false);
    } catch (e) {
      print('❌ Error loading bookings: $e');
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

  List<BookingRequestModel> _processBookingsWithExpiry(
      List<BookingRequestModel> bookings) {
    final now = DateTime.now();
    
    return bookings.map((booking) {
      final endDate = DateTime.tryParse(booking.endDate);
      
      if (endDate == null) return booking;

      final hasEnded = now.isAfter(endDate);
      
      if (hasEnded && booking.status?.toLowerCase() == 'approved') {
        print('✨ Auto-completing booking #${booking.id}: ${booking.apartmentTitle}');
        print('   End date: ${booking.endDate} (Passed)');
        print('   Status changed: approved → completed');
        
        return booking.copyWith(status: 'completed');
      }
      
      return booking;
    }).toList();
  }

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

        // ✅ Reload to update ALL tabs including "All" tab
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

  Future<void> _updateBookingDates(BookingRequestModel booking) async {
    DateTime? currentStartDate = DateTime.tryParse(booking.startDate);
    DateTime? currentEndDate = DateTime.tryParse(booking.endDate);

    if (currentStartDate == null || currentEndDate == null) {
      Get.snackbar(
        'Error',
        'Invalid booking dates',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(
        start: currentStartDate.isAfter(DateTime.now()) 
            ? currentStartDate 
            : DateTime.now(),
        end: currentEndDate.isAfter(DateTime.now()) 
            ? currentEndDate 
            : DateTime.now().add(const Duration(days: 1)),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    Get.dialog(
      const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      barrierDismissible: false,
    );

    try {
      final success = await _bookingService.updateBookingDates(
        bookingId: booking.id!,
        startDate: picked.start,
        endDate: picked.end,
      );

      Get.back();

      if (success) {
        Get.snackbar(
          '✓ Success',
          'Booking dates updated successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // ✅ Reload to update ALL tabs including "All" tab
        _loadAllBookings();
      } else {
        Get.snackbar(
          'Error',
          'Failed to update booking dates',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
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
          isScrollable: true, // ✅ Make tabs scrollable for 5 tabs
          tabs: [
            // ✅ NEW: All tab
            Tab(
              text: 'All',
              icon: _allBookings.isNotEmpty
                  ? Badge(
                      label: Text('${_allBookings.length}'),
                      child: const Icon(Icons.list_alt),
                    )
                  : const Icon(Icons.list_alt),
            ),
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
                // ✅ NEW: All bookings tab
                _buildBookingsList(_allBookings, 'all'),
                _buildBookingsList(_pendingBookings, 'pending'),
                _buildBookingsList(_approvedBookings, 'approved'),
                _buildBookingsList(_completedBookings, 'completed'),
                _buildBookingsList(_rejectedBookings, 'rejected'),
              ],
            ),
    );
  }

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
          // ✅ Get actual booking status for actions (important for "All" tab)
          final actualStatus = booking.status?.toLowerCase() ?? '';

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: MyBookingCard(
              booking: booking,
              status: status == 'all' ? actualStatus : status, // ✅ Pass correct status
              onCancel: (actualStatus == 'pending' || 
                        actualStatus == 'pending_owner_approval' ||
                        actualStatus == 'approved')
                  ? () => _cancelBooking(booking)
                  : null,
              onUpdate: (actualStatus == 'pending' || 
                        actualStatus == 'pending_owner_approval' ||
                        actualStatus == 'approved')
                  ? () => _updateBookingDates(booking)
                  : null,
              onReviewSubmitted: () {
                _loadAllBookings(); // ✅ Refresh all tabs when review submitted
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    IconData icon;
    String message;
    String subtitle;

    switch (status) {
      case 'all':
        icon = Icons.inbox_outlined;
        message = 'No bookings yet';
        subtitle = 'All your bookings will appear here';
        break;
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