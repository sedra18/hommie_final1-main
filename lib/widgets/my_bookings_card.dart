import 'package:flutter/material.dart';
import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/data/models/bookings/bookings_request_model.dart';

// ═══════════════════════════════════════════════════════════
// MY BOOKING CARD - FOR RENTER
// ✅ Shows booking details
// ✅ Different styles for each status
// ✅ Cancel button for pending
// ═══════════════════════════════════════════════════════════

class MyBookingCard extends StatelessWidget {
  final BookingRequestModel booking;
  final String status; // 'pending', 'rejected', 'approved', 'completed'
  final VoidCallback? onCancel;

  const MyBookingCard({
    super.key,
    required this.booking,
    required this.status,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
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

          // ✅ APARTMENT INFO
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Apartment Title
                Row(
                  children: [
                    Icon(Icons.apartment, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking.apartmentTitle ?? 'شقة',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ✅ DATES
                _buildInfoRow(
                  icon: Icons.calendar_today,
                  label: 'من',
                  value: booking.startDate ?? '--',
                  color: Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.event,
                  label: 'إلى',
                  value: booking.endDate ?? '--',
                  color: Colors.blue,
                ),

                const SizedBox(height: 16),

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

                // ✅ OWNER INFO (if available)
                if (booking.ownerName != null) ...[
                  _buildInfoRow(
                    icon: Icons.person,
                    label: 'المالك',
                    value: booking.ownerName!,
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 16),
                ],

                // ✅ CREATED DATE
                if (booking.createdAt != null)
                  Text(
                    'تاريخ الطلب: ${booking.createdAt}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),

                // ✅ CANCEL BUTTON (for pending only)
                if (onCancel != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.cancel, size: 20),
                      label: const Text('إلغاء الحجز'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
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
                  fontSize: 15,
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
  // STATUS HELPERS
  // ═══════════════════════════════════════════════════════════

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'approved':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'rejected':
        return Icons.cancel;
      case 'approved':
        return Icons.check_circle;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText() {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'في انتظار موافقة المالك';
      case 'rejected':
        return 'مرفوض من المالك';
      case 'approved':
        return 'مقبول ✓';
      case 'completed':
        return 'مكتمل';
      default:
        return 'غير معروف';
    }
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