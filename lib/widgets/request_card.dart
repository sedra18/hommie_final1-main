import 'package:flutter/material.dart';
import 'package:hommie/data/models/bookings/bookings_request_model.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:intl/intl.dart';

// ═══════════════════════════════════════════════════════════
// BOOKING REQUEST CARD - ENHANCED WITH UPDATE REQUESTS
// ✅ Shows NEW BOOKING requests (initial bookings)
// ✅ Shows UPDATE REQUESTS (date change requests)
// ✅ Highlights changes in update requests
// ✅ Different actions based on request type
// ═══════════════════════════════════════════════════════════

class BookingRequestCard extends StatelessWidget {
  final BookingRequestModel request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const BookingRequestCard({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Determine if this is an update request
    final isUpdateRequest = request.isUpdateRequest ?? false;
    final isPending = request.status?.toLowerCase() == 'pending_owner_approval' ||
                      request.status?.toLowerCase() == 'pending';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUpdateRequest 
                ? Colors.purple.withOpacity(0.3) 
                : Colors.orange.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════════════════════════════════════════════════════════
            // HEADER - Request Type Badge
            // ═══════════════════════════════════════════════════════════
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUpdateRequest
                    ? Colors.purple.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isUpdateRequest ? Icons.update : Icons.new_releases,
                    color: isUpdateRequest ? Colors.purple : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isUpdateRequest ? 'UPDATE REQUEST' : 'NEW BOOKING',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isUpdateRequest ? Colors.purple : Colors.orange,
                      ),
                    ),
                  ),
                  Text(
                    '#${request.id ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // ═══════════════════════════════════════════════════════════
            // CONTENT
            // ═══════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Renter Info
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        radius: 24,
                        backgroundImage: request.userAvatar != null
                            ? NetworkImage(request.userAvatar!)
                            : null,
                        child: request.userAvatar == null
                            ? Icon(
                                Icons.person,
                                color: AppColors.primary,
                                size: 24,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.userName ?? 'Renter',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (request.userEmail != null)
                              Text(
                                request.userEmail!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Apartment Title
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.home, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            request.apartmentTitle ?? 'Apartment',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ✅ NEW: Show changes if it's an update request
                  if (isUpdateRequest && 
                      request.originalStartDate != null && 
                      request.originalEndDate != null) ...[
                    _buildUpdateChanges(request),
                    const SizedBox(height: 16),
                  ],

                  // Dates Section
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUpdateRequest
                          ? Colors.purple.shade50
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isUpdateRequest
                            ? Colors.purple.shade200
                            : Colors.blue.shade200,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildDateRow(
                          icon: Icons.calendar_today,
                          label: 'Check In:',
                          date: request.startDate,
                        ),
                        const Divider(height: 16),
                        _buildDateRow(
                          icon: Icons.event,
                          label: 'Check Out:',
                          date: request.endDate,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Additional Info
                  Row(
                    children: [
                      // Payment Method
                      if (request.paymentMethod != null)
                        Expanded(
                          child: _buildInfoChip(
                            icon: request.paymentMethod?.toLowerCase() == 'cash'
                                ? Icons.money
                                : Icons.credit_card,
                            label: request.paymentMethod!,
                            color: Colors.green,
                          ),
                        ),
                      
                      if (request.paymentMethod != null)
                        const SizedBox(width: 8),

                      // Duration
                      Expanded(
                        child: _buildInfoChip(
                          icon: Icons.access_time,
                          label: '${_calculateDuration()} days',
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),

                  // ✅ Action Buttons - Only show if PENDING
                  if (isPending) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Approve Button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onApprove,
                            icon: const Icon(Icons.check, size: 18),
                            label: Text(
                              isUpdateRequest ? 'Approve Update' : 'Approve',
                              style: const TextStyle(fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),

                        // Reject Button
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onReject,
                            icon: const Icon(Icons.close, size: 18),
                            label: Text(
                              isUpdateRequest ? 'Reject Update' : 'Reject',
                              style: const TextStyle(fontSize: 14),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red, width: 1.5),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD UPDATE CHANGES WIDGET
  // ✅ Shows what changed in the update request
  // ═══════════════════════════════════════════════════════════
  
  Widget _buildUpdateChanges(BookingRequestModel request) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.compare_arrows, color: Colors.purple.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Date Changes Requested',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Original Dates
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Original Dates:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _formatDate(request.originalStartDate),
                        style: const TextStyle(
                          fontSize: 13,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward, size: 16, color: Colors.grey[600]),
                    Expanded(
                      child: Text(
                        _formatDate(request.originalEndDate),
                        style: const TextStyle(
                          fontSize: 13,
                          decoration: TextDecoration.lineThrough,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Arrow
          Center(
            child: Icon(Icons.arrow_downward, color: Colors.purple.shade700, size: 20),
          ),
          
          const SizedBox(height: 8),
          
          // New Dates
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Dates:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _formatDate(request.startDate),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward, size: 16, color: Colors.green[600]),
                    Expanded(
                      child: Text(
                        _formatDate(request.endDate),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD DATE ROW
  // ═══════════════════════════════════════════════════════════
  
  Widget _buildDateRow({
    required IconData icon,
    required String label,
    required String? date,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          _formatDate(date),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD INFO CHIP
  // ═══════════════════════════════════════════════════════════
  
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
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

  // ═══════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'N/A';
    }
    
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('dd/MM/yyyy');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }

  int _calculateDuration() {
    if (request.startDate == null || request.endDate == null) return 0;
    
    try {
      final start = DateTime.parse(request.startDate!);
      final end = DateTime.parse(request.endDate!);
      return end.difference(start).inDays;
    } catch (e) {
      return 0;
    }
  }
}