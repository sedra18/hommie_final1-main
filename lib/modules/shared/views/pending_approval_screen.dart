import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hommie/data/services/approval_status_service.dart';
import 'package:hommie/app/utils/app_colors.dart';

// ═══════════════════════════════════════════════════════════
// PENDING APPROVAL SCREEN
// Shows when user tries to access features without approval
// ═══════════════════════════════════════════════════════════

class PendingApprovalScreen extends StatelessWidget {
  final String? featureName;
  
  const PendingApprovalScreen({
    super.key,
    this.featureName,
  });

  @override
  Widget build(BuildContext context) {
    final approvalService = Get.find<ApprovalStatusService>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approval Required'),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Warning Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.schedule,
                  size: 64,
                  color: Colors.orange.shade700,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              const Text(
                'Account Pending Approval',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Description
              Obx(() {
                return Text(
                  _getDescriptionText(approvalService.userRole),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                );
              }),
              
              const SizedBox(height: 32),
              
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'What happens next?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoStep('1', 'Our team reviews your account'),
                    const SizedBox(height: 8),
                    _buildInfoStep('2', 'Verification usually takes 24-48 hours'),
                    const SizedBox(height: 8),
                    _buildInfoStep('3', 'You\'ll be notified once approved'),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Refresh Button
              Obx(() {
                final isChecking = approvalService.isCheckingApproval;
                
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isChecking
                        ? null
                        : () => _handleRefresh(approvalService),
                    icon: isChecking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(
                      isChecking ? 'Checking...' : 'Check Approval Status',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // GET DESCRIPTION TEXT
  // Returns role-specific description
  // ═══════════════════════════════════════════════════════════
  
  String _getDescriptionText(String userRole) {
    if (userRole == 'owner') {
      return 'Your owner account is currently under review. You cannot add apartments or access certain features until approved.';
    } else if (userRole == 'renter') {
      return 'Your renter account is currently under review. You cannot book apartments or access certain features until approved.';
    } else {
      return 'Your account is currently under review. You cannot access certain features until approved.';
    }
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD INFO STEP
  // ═══════════════════════════════════════════════════════════
  
  Widget _buildInfoStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HANDLE REFRESH
  // ✅ FIX: Use .value to access RxBool
  // ═══════════════════════════════════════════════════════════
  
  Future<void> _handleRefresh(ApprovalStatusService approvalService) async {
    await approvalService.refreshApprovalStatus();
    
    // ✅ CORRECT: Access .value property of RxBool
    if (approvalService.isApproved.value) {
      // User is now approved, go back and refresh the previous screen
      Get.back();
      
      Get.snackbar(
        'Approved!',
        'Your account has been approved. You can now access all features.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF22C55E),
        colorText: const Color(0xFFFFFFFF),
        icon: const Icon(
          Icons.check_circle,
          color: Color(0xFFFFFFFF),
        ),
      );
    }
  }
}