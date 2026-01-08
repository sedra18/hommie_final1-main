  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import 'package:hommie/app/utils/app_colors.dart';
  import 'package:hommie/data/services/bookings_service.dart';

  // ═══════════════════════════════════════════════════════════
  // BOOKING DIALOG CONTROLLER (GetX)
  // ✅ Reactive state management for dialog
  // ✅ Works inside GetX dialogs
  // ✅ Button enables correctly
  // ═══════════════════════════════════════════════════════════

  class BookingDialogController extends GetxController {
    // ✅ Reactive variables
    final Rx<DateTime?> selectedStartDate = Rx<DateTime?>(null);
    final Rx<DateTime?> selectedEndDate = Rx<DateTime?>(null);
    final RxString paymentMethod = 'cash'.obs;
  final RxBool isSubmitting = false.obs;
    // ✅ Computed property for button state
  final BookingService _bookingService = Get.find<BookingService>();

    // ✅ UPDATE canSubmit to include loading check
    bool get canSubmit =>
        selectedStartDate.value != null && 
        selectedEndDate.value != null &&
        !isSubmitting.value; 

    // ✅ Update dates
    void updateDates(DateTime start, DateTime end) {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('📅 [BookingDialogController] Dates updated');
      print('   Start: $start');
      print('   End: $end');
      print('═══════════════════════════════════════════════════════════');

      selectedStartDate.value = start;
      selectedEndDate.value = end;

      print('✅ Reactive state updated');
      print('   selectedStartDate.value: ${selectedStartDate.value}');
      print('   selectedEndDate.value: ${selectedEndDate.value}');
      print('   canSubmit: $canSubmit');
    }

    // ✅ Calculate duration
    int get duration {
      if (selectedStartDate.value == null || selectedEndDate.value == null)
        return 0;
      return selectedEndDate.value!.difference(selectedStartDate.value!).inDays;
    }

    // ✅ Format date for display
    String formatDate(DateTime date) {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    // ✅ Format date for API
    String formatDateForAPI(DateTime date) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }

    // ✅ Submit booking
    Future<void> submitBooking(int apartmentId) async {
      if (selectedStartDate.value == null || selectedEndDate.value == null) {
        Get.snackbar(
          'خطأ',
          'الرجاء اختيار تاريخ الحجز',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      print('');
      print('═══════════════════════════════════════════════════════════');
      print('🚀 [SUBMIT BOOKING - CALLING API]');
      print('   Apartment ID: $apartmentId');
      print('   Start Date: ${formatDateForAPI(selectedStartDate.value!)}');
      print('   End Date: ${formatDateForAPI(selectedEndDate.value!)}');
      print('   Payment Method: ${paymentMethod.value}');
      print('   Duration: $duration days');
      print('──────────────────────────────────────────────────────────');

      // ✅ Set loading state
      isSubmitting.value = true;

      try {
        // ✅ CALL THE ACTUAL API!
        final result = await _bookingService.createBooking(
          apartmentId: apartmentId,
          startDate: formatDateForAPI(selectedStartDate.value!),
          endDate: formatDateForAPI(selectedEndDate.value!),
          paymentMethod: paymentMethod.value,
        );

        print('API Response: $result');
        print('═══════════════════════════════════════════════════════════');

        isSubmitting.value = false;

        // Close dialog
        Get.back();

        // ✅ Check if successful
        if (result['success'] == true) {
          print('✅ Booking created successfully!');
          
          // Show success message (keep Arabic text)
          Get.snackbar(
            'تم الحجز!',
            'تم إرسال طلب الحجز إلى المالك للموافقة!\nمن: ${formatDate(selectedStartDate.value!)}\nإلى: ${formatDate(selectedEndDate.value!)}\nالمدة: $duration ${duration == 1 ? 'يوم' : 'أيام'}',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
            icon: const Icon(Icons.check_circle, color: Colors.white),
            snackPosition: SnackPosition.BOTTOM,
          );
          
        } else {
          print('❌ Booking failed: ${result['message']}');
          
          // Show error message
          Get.snackbar(
            'خطأ',
            result['message'] ?? 'فشل إنشاء الحجز. يرجى المحاولة مرة أخرى.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
            icon: const Icon(Icons.error, color: Colors.white),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        
      } catch (e) {
        print('❌ Exception creating booking: $e');
        print('═══════════════════════════════════════════════════════════');
        
        isSubmitting.value = false;
        
        // Close dialog
        Get.back();
        
        // Show error message
        Get.snackbar(
          'خطأ',
          'فشل في إنشاء الحجز: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.error, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // DATE RANGE PICKER WIDGET
  // ✅ Works with GetX reactive state
  // ═══════════════════════════════════════════════════════════

  class BookingDateRangePicker extends StatelessWidget {
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
    Widget build(BuildContext context) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            // Date display
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
                  Expanded(
                    child: _buildDateDisplay(
                      icon: Icons.calendar_today,
                      label: 'Check In',
                      date: initialStartDate,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  Expanded(
                    child: _buildDateDisplay(
                      icon: Icons.event,
                      label: 'Check Out',
                      date: initialEndDate,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Select button
            InkWell(
              onTap: () => _selectDateRange(context),
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
                      initialStartDate == null || initialEndDate == null
                          ? 'اختر تاريخ الحجز'
                          : 'تغيير التاريخ',
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

            // Duration display
            if (initialStartDate != null && initialEndDate != null)
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
                        '${initialEndDate!.difference(initialStartDate!).inDays} ${initialEndDate!.difference(initialStartDate!).inDays == 1 ? 'يوم' : 'أيام'}',
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
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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

    Future<void> _selectDateRange(BuildContext context) async {
      final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        initialDateRange: initialStartDate != null && initialEndDate != null
            ? DateTimeRange(start: initialStartDate!, end: initialEndDate!)
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
        print('');
        print('═══════════════════════════════════════════════════════════');
        print('📅 DATE RANGE SELECTED IN PICKER');
        print('   Start: ${picked.start}');
        print('   End: ${picked.end}');
        print('   Calling callback...');
        print('═══════════════════════════════════════════════════════════');

        onDateRangeSelected(picked.start, picked.end);
      }
    }

    String _formatDate(DateTime date) {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  // ═══════════════════════════════════════════════════════════
  // BOOKING DIALOG
  // ✅ Uses GetX reactive controller
  // ✅ Button enables automatically when dates selected
  // ═══════════════════════════════════════════════════════════

  void showBookingDialog({required int apartmentId}) {
    final controller = Get.put(BookingDialogController());

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(
                        Icons.event_available,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'حجز الشقة',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Date Picker
                  const Text(
                    'اختر تاريخ الحجز',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  Obx(
                    () => BookingDateRangePicker(
                      initialStartDate: controller.selectedStartDate.value,
                      initialEndDate: controller.selectedEndDate.value,
                      onDateRangeSelected: controller.updateDates,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Payment Method
                  const Text(
                    'طريقة الدفع',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  Obx(
                    () => Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: const Row(
                              children: [
                                Icon(Icons.money, color: Colors.green, size: 20),
                                SizedBox(width: 8),
                                Text('نقداً (Cash)'),
                              ],
                            ),
                            value: 'cash',
                            groupValue: controller.paymentMethod.value,
                            activeColor: AppColors.primary,
                            onChanged: (value) {
                              controller.paymentMethod.value = value!;
                            },
                          ),
                          const Divider(height: 1),
                          RadioListTile<String>(
                            title: const Row(
                              children: [
                                Icon(
                                  Icons.credit_card,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text('بطاقة ائتمان'),
                              ],
                            ),
                            value: 'credit_card',
                            groupValue: controller.paymentMethod.value,
                            activeColor: AppColors.primary,
                            onChanged: (value) {
                              controller.paymentMethod.value = value!;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Status Indicator & Button
                  Obx(
                    () => Column(
                      children: [
                        // Status indicator
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: controller.canSubmit
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                controller.canSubmit
                                    ? Icons.check_circle
                                    : Icons.warning,
                                size: 20,
                                color: controller.canSubmit
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                controller.canSubmit
                                    ? 'جاهز للحجز ✓'
                                    : 'الرجاء اختيار التواريخ أولاً',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: controller.canSubmit
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Confirm button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.canSubmit
                                ? () {
                                    print('🔘 BUTTON PRESSED!');
                                    print(
                                      '   Start: ${controller.selectedStartDate.value}',
                                    );
                                    print(
                                      '   End: ${controller.selectedEndDate.value}',
                                    );
                                    print(
                                      '   Can Submit: ${controller.canSubmit}',
                                    );
                                    controller.submitBooking(apartmentId);
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

    // ═══════════════════════════════════════════════════════════
    // EXAMPLE USAGE
    // ═══════════════════════════════════════════════════════════

    // In your apartment details screen, call:
    // showBookingDialog(apartmentId: apartment.id);