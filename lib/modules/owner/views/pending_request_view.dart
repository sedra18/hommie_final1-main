import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/services/bookings_service.dart';
import 'package:hommie/data/models/bookings/bookings_request_model.dart';
import 'package:hommie/widgets/request_card.dart';
import 'package:hommie/widgets/owner_booking_card.dart';
import 'package:hommie/app/utils/app_colors.dart';

// ═══════════════════════════════════════════════════════════
// OWNER DASHBOARD WITH TABS
// ✅ Tab 1: Pending Requests (with approve/reject actions)
// ✅ Tab 2: Rejected Bookings (read-only)
// ✅ Tab 3: Approved Bookings (read-only)
// ═══════════════════════════════════════════════════════════

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BookingService _bookingService = Get.find<BookingService>();

  List<BookingRequestModel> _pendingRequests = [];
  List<BookingRequestModel> _rejectedRequests = [];
  List<BookingRequestModel> _approvedRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🏠 OWNER DASHBOARD INITIALIZED');
    print('═══════════════════════════════════════════════════════════');

    _loadAllRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // LOAD ALL REQUESTS
  // ✅ Separates by status
  // ═══════════════════════════════════════════════════════════

  Future<void> _loadAllRequests() async {
    print('📥 Loading all booking requests...');
    setState(() => _isLoading = true);

    try {
      // GET /api/owner/bookings (all statuses)
      final allRequests = await _bookingService.getOwnerBookings();

      _pendingRequests = allRequests
          .where((b) => b.status?.toLowerCase() == 'pending')
          .toList();

      _rejectedRequests = allRequests
          .where((b) => b.status?.toLowerCase() == 'rejected')
          .toList();

      _approvedRequests = allRequests
          .where((b) => b.status?.toLowerCase() == 'approved')
          .toList();

      print('');
      print('📊 REQUESTS LOADED:');
      print('   Pending: ${_pendingRequests.length}');
      print('   Rejected: ${_rejectedRequests.length}');
      print('   Approved: ${_approvedRequests.length}');
      print('═══════════════════════════════════════════════════════════');

      setState(() => _isLoading = false);
    } catch (e) {
      print('❌ Error loading requests: $e');
      print('═══════════════════════════════════════════════════════════');

      setState(() => _isLoading = false);

      Get.snackbar(
        'خطأ',
        'فشل تحميل طلبات الحجز',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // APPROVE REQUEST
  // ═══════════════════════════════════════════════════════════

  Future<void> _approveRequest(BookingRequestModel request) async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('✅ APPROVING REQUEST');
    print('   Booking ID: ${request.id}');
    print('   User: ${request.userName}');
    print('──────────────────────────────────────────────────────────');

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text('قبول الحجز'),
          ],
        ),
        content: Text(
          'قبول طلب الحجز من ${request.userName ?? 'المستأجر'}؟\n\n'
          'التواريخ: ${request.startDate} - ${request.endDate}\n'
          'الدفع: ${request.paymentMethod?.toUpperCase()}',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('قبول'),
          ),
        ],
      ),
    );

    if (confirmed == true && request.id != null) {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.green)),
        barrierDismissible: false,
      );

      final success = await _bookingService.approveBooking(request.id!);

      Get.back(); // Close loading

      if (success) {
        print('✅ Booking approved successfully');
        print('═══════════════════════════════════════════════════════════');

        Get.snackbar(
          'تم القبول',
          'تم قبول الحجز بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 3),
        );

        await _loadAllRequests();
      } else {
        print('❌ Failed to approve booking');
        print('═══════════════════════════════════════════════════════════');

        Get.snackbar(
          'خطأ',
          'فشل قبول الحجز',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // REJECT REQUEST
  // ═══════════════════════════════════════════════════════════

  Future<void> _rejectRequest(BookingRequestModel request) async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('❌ REJECTING REQUEST');
    print('   Booking ID: ${request.id}');
    print('   User: ${request.userName}');
    print('──────────────────────────────────────────────────────────');

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text('رفض الحجز'),
          ],
        ),
        content: Text(
          'رفض طلب الحجز من ${request.userName ?? 'المستأجر'}؟\n\n'
          'لا يمكن التراجع عن هذا الإجراء.',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('رفض'),
          ),
        ],
      ),
    );

    if (confirmed == true && request.id != null) {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.red)),
        barrierDismissible: false,
      );

      final success = await _bookingService.rejectBooking(request.id!);

      Get.back(); // Close loading

      if (success) {
        print('✅ Booking rejected successfully');
        print('═══════════════════════════════════════════════════════════');

        Get.snackbar(
          'تم الرفض',
          'تم رفض الحجز',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          icon: const Icon(Icons.info, color: Colors.white),
          duration: const Duration(seconds: 3),
        );

        await _loadAllRequests();
      } else {
        print('❌ Failed to reject booking');
        print('═══════════════════════════════════════════════════════════');

        Get.snackbar(
          'خطأ',
          'فشل رفض الحجز',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // GO TO MESSAGES
  // ═══════════════════════════════════════════════════════════

  void _goToMessages(BookingRequestModel request) {
    print('💬 Opening messages with ${request.userName ?? "user"}');

    Get.snackbar(
      'الرسائل',
      'ميزة الدردشة قريباً',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('طلبات الحجز'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllRequests,
            tooltip: 'تحديث',
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
                  Text('في الانتظار (${_pendingRequests.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                children: [
                  const Icon(Icons.cancel, size: 18),
                  const SizedBox(width: 6),
                  Text('مرفوض (${_rejectedRequests.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 18),
                  const SizedBox(width: 6),
                  Text('مقبول (${_approvedRequests.length})'),
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
                // ⏳ PENDING TAB (with action buttons)
                _buildPendingList(),

                // ❌ REJECTED TAB (read-only)
                _buildStatusList(
                  requests: _rejectedRequests,
                  status: 'rejected',
                  emptyIcon: Icons.cancel,
                  emptyTitle: 'لا توجد حجوزات مرفوضة',
                  emptyMessage: 'الحجوزات التي رفضتها ستظهر هنا',
                ),

                // ✅ APPROVED TAB (read-only)
                _buildStatusList(
                  requests: _approvedRequests,
                  status: 'approved',
                  emptyIcon: Icons.check_circle,
                  emptyTitle: 'لا توجد حجوزات مقبولة',
                  emptyMessage: 'الحجوزات التي قبلتها ستظهر هنا',
                ),
              ],
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD PENDING LIST (with action buttons)
  // ═══════════════════════════════════════════════════════════

  Widget _buildPendingList() {
    if (_pendingRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inbox_outlined,
        title: 'لا توجد طلبات جديدة',
        message: 'طلبات الحجز الجديدة من المستأجرين ستظهر هنا',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllRequests,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingRequests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final request = _pendingRequests[index];
          return BookingRequestCard(
            request: request,
            onApprove: () => _approveRequest(request),
            onReject: () => _rejectRequest(request),
            onMessage: () => _goToMessages(request),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD STATUS LIST (read-only)
  // ═══════════════════════════════════════════════════════════

  Widget _buildStatusList({
    required List<BookingRequestModel> requests,
    required String status,
    required IconData emptyIcon,
    required String emptyTitle,
    required String emptyMessage,
  }) {
    if (requests.isEmpty) {
      return _buildEmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        message: emptyMessage,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllRequests,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final request = requests[index];
          return OwnerBookingCard(
            booking: request,
            status: status,
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
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _loadAllRequests,
              icon: const Icon(Icons.refresh),
              label: const Text('تحديث'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}