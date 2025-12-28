import 'package:flutter/material.dart';
import 'package:hommie/app/utils/app_colors.dart';



class PendingApprovalWidget extends StatelessWidget {
  final VoidCallback onRefresh;
  
  const PendingApprovalWidget({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hourglass Icon
            Icon(
              Icons.hourglass_empty,
              size: 80,
              color: AppColors.warning,
            ),
            
            const SizedBox(height: 24),
            
            // Main Message
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.warning,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.hourglass_empty,
                        color: AppColors.warning,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Flexible(
                        child: Text(
                          'حسابك في انتظار الموافقة',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  const Text(
                    'لا يمكنك إضافة شقق حتى تتم الموافقة على حسابك من قبل الإدارة',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimaryLight,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Refresh Button
                  OutlinedButton.icon(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('تحقق من الحالة'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: BorderSide(color: AppColors.warning, width: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Disabled Add Button (visual indicator)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.textSecondaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, color: AppColors.textPrimaryLight),
                  SizedBox(width: 8),
                  Text(
                    'إضافة شقة (معطل)',
                    style: TextStyle(
                      color: AppColors.textPrimaryLight,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Info Text
            const Text(
              'سيتم تفعيل زر الإضافة بعد موافقة الإدارة على حسابك',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimaryLight,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}