import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onCreateRoom;

  const EmptyStateWidget({
    Key? key,
    required this.onCreateRoom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              width: 40.w,
              height: 30.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'chat_bubble_outline',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 60,
                  ),
                  SizedBox(height: 2.h),
                  CustomIconWidget(
                    iconName: 'people_outline',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 40,
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),
            // Title
            Text(
              'لا توجد غرف متاحة',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            // Description
            Text(
              'ابدأ محادثة جديدة عبر إنشاء غرفة صوتية أو مرئية واستمتع بالتواصل مع الأصدقاء',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            // Create room button
            ElevatedButton(
              onPressed: onCreateRoom,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'add',
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'أنشئ غرفتك الأولى',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
