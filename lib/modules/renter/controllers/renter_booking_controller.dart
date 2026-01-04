import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hommie/helpers/base_url.dart';
import 'package:http/http.dart' as http;
import 'package:hommie/data/models/apartment/apartment_model.dart';
import 'package:hommie/app/utils/app_colors.dart';

// ═══════════════════════════════════════════════════════════
// RENTER BOOKING CONTROLLER
// ✅ Handles booking with date range picker
// ✅ Validates dates
// ✅ Submits to API
// ═══════════════════════════════════════════════════════════

class RenterBookingController extends GetxController {
  final box = GetStorage();
  
  // Observables
  final isLoading = false.obs;
  final selectedStartDate = Rx<DateTime?>(null);
  final selectedEndDate = Rx<DateTime?>(null);
  final paymentMethod = 'cash'.obs;
  
  // ═══════════════════════════════════════════════════════════
  // SHOW BOOKING DIALOG
  // ✅ Opens dialog with date picker and payment options
  // ═══════════════════════════════════════════════════════════
  
  void showBookingDialog(ApartmentModel apartment) {
    // Reset dates
    selectedStartDate.value = null;
    selectedEndDate.value = null;
    paymentMethod.value = 'cash';
    
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('📅 OPENING BOOKING DIALOG');
    print('   Apartment: ${apartment.title}');
    print('   ID: ${apartment.id}');
    print('   Price: \$${apartment.pricePerDay}/day');
    print('═══════════════════════════════════════════════════════════');
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ HEADER
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.calendar_month,
                          color: AppColors.primary,
                          size: 28,
                        ),
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
                        icon: const Icon(Icons.close),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // ✅ APARTMENT INFO
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.apartment, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                apartment.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '\$${apartment.pricePerDay}/يوم',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // ✅ DATE RANGE PICKER
                  const Text(
                    'اختر تاريخ الحجز',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildDateRangePicker(),
                  
                  const SizedBox(height: 24),
                  
                  // ✅ PAYMENT METHOD
                  const Text(
                    'طريقة الدفع',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Obx(() => Column(
                    children: [
                      RadioListTile<String>(
                        title: Row(
                          children: [
                            Icon(Icons.money, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            const Text('نقداً (Cash)'),
                          ],
                        ),
                        value: 'cash',
                        groupValue: paymentMethod.value,
                        onChanged: (value) {
                          paymentMethod.value = value!;
                        },
                        activeColor: AppColors.primary,
                      ),
                      RadioListTile<String>(
                        title: Row(
                          children: [
                            Icon(Icons.credit_card, color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            const Text('بطاقة ائتمان (Credit Card)'),
                          ],
                        ),
                        value: 'credit_card',
                        groupValue: paymentMethod.value,
                        onChanged: (value) {
                          paymentMethod.value = value!;
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                  )),
                  
                  const SizedBox(height: 24),
                  
                  // ✅ TOTAL PRICE
                  Obx(() {
                    if (selectedStartDate.value != null && selectedEndDate.value != null) {
                      final duration = _calculateDuration();
                      final totalPrice = duration * apartment.pricePerDay;
                      
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.receipt_long, color: AppColors.primary),
                                const SizedBox(width: 8),
                                const Text(
                                  'المجموع:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$$totalPrice',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  '$duration ${duration == 1 ? 'يوم' : 'أيام'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  
                  const SizedBox(height: 24),
                  
                  // ✅ SUBMIT BUTTON
                  Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading.value
                          ? null
                          : (selectedStartDate.value != null && selectedEndDate.value != null)
                              ? () => submitBooking(apartment)
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'تأكيد الحجز',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: !isLoading.value,
    );
  }
  
  // ═══════════════════════════════════════════════════════════
  // BUILD DATE RANGE PICKER
  // ✅ Displays selected dates and picker button
  // ═══════════════════════════════════════════════════════════
  
  Widget _buildDateRangePicker() {
    return Obx(() => Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Display Selected Dates
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
                    label: 'تسجيل الدخول',
                    date: selectedStartDate.value,
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
                    label: 'تسجيل الخروج',
                    date: selectedEndDate.value,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Select Button
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
                    selectedStartDate.value == null || selectedEndDate.value == null
                        ? 'اختر التاريخ'
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

          // Duration Display
          if (selectedStartDate.value != null && selectedEndDate.value != null)
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
    ));
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
      context: Get.context!,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: selectedStartDate.value != null && selectedEndDate.value != null
          ? DateTimeRange(start: selectedStartDate.value!, end: selectedEndDate.value!)
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
      selectedStartDate.value = picked.start;
      selectedEndDate.value = picked.end;

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
  // SUBMIT BOOKING
  // ✅ Sends booking request to API
  // ═══════════════════════════════════════════════════════════
  
  Future<void> submitBooking(ApartmentModel apartment) async {
    if (selectedStartDate.value == null || selectedEndDate.value == null) {
      Get.snackbar(
        'خطأ',
        'الرجاء اختيار تاريخ الحجز',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final token = box.read('access_token');
      
      if (token == null) {
        Get.snackbar(
          'خطأ',
          'الرجاء تسجيل الدخول',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // ✅ Format dates for API
      final startDateStr = _formatDateForAPI(selectedStartDate.value!);
      final endDateStr = _formatDateForAPI(selectedEndDate.value!);
      final duration = _calculateDuration();
      final totalPrice = duration * apartment.pricePerDay;

      // ✅ Create booking data
      final bookingData = {
        "apartment_id": apartment.id,
        "start_date": startDateStr,
        "end_date": endDateStr,
        "payment_method": paymentMethod.value,
      };

      print('');
      print('═══════════════════════════════════════════════════════════');
      print('📤 SUBMITTING BOOKING');
      print('   JSON: $bookingData');
      print('   Duration: $duration days');
      print('   Total: \$$totalPrice');
      print('═══════════════════════════════════════════════════════════');

      final response = await http.post(
        Uri.parse('${BaseUrl.pubBaseUrl}/api/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bookingData),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ BOOKING SUCCESSFUL');
        print('═══════════════════════════════════════════════════════════');

        Get.back(); // Close dialog

        Get.snackbar(
          '✅ نجح الحجز',
          'تم حجز ${apartment.title} من $startDateStr إلى $endDateStr',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 4),
        );
      } else {
        print('❌ BOOKING FAILED');
        print('═══════════════════════════════════════════════════════════');

        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'فشل الحجز';

        Get.snackbar(
          'فشل الحجز',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      print('❌ ERROR: $e');
      print('═══════════════════════════════════════════════════════════');

      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء الحجز: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // ═══════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════
  
  int _calculateDuration() {
    if (selectedStartDate.value == null || selectedEndDate.value == null) return 0;
    return selectedEndDate.value!.difference(selectedStartDate.value!).inDays;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateForAPI(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}