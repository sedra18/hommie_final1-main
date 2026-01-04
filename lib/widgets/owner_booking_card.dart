import 'package:flutter/material.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/data/models/bookings/bookings_request_model.dart';

// ═══════════════════════════════════════════════════════════
// OWNER BOOKING CARD - FOR REJECTED & APPROVED
// ✅ Shows booking details with appropriate status
// ✅ No action buttons (already processed)
// ═══════════════════════════════════════════════════════════

class OwnerBookingCard extends StatelessWidget {
  final BookingRequestModel booking;
  final String status; // 'rejected' or 'approved'

  const OwnerBookingCard({
    super.key,
    required this.booking,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isRejected = status.toLowerCase() == 'rejected';
    final isApproved = status.toLowerCase() == 'approved';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _getStatusColor().withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // ✅ STATUS HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(),
                    ),
                  ),
                ),
                // Booking ID badge
                if (booking.id != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#${booking.id}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ✅ BOOKING DETAILS
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ RENTER INFO
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.userName ?? 'مستأجر',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (booking.userEmail != null)
                            Text(
                              booking.userEmail!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ✅ APARTMENT INFO
                _buildInfoRow(
                  icon: Icons.apartment,
                  label: 'الشقة',
                  value: booking.apartmentTitle ?? '--',
                  color: AppColors.primary,
                ),

                const SizedBox(height: 12),

                // ✅ DATES
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        icon: Icons.calendar_today,
                        label: 'من',
                        value: booking.startDate ?? '--',
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoRow(
                        icon: Icons.event,
                        label: 'إلى',
                        value: booking.endDate ?? '--',
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ✅ PAYMENT METHOD
                _buildInfoRow(
                  icon: booking.paymentMethod?.toLowerCase() == 'cash'
                      ? Icons.money
                      : Icons.credit_card,
                  label: 'طريقة الدفع',
                  value: _getPaymentMethodText(),
                  color: Colors.green,
                ),

                const SizedBox(height: 16),

                // ✅ TIMESTAMPS
                Divider(color: Colors.grey.shade300),
                const SizedBox(height: 12),

                if (booking.createdAt != null)
                  _buildTimestamp(
                    'تاريخ الطلب',
                    booking.createdAt!,
                    Icons.access_time,
                  ),

                if (booking.updatedAt != null && booking.updatedAt != booking.createdAt) ...[
                  const SizedBox(height: 8),
                  _buildTimestamp(
                    isRejected ? 'تاريخ الرفض' : 'تاريخ القبول',
                    booking.updatedAt!,
                    isRejected ? Icons.cancel : Icons.check_circle,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD INFO ROW
  // ═══════════════════════════════════════════════════════════

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD TIMESTAMP
  // ═══════════════════════════════════════════════════════════

  Widget _buildTimestamp(String label, String timestamp, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          timestamp,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // STATUS HELPERS
  // ═══════════════════════════════════════════════════════════

  Color _getStatusColor() {
    return status.toLowerCase() == 'rejected'
        ? Colors.red
        : Colors.green;
  }

  IconData _getStatusIcon() {
    return status.toLowerCase() == 'rejected'
        ? Icons.cancel
        : Icons.check_circle;
  }

  String _getStatusText() {
    return status.toLowerCase() == 'rejected'
        ? 'مرفوض'
        : 'مقبول';
  }

  String _getPaymentMethodText() {
    if (booking.paymentMethod == null) return '--';
    switch (booking.paymentMethod!.toLowerCase()) {
      case 'cash':
        return 'نقداً';
      case 'credit_card':
        return 'بطاقة ائتمان';
      default:
        return booking.paymentMethod!;
    }
  }
}