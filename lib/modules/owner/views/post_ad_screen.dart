import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/data/models/bookings/bookings_request_model.dart';
import 'package:hommie/modules/owner/controllers/pending_request_controller.dart';
import 'package:hommie/modules/owner/controllers/post_ad_controller.dart';
import 'package:hommie/modules/owner/views/apartment_form_view.dart';
import 'package:hommie/widgets/apartment_card.dart';




class PostAdScreen extends StatefulWidget {
  const PostAdScreen({super.key});

  @override
  State<PostAdScreen> createState() => _PostAdViewState();
}

class _PostAdViewState extends State<PostAdScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final c = Get.find<PostAdController>();
  
  // ✅ ADD DASHBOARD CONTROLLER
  late final OwnerDashboardController dashboardController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    c.load();
    
    // ✅ INITIALIZE DASHBOARD CONTROLLER
    dashboardController = Get.put(OwnerDashboardController());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Post Ad"),
        bottom: TabBar(
          labelColor: AppColors.backgroundLight,
          unselectedLabelColor: AppColors.textPrimaryLight,
          controller: _tabController,
          tabs: const [
            Tab(text: "Add a Flat"),
            Tab(text: "Pending Requests"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ═══════════════════════════════════════════════════════
          // TAB 1: ADD APARTMENT (Your existing code)
          // ═══════════════════════════════════════════════════════
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    icon: const Icon(
                      Icons.add,
                      color: AppColors.backgroundLight,
                    ),
                    label: const Text(
                      "Adding New Flat",
                      style: TextStyle(color: AppColors.backgroundLight),
                    ),
                    onPressed: () {
                      c.startNewDraft();
                      Get.to(() => const ApartmentFormView(isEdit: false));
                    },
                  ),
                ),
                const SizedBox(height: 14),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Last Flats",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 10),
                
                // Horizontal List
                SizedBox(
                  height: 140,
                  child: Obx(() {
                    final list = c.myApartments;
                    if (list.isEmpty) {
                      return const Center(child: Text("There are no flats yet"));
                    }
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) {
                        final apt = list[i];
                        return SizedBox(
                          width: 260,
                          child: ApartmentCard(
                            apartment: apt,
                            showOwnerActions: true,
                          ),
                        );
                      },
                    );
                  }),
                ),

                const SizedBox(height: 14),

                // Vertical List
                Expanded(
                  child: Obx(() {
                    final list = c.myApartments;
                    if (list.isEmpty) {
                      return const Center(child: Text("لا يوجد شقق منشورة"));
                    }
                    return ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => ApartmentCard(
                        apartment: list[i],
                        showOwnerActions: true,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // ═══════════════════════════════════════════════════════
          // TAB 2: PENDING REQUESTS (Owner Dashboard)
          // ═══════════════════════════════════════════════════════
          _buildPendingRequestsTab(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 🆕 PENDING REQUESTS TAB CONTENT
  // ═══════════════════════════════════════════════════════════
  Widget _buildPendingRequestsTab() {
    return Obx(() {
      if (dashboardController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (dashboardController.pendingRequests.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No Pending Requests',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'New booking requests will appear here',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: dashboardController.refreshRequests,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: dashboardController.pendingRequests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final request = dashboardController.pendingRequests[index];
            return _buildBookingRequestCard(request);
          },
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════
  // 🆕 BOOKING REQUEST CARD
  // ═══════════════════════════════════════════════════════════
  Widget _buildBookingRequestCard(BookingRequestModel request) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with user info and close button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // User avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: request.userAvatar != null
                      ? NetworkImage(request.userAvatar!)
                      : null,
                  child: request.userAvatar == null
                      ? Text(
                          request.userName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // User details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.dateRange,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            _getPaymentIcon(request.paymentMethod),
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            request.paymentMethod.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Close/Reject button
                IconButton(
                  onPressed: () => dashboardController.rejectRequest(request),
                  icon: const Icon(Icons.close, color: Colors.grey),
                  tooltip: 'Reject',
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Accept button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => dashboardController.approveRequest(request),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.backgroundLight,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Message button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => dashboardController.goToMessages(request),
                    icon: const Icon(Icons.message, size: 18),
                    label: const Text('Message'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 🆕 HELPER: Get Payment Icon
  // ═══════════════════════════════════════════════════════════
  IconData _getPaymentIcon(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return Icons.payments_outlined;
      case 'credit_card':
      case 'card':
        return Icons.credit_card;
      case 'paypal':
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }
}