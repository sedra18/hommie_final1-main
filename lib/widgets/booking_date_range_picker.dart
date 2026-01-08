import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/app/utils/app_colors.dart';

// ═══════════════════════════════════════════════════════════
// BOOKING DATE CONTROLLER (GetX)
// ✅ Manages date state reactively
// ✅ Works inside GetX dialogs
// ═══════════════════════════════════════════════════════════

class BookingDateController extends GetxController {
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);

  void updateDates(DateTime start, DateTime end) {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📅 [BookingDateController] Dates updated');
    print('   Start: $start');
    print('   End: $end');
    print('═══════════════════════════════════════════════════════════');
    
    startDate.value = start;
    endDate.value = end;
    
    print('✅ Reactive state updated');
    print('   startDate.value: ${startDate.value}');
    print('   endDate.value: ${endDate.value}');
  }

  void reset() {
    startDate.value = null;
    endDate.value = null;
  }

  int get duration {
    if (startDate.value == null || endDate.value == null) return 0;
    return endDate.value!.difference(startDate.value!).inDays;
  }
}

// ═══════════════════════════════════════════════════════════
// DATE RANGE PICKER FOR BOOKING
// ✅ Select start_date and end_date together
// ✅ Beautiful UI with calendar
// ✅ Validates dates (end > start)
// ✅ Returns formatted dates for API
// ✅ WORKS WITH GETX REACTIVE STATE
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
  void didUpdateWidget(BookingDateRangePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ Update local state when parent changes
    if (widget.initialStartDate != oldWidget.initialStartDate ||
        widget.initialEndDate != oldWidget.initialEndDate) {
      setState(() {
        startDate = widget.initialStartDate;
        endDate = widget.initialEndDate;
      });
    }
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
                const Icon(
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
                  const Icon(
                    Icons.date_range,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    startDate == null || endDate == null
                        ? 'Choose the reservation date'
                        : 'Change date',
                    style: const TextStyle(
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
                      '${_calculateDuration()} ${_calculateDuration() == 1 ? 'Day' : 'Days'}',
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
            colorScheme: const ColorScheme.light(
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
// BOOKING SCREEN - WITH GETX REACTIVE STATE
// ✅ Button enables when dates selected
// ✅ Works in GetX dialogs
// ✅ Payment method radio buttons visible
// ═══════════════════════════════════════════════════════════

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // ✅ Use GetX controller for reactive state
  final BookingDateController _dateController = Get.put(BookingDateController());
  final RxString paymentMethod = 'cash'.obs;

  @override
  void dispose() {
    _dateController.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Apartment'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        
            const Text(
              'اختر تاريخ الحجز',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // ✅ Wrapped with Obx to listen to reactive changes
            Obx(() => BookingDateRangePicker(
              initialStartDate: _dateController.startDate.value,
              initialEndDate: _dateController.endDate.value,
              onDateRangeSelected: (start, end) {
                print('');
                print('═══════════════════════════════════════════════════════════');
                print('📅 [BOOKING SCREEN] Date range callback received');
                print('   Start: $start');
                print('   End: $end');
                print('═══════════════════════════════════════════════════════════');
                
                _dateController.updateDates(start, end);

                print('✅ Controller updated!');
                print('   Button enabled: ${_dateController.startDate.value != null && _dateController.endDate.value != null}');
              },
            )),

            const SizedBox(height: 24),

            // ═══════════════════════════════════════════════════════════
            // DEBUG INFO BOX (Shows selected dates)
            // ═══════════════════════════════════════════════════════════
            Obx(() {
              if (_dateController.startDate.value != null && 
                  _dateController.endDate.value != null) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✅ التواريخ المحددة:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('من: ${_formatDate(_dateController.startDate.value!)}'),
                      Text('إلى: ${_formatDate(_dateController.endDate.value!)}'),
                      Text('المدة: ${_dateController.duration} ${_dateController.duration == 1 ? 'يوم' : 'أيام'}'),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // ═══════════════════════════════════════════════════════════
            // PAYMENT METHOD SECTION
            // ═══════════════════════════════════════════════════════════
            const Text(
              'طريقة الدفع',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // ✅ Payment method card
            Obx(() => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  // Cash option
                  RadioListTile<String>(
                    title: const Row(
                      children: [
                        Icon(Icons.money, color: Colors.green),
                        SizedBox(width: 8),
                        Text('نقداً (Cash)'),
                      ],
                    ),
                    value: 'cash',
                    groupValue: paymentMethod.value,
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      print('💳 Payment method changed to: $value');
                      paymentMethod.value = value!;
                    },
                  ),
                  
                  const Divider(height: 1),
                  
                  // Credit card option
                  RadioListTile<String>(
                    title: const Row(
                      children: [
                        Icon(Icons.credit_card, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('بطاقة ائتمان (Credit Card)'),
                      ],
                    ),
                    value: 'credit_card',
                    groupValue: paymentMethod.value,
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      print('💳 Payment method changed to: $value');
                      paymentMethod.value = value!;
                    },
                  ),
                ],
              ),
            )),

            const SizedBox(height: 32),

            // ═══════════════════════════════════════════════════════════
            // SUBMIT BUTTON SECTION
            // ═══════════════════════════════════════════════════════════
            SizedBox(
              width: double.infinity,
              child: Obx(() {
                final canSubmit = _dateController.startDate.value != null && 
                                  _dateController.endDate.value != null;
                
                return Column(
                  children: [
                    // ✅ Status indicator
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: canSubmit
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            canSubmit
                                ? Icons.check_circle
                                : Icons.warning,
                            size: 20,
                            color: canSubmit
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            canSubmit
                                ? 'جاهز للحجز ✓'
                                : 'الرجاء اختيار التواريخ أولاً',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: canSubmit
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ✅ Confirm booking button
                    ElevatedButton(
                      onPressed: canSubmit
                          ? () {
                              print('');
                              print('🔘 BUTTON PRESSED!');
                              print('   Start: ${_dateController.startDate.value}');
                              print('   End: ${_dateController.endDate.value}');
                              print('   Payment: ${paymentMethod.value}');
                              _submitBooking();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.grey.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'تأكيد الحجز',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SUBMIT BOOKING
  // ═══════════════════════════════════════════════════════════
  
  void _submitBooking() {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('🚀 [SUBMIT BOOKING] Called');
    print('═══════════════════════════════════════════════════════════');

    if (_dateController.startDate.value == null || _dateController.endDate.value == null) {
      print('❌ Dates are null!');
      
      Get.snackbar(
        'خطأ',
        'الرجاء اختيار تاريخ الحجز',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // ✅ Format dates for API (YYYY-MM-DD)
    final startDateStr = _formatDateForAPI(_dateController.startDate.value!);
    final endDateStr = _formatDateForAPI(_dateController.endDate.value!);

    // ✅ Create JSON body
    final bookingData = {
      "apartment_id": 3,
      "start_date": startDateStr,
      "end_date": endDateStr,
      "payment_method": paymentMethod.value,
    };

    print('📤 BOOKING REQUEST');
    print('   JSON: $bookingData');
    print('   Duration: ${_dateController.duration} days');
    print('═══════════════════════════════════════════════════════════');

    // TODO: Send to API
    // Example: await bookingService.createBooking(bookingData);
    
    Get.snackbar(
      'تم الحجز!',
      'من: $startDateStr\nإلى: $endDateStr\nالمدة: ${_dateController.duration} ${_dateController.duration == 1 ? 'يوم' : 'أيام'}\nالدفع: ${paymentMethod.value == 'cash' ? 'نقداً' : 'بطاقة ائتمان'}',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      snackPosition: SnackPosition.TOP,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════
  
  // Format for display (DD/MM/YYYY)
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // ✅ Format for API (YYYY-MM-DD)
  String _formatDateForAPI(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}