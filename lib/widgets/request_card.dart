
import 'package:flutter/material.dart';
import 'package:hommie/data/models/bookings/bookings_request_model.dart';


class BookingRequestCard extends StatelessWidget {
  final BookingRequestModel request;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onMessage;

  const BookingRequestCard({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onReject,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
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
                  backgroundColor: Colors.blue[100],
                  backgroundImage: request.userAvatar != null
                      ? NetworkImage(request.userAvatar!)
                      : null,
                  child: request.userAvatar == null
                      ? Text(
                          request.userName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
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
                  onPressed: onReject,
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
                    onPressed: onApprove,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
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
                    onPressed: onMessage,
                    icon: const Icon(Icons.message, size: 18),
                    label: const Text('Message'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.blue, width: 1.5),
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