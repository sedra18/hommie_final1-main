import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:hommie/app/utils/app_colors.dart';
import 'package:hommie/modules/shared/controllers/filter_controller.dart';

// ═══════════════════════════════════════════════════════════
// FILTER SCREEN
// Comprehensive filter screen for apartment search
// Works for both Owner and Renter programs
// ═══════════════════════════════════════════════════════════

class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FilterController());

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Filters',
          style: TextStyle(color: AppColors.backgroundLight),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.backgroundLight,
        leading: IconButton(
          color: AppColors.backgroundLight,
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Active filters badge
          Obx(() {
            final count = controller.getActiveFiltersCount();
            if (count == 0) return const SizedBox.shrink();
            
            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBBF24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count active',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Section
                  _buildSectionHeader('Location', Icons.location_on),
                  const SizedBox(height: 12),
                  
                  _buildTextField(
                    controller: controller.cityController,
                    label: 'City',
                    hint: 'e.g., Tunis',
                    icon: Icons.location_city,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildTextField(
                    controller: controller.governorateController,
                    label: 'Governorate',
                    hint: 'e.g., Tunis Governorate',
                    icon: Icons.map,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildTextField(
                    controller: controller.addressController,
                    label: 'Address',
                    hint: 'e.g., Avenue Habib Bourguiba',
                    icon: Icons.home,
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  
                  // Price Section
                  _buildSectionHeader('Price Range', Icons.attach_money),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberTextField(
                          controller: controller.minPriceController,
                          label: 'Min Price',
                          hint: 'Min',
                          prefix: 'TND',
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '—',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildNumberTextField(
                          controller: controller.maxPriceController,
                          label: 'Max Price',
                          hint: 'Max',
                          prefix: 'TND',
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  
                  // Rooms Section
                  _buildSectionHeader('Number of Rooms', Icons.bed),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberTextField(
                          controller: controller.minRoomsController,
                          label: 'Min Rooms',
                          hint: 'Min',
                          isInteger: true,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '—',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildNumberTextField(
                          controller: controller.maxRoomsController,
                          label: 'Max Rooms',
                          hint: 'Max',
                          isInteger: true,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  
                  // Size Section
                  _buildSectionHeader('Size (m²)', Icons.aspect_ratio),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberTextField(
                          controller: controller.minSizeController,
                          label: 'Min Size',
                          hint: 'Min',
                          suffix: 'm²',
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '—',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildNumberTextField(
                          controller: controller.maxSizeController,
                          label: 'Max Size',
                          hint: 'Max',
                          suffix: 'm²',
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Bottom Action Buttons
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.clearFilters,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Clear All',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: controller.applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
  // BUILD SECTION HEADER
  // ═══════════════════════════════════════════════════════════
  
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD TEXT FIELD
  // ═══════════════════════════════════════════════════════════
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondaryLight.withOpacity(0.5),
            ),
            prefixIcon: icon != null ? Icon(icon, color: AppColors.primary, size: 20) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD NUMBER TEXT FIELD
  // ═══════════════════════════════════════════════════════════
  
  Widget _buildNumberTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? prefix,
    String? suffix,
    bool isInteger = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: !isInteger),
          inputFormatters: [
            if (isInteger)
              FilteringTextInputFormatter.digitsOnly
            else
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondaryLight.withOpacity(0.5),
            ),
            prefixText: prefix != null ? '$prefix ' : null,
            suffixText: suffix != null ? ' $suffix' : null,
            prefixStyle: const TextStyle(
              color: AppColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
            suffixStyle: const TextStyle(
              color: AppColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}