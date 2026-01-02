import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/services/bookings_service.dart';
import 'package:hommie/data/models/bookings/bookings_request_model.dart';
import 'package:hommie/widgets/request_card.dart';

// ═══════════════════════════════════════════════════════════
// CORRECTED OWNER DASHBOARD SCREEN
// ✅ Uses BookingRequestModel (correct model name)
// ✅ Handles nullable status properly
// ✅ Complete API integration
// ═══════════════════════════════════════════════════════════

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final BookingService _bookingService = Get.find<BookingService>();
  List<BookingRequestModel> _pendingRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🏠 OWNER DASHBOARD INITIALIZED');
    print('──────────────────────────────────────────────────────────');
    _loadPendingRequests();
  }

  // ═══════════════════════════════════════════════════════════
  // LOAD PENDING BOOKING REQUESTS FROM API
  // ═══════════════════════════════════════════════════════════
  Future<void> _loadPendingRequests() async {
    print('📥 Loading pending requests...');
    setState(() => _isLoading = true);
    
    try {
      final requests = await _bookingService.getPendingBookings();
      
      setState(() {
        _pendingRequests = requests;
        _isLoading = false;
      });
      
      print('✅ Loaded ${requests.length} pending requests');
      print('═══════════════════════════════════════════════════════════');
    } catch (e) {
      print('❌ Error loading requests: $e');
      print('═══════════════════════════════════════════════════════════');
      setState(() => _isLoading = false);
      
      Get.snackbar(
        'Error',
        'Failed to load booking requests',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // APPROVE BOOKING REQUEST
  // ═══════════════════════════════════════════════════════════
  Future<void> _approveRequest(BookingRequestModel request) async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('✅ APPROVING REQUEST');
    print('   Booking ID: ${request.id}');
    print('   User: ${request.userName}');
    print('──────────────────────────────────────────────────────────');

    // Confirm with user
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text('Approve Booking'),
          ],
        ),
        content: Text(
          'Approve booking request from ${request.userName ?? 'Unknown User'}?\n\n'
          'Dates: ${request.startDate} - ${request.endDate}\n'
          'Payment: ${request.paymentMethod.toUpperCase()}',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Ensure we have a valid booking ID
      if (request.id == null) {
        Get.snackbar(
          'Error',
          'Invalid booking ID',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Show loading
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
        barrierDismissible: false,
      );

      final success = await _bookingService.approveBooking(request.id!);
      
      Get.back(); // Close loading dialog

      if (success) {
        print('✅ Booking approved successfully');
        print('═══════════════════════════════════════════════════════════');
        
        Get.snackbar(
          'Success',
          'Booking approved successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 3),
        );
        
        // Reload the list
        await _loadPendingRequests();
      } else {
        print('❌ Failed to approve booking');
        print('═══════════════════════════════════════════════════════════');
        
        Get.snackbar(
          'Error',
          'Failed to approve booking. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } else {
      print('ℹ️ Approval cancelled by user');
      print('═══════════════════════════════════════════════════════════');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // REJECT BOOKING REQUEST
  // ═══════════════════════════════════════════════════════════
  Future<void> _rejectRequest(BookingRequestModel request) async {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('❌ REJECTING REQUEST');
    print('   Booking ID: ${request.id}');
    print('   User: ${request.userName}');
    print('──────────────────────────────────────────────────────────');

    // Confirm with user
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text('Reject Booking'),
          ],
        ),
        content: Text(
          'Reject booking request from ${request.userName ?? 'Unknown User'}?\n\n'
          'This action cannot be undone.',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Ensure we have a valid booking ID
      if (request.id == null) {
        Get.snackbar(
          'Error',
          'Invalid booking ID',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Show loading
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Colors.red),
        ),
        barrierDismissible: false,
      );

      final success = await _bookingService.rejectBooking(request.id!);
      
      Get.back(); // Close loading dialog

      if (success) {
        print('✅ Booking rejected successfully');
        print('═══════════════════════════════════════════════════════════');
        
        Get.snackbar(
          'Rejected',
          'Booking request has been rejected',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          icon: const Icon(Icons.info, color: Colors.white),
          duration: const Duration(seconds: 3),
        );
        
        // Reload the list
        await _loadPendingRequests();
      } else {
        print('❌ Failed to reject booking');
        print('═══════════════════════════════════════════════════════════');
        
        Get.snackbar(
          'Error',
          'Failed to reject booking. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } else {
      print('ℹ️ Rejection cancelled by user');
      print('═══════════════════════════════════════════════════════════');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // GO TO MESSAGES (PLACEHOLDER)
  // ═══════════════════════════════════════════════════════════
  void _goToMessages(BookingRequestModel request) {
    print('💬 Opening messages with ${request.userName ?? "user"}');
    
    Get.snackbar(
      'Messages',
      'Chat feature coming soon',
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
        title: const Text('Owner Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingRequests,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Blue header background
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pending Requests',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_pendingRequests.length} ${_pendingRequests.length == 1 ? 'request' : 'requests'} waiting',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Requests list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  )
                : _pendingRequests.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadPendingRequests,
                        color: Colors.blue,
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
                      ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // EMPTY STATE WIDGET
  // ═══════════════════════════════════════════════════════════
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            'No Pending Requests',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'New booking requests from renters will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 30),
          OutlinedButton.icon(
            onPressed: _loadPendingRequests,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: const BorderSide(color: Colors.blue),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}