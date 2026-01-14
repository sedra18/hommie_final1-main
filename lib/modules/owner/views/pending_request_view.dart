import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hommie/data/models/bookings/bookings_request_model.dart';
import 'package:hommie/data/services/bookings_service.dart';

import 'package:hommie/widgets/request_card.dart';

// ═══════════════════════════════════════════════════════════
// ENHANCED OWNER DASHBOARD SCREEN
// ✅ Beautiful modern UI with gradients and animations
// ✅ Shows both new bookings AND update requests (future feature)
// ✅ Statistics cards with live counts
// ✅ Same functionality as before - just better UI
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
  // ═══════════════════════════════════════════════════════════

  Future<void> _loadAllRequests() async {
    print('📥 Loading owner booking requests...');
    setState(() => _isLoading = true);

    try {
      final allRequests = await _bookingService.getMyBookings();

      print('📦 Raw requests received: ${allRequests.length}');
      
      for (var request in allRequests) {
        print('   - Booking #${request.id}: "${request.status}" for ${request.apartmentTitle}');
      }

      _pendingRequests = allRequests
          .where((b) {
            final status = b.status?.toLowerCase() ?? '';
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
  // ═══════════════════════════════════════════════════════════

  Future<void> _approveRequest(BookingRequestModel request) async {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('موافق'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final success = await _bookingService.approveBooking(request.id!);
      
      Get.back();

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
  // ═══════════════════════════════════════════════════════════

  Future<void> _rejectRequest(BookingRequestModel request) async {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('رفض'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final success = await _bookingService.rejectBooking(request.id!);
      
      Get.back();

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
  // BUILD UI - ENHANCED WITH MODERN DESIGN
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1F172A) : const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // ═══════════════════════════════════════════════════════════
          // MODERN APP BAR WITH GRADIENT
          // ═══════════════════════════════════════════════════════════
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF2D1B3D) : const Color(0xFF3A7AFE),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'لوحة التحكم',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF2D1B3D),
                            const Color(0xFF1F172A),
                          ]
                        : [
                            const Color(0xFF3A7AFE),
                            const Color(0xFF1D4ED8),
                          ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      left: -20,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              // Refresh button with badge
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 26),
                    onPressed: _loadAllRequests,
                    tooltip: 'تحديث',
                  ),
                  if (_pendingRequests.isNotEmpty)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${_pendingRequests.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),

          // ═══════════════════════════════════════════════════════════
          // STATISTICS CARDS
          // ═══════════════════════════════════════════════════════════
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Pending Stats
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.pending_actions,
                      title: 'قيد الانتظار',
                      count: _pendingRequests.length,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Approved Stats
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.check_circle,
                      title: 'المقبولة',
                      count: _approvedRequests.length,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ═══════════════════════════════════════════════════════════
          // TAB BAR - STICKY
          // ═══════════════════════════════════════════════════════════
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: isDark ? Colors.white : const Color(0xFF3A7AFE),
                unselectedLabelColor: Colors.grey,
                indicatorColor: isDark ? Colors.white : const Color(0xFF3A7AFE),
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('قيد الانتظار'),
                        if (_pendingRequests.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
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
              isDark,
            ),
          ),

          // ═══════════════════════════════════════════════════════════
          // TAB VIEW CONTENT
          // ═══════════════════════════════════════════════════════════
          SliverFillRemaining(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRequestsList(_pendingRequests, 'pending'),
                      _buildRequestsList(_approvedRequests, 'approved'),
                      _buildRequestsList(_rejectedRequests, 'rejected'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // STATISTICS CARD WIDGET
  // ═══════════════════════════════════════════════════════════
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required int count,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD REQUESTS LIST
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
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: BookingRequestCard(
              request: request,
              onApprove: statusType == 'pending'
                  ? () => _approveRequest(request)
                  : () {},
              onReject: statusType == 'pending'
                  ? () => _rejectRequest(request)
                  : () {},
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SLIVER APP BAR DELEGATE FOR STICKY TAB BAR
// ═══════════════════════════════════════════════════════════
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, this.isDark);

  final TabBar _tabBar;
  final bool isDark;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F172A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}