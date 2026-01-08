import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/models/bookings/bookings_request_model.dart';
import 'package:hommie/data/services/bookings_service.dart';
import 'package:hommie/widgets/request_card.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BookingService _bookingService = Get.find<BookingService>();

  bool _isLoading = false;
  List<BookingRequestModel> _pendingRequests = [];
  List<BookingRequestModel> _rejectedRequests = [];
  List<BookingRequestModel> _approvedRequests = [];

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
  // ✅ Fetches ONLY bookings for this owner's apartments
  // ✅ Separates by status
  // ═══════════════════════════════════════════════════════════

  Future<void> _loadAllRequests() async {
    print('📥 Loading owner booking requests...');
    setState(() => _isLoading = true);

    try {
      // ✅ GET /api/bookings (backend determines owner/renter from token)
      final allRequests = await _bookingService.getMyBookings();

      print('📦 Raw requests received: ${allRequests.length}');
      
      // Log each request for debugging
      for (var request in allRequests) {
        print('   - Booking #${request.id}: "${request.status}" for ${request.apartmentTitle}');
      }

      // ✅ FIXED: Check for exact status from backend
      // Backend returns 'pending_owner_approval' for pending owner requests
      _pendingRequests = allRequests
          .where((b) {
            final status = b.status?.toLowerCase() ?? '';
            // Match exactly what backend sends
            return status == 'pending_owner_approval' || 
                   status == 'pending';
          })
          .toList();

      _rejectedRequests = allRequests
          .where((b) {
            final status = b.status?.toLowerCase() ?? '';
            return status == 'rejected' || status == 'declined';
          })
          .toList();

      _approvedRequests = allRequests
          .where((b) {
            final status = b.status?.toLowerCase() ?? '';
            return status == 'approved' || status == 'confirmed';
          })
          .toList();

      print('');
      print('📊 REQUESTS LOADED BY STATUS:');
      print('   Pending: ${_pendingRequests.length}');
      print('   Rejected: ${_rejectedRequests.length}');
      print('   Approved: ${_approvedRequests.length}');
      print('   Total: ${allRequests.length}');
      
      // Debug: Show which requests went where
      if (_pendingRequests.isNotEmpty) {
        print('\n   Pending requests:');
        for (var req in _pendingRequests) {
          print('     - Booking #${req.id}: "${req.status}"');
        }
      }
      print('═══════════════════════════════════════════════════════════');

      setState(() => _isLoading = false);
    } catch (e, stackTrace) {
      print('❌ Error loading requests: $e');
      print('Stack trace: ${stackTrace.toString().split('\n').take(5).join('\n')}');
      print('═══════════════════════════════════════════════════════════');

      setState(() => _isLoading = false);

      Get.snackbar(
        'خطأ',
        'فشل تحميل طلبات الحجز',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // APPROVE REQUEST
  // ✅ FIXED: Proper null check for request.id
  // ═══════════════════════════════════════════════════════════

  Future<void> _approveRequest(BookingRequestModel request) async {
    // ✅ Check if ID exists
    if (request.id == null) {
      print('❌ Cannot approve: ID is null');
      Get.snackbar(
        'خطأ',
        'معرف الحجز غير صالح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    print('');
    print('═══════════════════════════════════════════════════════════');
    print('✅ APPROVING REQUEST');
    print('   Booking ID: ${request.id}');
    print('   Renter: ${request.userName ?? 'N/A'}');
    print('   Apartment: ${request.apartmentTitle ?? 'N/A'}');
    print('──────────────────────────────────────────────────────────');

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('تأكيد الموافقة'),
          ],
        ),
        content: const Text(
          'هل أنت متأكد من الموافقة على هذا الحجز؟',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('موافق'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final success = await _bookingService.approveBooking(request.id!);
      
      Get.back(); // Close loading

      if (success) {
        print('✅ Booking approved successfully');
        print('═══════════════════════════════════════════════════════════');
        
        Get.snackbar(
          'نجاح',
          'تم قبول الحجز بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 3),
        );

        // Reload data
        await _loadAllRequests();
      } else {
        print('❌ Failed to approve booking');
        print('═══════════════════════════════════════════════════════════');
        
        Get.snackbar(
          'خطأ',
          'فشل قبول الحجز. حاول مرة أخرى',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // REJECT REQUEST
  // ✅ FIXED: Proper null check for request.id
  // ═══════════════════════════════════════════════════════════

  Future<void> _rejectRequest(BookingRequestModel request) async {
    // ✅ Check if ID exists
    if (request.id == null) {
      print('❌ Cannot reject: ID is null');
      Get.snackbar(
        'خطأ',
        'معرف الحجز غير صالح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    print('');
    print('═══════════════════════════════════════════════════════════');
    print('❌ REJECTING REQUEST');
    print('   Booking ID: ${request.id}');
    print('   Renter: ${request.userName ?? 'N/A'}');
    print('   Apartment: ${request.apartmentTitle ?? 'N/A'}');
    print('──────────────────────────────────────────────────────────');

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('تأكيد الرفض'),
          ],
        ),
        content: const Text(
          'هل أنت متأكد من رفض هذا الحجز؟',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('رفض'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final success = await _bookingService.rejectBooking(request.id!);
      
      Get.back(); // Close loading

      if (success) {
        print('✅ Booking rejected successfully');
        print('═══════════════════════════════════════════════════════════');
        
        Get.snackbar(
          'نجاح',
          'تم رفض الحجز',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          icon: const Icon(Icons.info, color: Colors.white),
          duration: const Duration(seconds: 3),
        );

        // Reload data
        await _loadAllRequests();
      } else {
        print('❌ Failed to reject booking');
        print('═══════════════════════════════════════════════════════════');
        
        Get.snackbar(
          'خطأ',
          'فشل رفض الحجز. حاول مرة أخرى',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD UI
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1F172A) : const Color(0xFFFAF9FB),
      appBar: AppBar(
        title: const Text(
          'لوحة التحكم',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF2D2438) : Colors.white,
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
          indicatorColor: const Color(0xFF3A7AFE),
          labelColor: const Color(0xFF3A7AFE),
          unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('قيد الانتظار'),
                  if (_pendingRequests.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${_pendingRequests.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'المقبولة'),
            const Tab(text: 'المرفوضة'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // PENDING TAB
                _buildRequestsList(_pendingRequests, 'pending'),
                // APPROVED TAB
                _buildRequestsList(_approvedRequests, 'approved'),
                // REJECTED TAB
                _buildRequestsList(_rejectedRequests, 'rejected'),
              ],
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD REQUESTS LIST
  // ✅ FIXED: Proper VoidCallback handling with null checks
  // ═══════════════════════════════════════════════════════════

  Widget _buildRequestsList(List<BookingRequestModel> requests, String statusType) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              statusType == 'pending'
                  ? Icons.inbox
                  : statusType == 'approved'
                      ? Icons.check_circle_outline
                      : Icons.cancel,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              statusType == 'pending'
                  ? 'لا توجد طلبات قيد الانتظار'
                  : statusType == 'approved'
                      ? 'لا توجد طلبات مقبولة'
                      : 'لا توجد طلبات مرفوضة',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          
          return BookingRequestCard(
            request: request,
            // ✅ FIXED: Provide proper VoidCallback (non-nullable)
            onApprove: statusType == 'pending'
                ? () => _approveRequest(request)
                : () {}, // Empty callback for non-pending
            onReject: statusType == 'pending'
                ? () => _rejectRequest(request)
                : () {}, // Empty callback for non-pending
          );
        },
      ),
    );
  }
}