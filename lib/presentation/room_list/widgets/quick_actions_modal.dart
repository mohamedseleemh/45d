import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionsModal extends StatelessWidget {
  final Map<String, dynamic> roomData;
  final VoidCallback onJoin;
  final VoidCallback onBookmark;
  final VoidCallback onReport;

  const QuickActionsModal({
    Key? key,
    required this.roomData,
    required this.onJoin,
    required this.onBookmark,
    required this.onReport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roomName = roomData['name'] as String? ?? '';
    final isBookmarked = roomData['isBookmarked'] as bool? ?? false;

    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 3.h),
          // Room info
          Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'chat_bubble',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 24,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roomName,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'إجراءات سريعة',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          // Action buttons
          _buildActionButton(
            icon: 'login',
            title: 'انضم للغرفة',
            subtitle: 'ابدأ المحادثة الآن',
            color: AppTheme.lightTheme.primaryColor,
            onTap: () {
              Navigator.pop(context);
              onJoin();
            },
          ),
          SizedBox(height: 2.h),
          _buildActionButton(
            icon: isBookmarked ? 'bookmark' : 'bookmark_border',
            title: isBookmarked ? 'إزالة من المفضلة' : 'إضافة للمفضلة',
            subtitle:
                isBookmarked ? 'إزالة من قائمة المفضلة' : 'حفظ للوصول السريع',
            color: AppTheme.lightTheme.colorScheme.secondary,
            onTap: () {
              Navigator.pop(context);
              onBookmark();
            },
          ),
          SizedBox(height: 2.h),
          _buildActionButton(
            icon: 'report',
            title: 'إبلاغ عن الغرفة',
            subtitle: 'الإبلاغ عن محتوى غير مناسب',
            color: AppTheme.lightTheme.colorScheme.tertiary,
            onTap: () {
              Navigator.pop(context);
              onReport();
            },
          ),
          SizedBox(height: 2.h),
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'إلغاء',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
