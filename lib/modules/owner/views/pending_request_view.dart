import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/modules/owner/controllers/pending_request_controller.dart';
import 'package:hommie/widgets/request_card.dart';



class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OwnerDashboardController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
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
                Obx(() => Text(
                  '${controller.pendingRequests.length} requests waiting',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                )),
              ],
            ),
          ),

          // Requests list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.pendingRequests.isEmpty) {
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
                onRefresh: controller.refreshRequests,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.pendingRequests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final request = controller.pendingRequests[index];
                    return BookingRequestCard(
                      request: request,
                      onApprove: () => controller.approveRequest(request),
                      onReject: () => controller.rejectRequest(request),
                      onMessage: () => controller.goToMessages(request),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
