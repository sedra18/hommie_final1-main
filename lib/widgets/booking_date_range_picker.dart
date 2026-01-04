import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/app/utils/app_colors.dart';

// ═══════════════════════════════════════════════════════════
// DATE RANGE PICKER FOR BOOKING
// ✅ Select start_date and end_date together
// ✅ Beautiful UI with calendar
// ✅ Validates dates (end > start)
// ✅ Returns formatted dates for API
// ═══════════════════════════════════════════════════════════

class BookingDateRangePicker extends StatefulWidget {
  final Function(DateTime startDate, DateTime endDate) onDateRangeSelected;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const BookingDateRangePicker({
    super.key,
    required this.onDateRangeSelected,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<BookingDateRangePicker> createState() => _BookingDateRangePickerState();
}

class _BookingDateRangePickerState extends State<BookingDateRangePicker> {
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    startDate = widget.initialStartDate;
    endDate = widget.initialEndDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // ✅ Display Selected Dates
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Start Date
                Expanded(
                  child: _buildDateDisplay(
                    icon: Icons.calendar_today,
                    label: 'Check In',
                    date: startDate,
                  ),
                ),
                
                // Arrow
                Icon(
                  Icons.arrow_forward,
                  color: AppColors.primary,
                  size: 20,
                ),
                
                // End Date
                Expanded(
                  child: _buildDateDisplay(
                    icon: Icons.event,
                    label: 'Check Out',
                    date: endDate,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ✅ Select Button
          InkWell(
            onTap: _selectDateRange,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.date_range,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    startDate == null || endDate == null
                        ? 'اختر تاريخ الحجز'
                        : 'تغيير التاريخ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ Duration Display (if dates selected)
          if (startDate != null && endDate != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.green.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_calculateDuration()} ${_calculateDuration() == 1 ? 'يوم' : 'أيام'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD DATE DISPLAY
  // ═══════════════════════════════════════════════════════════
  
  Widget _buildDateDisplay({
    required IconData icon,
    required String label,
    required DateTime? date,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          date == null ? '--/--/----' : _formatDate(date),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: date == null ? Colors.grey : Colors.black87,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SELECT DATE RANGE
  // ✅ Opens Flutter's DateRangePicker
  // ═══════════════════════════════════════════════════════════
  
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(), // ✅ Can't select past dates
      lastDate: DateTime.now().add(const Duration(days: 365)), // ✅ Up to 1 year ahead
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });

      // ✅ Call callback with selected dates
      widget.onDateRangeSelected(picked.start, picked.end);

      print('');
      print('═══════════════════════════════════════════════════════════');
      print('📅 DATE RANGE SELECTED');
      print('   Start: ${_formatDateForAPI(picked.start)}');
      print('   End: ${_formatDateForAPI(picked.end)}');
      print('   Duration: ${_calculateDuration()} days');
      print('═══════════════════════════════════════════════════════════');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════
  
  // Calculate duration in days
  int _calculateDuration() {
    if (startDate == null || endDate == null) return 0;
    return endDate!.difference(startDate!).inDays;
  }

  // Format for display (DD/MM/YYYY)
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // ✅ Format for API (YYYY-MM-DD)
  String _formatDateForAPI(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// ═══════════════════════════════════════════════════════════
// EXAMPLE USAGE IN BOOKING SCREEN
// ═══════════════════════════════════════════════════════════

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String paymentMethod = 'cash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Apartment'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Date Range Picker
            const Text(
              'اختر تاريخ الحجز',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            BookingDateRangePicker(
              onDateRangeSelected: (start, end) {
                setState(() {
                  selectedStartDate = start;
                  selectedEndDate = end;
                });
              },
            ),

            const SizedBox(height: 24),

            // Payment Method
            const Text(
              'طريقة الدفع',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            RadioListTile<String>(
              title: const Text('نقداً (Cash)'),
              value: 'cash',
              groupValue: paymentMethod,
              onChanged: (value) {
                setState(() {
                  paymentMethod = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('بطاقة ائتمان (Credit Card)'),
              value: 'credit_card',
              groupValue: paymentMethod,
              onChanged: (value) {
                setState(() {
                  paymentMethod = value!;
                });
              },
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedStartDate != null && selectedEndDate != null
                    ? _submitBooking
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'تأكيد الحجز',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SUBMIT BOOKING
  // ✅ Format dates for API
  // ═══════════════════════════════════════════════════════════
  
  void _submitBooking() {
    if (selectedStartDate == null || selectedEndDate == null) {
      Get.snackbar(
        'خطأ',
        'الرجاء اختيار تاريخ الحجز',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // ✅ Format dates for API (YYYY-MM-DD)
    final startDateStr = _formatDateForAPI(selectedStartDate!);
    final endDateStr = _formatDateForAPI(selectedEndDate!);

    // ✅ Create JSON body
    final bookingData = {
      "apartment_id": 3,
      "start_date": startDateStr,
      "end_date": endDateStr,
      "payment_method": paymentMethod,
    };

    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📤 BOOKING REQUEST');
    print('   JSON: $bookingData');
    print('═══════════════════════════════════════════════════════════');

    // TODO: Send to API
    Get.snackbar(
      'جاري الحجز...',
      'Start: $startDateStr\nEnd: $endDateStr',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // ✅ Format date for API (YYYY-MM-DD)
  String _formatDateForAPI(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}