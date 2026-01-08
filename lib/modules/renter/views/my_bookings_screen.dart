import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/data/services/bookings_service.dart';
import 'package:hommie/data/models/bookings/bookings_request_model.dart';
import 'package:hommie/widgets/my_bookings_card.dart'; // ✅ Import fixed


// ═══════════════════════════════════════════════════════════
// RENTER MY BOOKINGS SCREEN
// ✅ 4 Tabs: Pending, Rejected, Approved, Completed
// ✅ Shows renter's bookings by status
// ✅ Can cancel pending bookings
// ✅ CARDS NOW VISIBLE
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
  List<BookingRequestModel> _rejectedBookings = [];
  List<BookingRequestModel> _approvedBookings = [];
  List<BookingRequestModel> _completedBookings = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📋 MY BOOKINGS SCREEN INITIALIZED');
    print('═══════════════════════════════════════════════════════════');

    _loadAllBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // LOAD ALL BOOKINGS
  // ✅ Fetches bookings and separates by status
  // ═══════════════════════════════════════════════════════════

  Future<void> _loadAllBookings() async {
    print('📥 Loading all bookings...');
    setState(() => _isLoading = true);

    try {
      // GET /api/bookings (all statuses)
      final allBookings = await _bookingService.getMyBookings();

      // Separate by status
      _pendingBookings = allBookings
          .where((b) => b.status?.toLowerCase() == 'pending')
          .toList();

      _rejectedBookings = allBookings
          .where((b) => b.status?.toLowerCase() == 'rejected')
          .toList();

      _approvedBookings = allBookings
          .where((b) => b.status?.toLowerCase() == 'approved')
          .toList();

      _completedBookings = allBookings
          .where((b) => b.status?.toLowerCase() == 'completed')
          .toList();

      print('');
      print('📊 BOOKINGS LOADED:');
      print('   Pending: ${_pendingBookings.length}');
      print('   Rejected: ${_rejectedBookings.length}');
      print('   Approved: ${_approvedBookings.length}');
      print('   Completed: ${_completedBookings.length}');
      print('═══════════════════════════════════════════════════════════');

      setState(() => _isLoading = false);
    } catch (e) {
      print('❌ Error loading bookings: $e');
      print('═══════════════════════════════════════════════════════════');

      setState(() => _isLoading = false);

      Get.snackbar(
        'error',
        'Failed to load bookings',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // CANCEL BOOKING
  // ✅ Only for pending bookings
  // ═══════════════════════════════════════════════════════════

  Future<void> _cancelBooking(BookingRequestModel booking) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Delete booking'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to delete this booking?',
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
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${booking.startDate} - ${booking.endDate}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('تراجع'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete reservation'),
          ),
        ],
      ),
    );

    if (confirmed == true && booking.id != null) {
      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final success = await _bookingService.cancelBooking(booking.id!);

      Get.back(); // Close loading

      if (success) {
        Get.snackbar(
          'Deleting process is done!',
          'The reservation was deleted successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        await _loadAllBookings();
      } else {
        Get.snackbar(
          'Error',
          'فشل إلغاء الحجز',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50, // ✅ Better background
      appBar: AppBar(
        title: const Text('My bookings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllBookings,
            tooltip: 'update',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: [
            Tab(
              child: Row(
                children: [
                  const Icon(Icons.hourglass_empty, size: 18),
                  const SizedBox(width: 6),
                  Text('Pending (${_pendingBookings.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                children: [
                  const Icon(Icons.cancel, size: 18),
                  const SizedBox(width: 6),
                  Text('Rejected (${_rejectedBookings.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 18),
                  const SizedBox(width: 6),
                  Text('Approved (${_approvedBookings.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                children: [
                  const Icon(Icons.done_all, size: 18),
                  const SizedBox(width: 6),
                  Text('Completed (${_completedBookings.length})'),
                ],
              ),
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
                // ⏳ PENDING TAB
                _buildBookingsList(
                  bookings: _pendingBookings,
                  emptyIcon: Icons.hourglass_empty,
                  emptyTitle: 'There are no pending reservation',
                  emptyMessage: 'الحجوزات التي لم يرد عليها المالك ستظهر هنا',
                  status: 'pending',
                  showCancel: true,
                ),

                // ❌ REJECTED TAB
                _buildBookingsList(
                  bookings: _rejectedBookings,
                  emptyIcon: Icons.cancel,
                  emptyTitle: 'There are no rejected reservation',
                  emptyMessage: 'الحجوزات التي رفضها المالك ستظهر هنا',
                  status: 'rejected',
                  showCancel: false,
                ),

                // ✅ APPROVED TAB
                _buildBookingsList(
                  bookings: _approvedBookings,
                  emptyIcon: Icons.check_circle,
                  emptyTitle: 'There are no approved reservation',
                  emptyMessage: 'الحجوزات التي قبلها المالك ستظهر هنا',
                  status: 'approved',
                  showCancel: false,
                ),

                // 🏁 COMPLETED TAB
                _buildBookingsList(
                  bookings: _completedBookings,
                  emptyIcon: Icons.done_all,
                  emptyTitle: 'There are no completed reservation',
                  emptyMessage: 'الحجوزات المكتملة ستظهر هنا',
                  status: 'completed',
                  showCancel: false,
                ),
              ],
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD BOOKINGS LIST
  // ✅ Cards will now appear correctly
  // ═══════════════════════════════════════════════════════════

  Widget _buildBookingsList({
    required List<BookingRequestModel> bookings,
    required IconData emptyIcon,
    required String emptyTitle,
    required String emptyMessage,
    required String status,
    required bool showCancel,
  }) {
    if (bookings.isEmpty) {
      return _buildEmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        message: emptyMessage,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllBookings,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final booking = bookings[index];
          
          print('🎴 Building card for booking #${booking.id}');
          
          // ✅ Return the card widget
          return MyBookingCard(
            booking: booking,
            status: status,
            onCancel: showCancel ? () => _cancelBooking(booking) : null,
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // EMPTY STATE
  // ═══════════════════════════════════════════════════════════

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}