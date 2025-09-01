import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

enum RoomType { voiceOnly, video, both }

class RoomTypeSelectorWidget extends StatelessWidget {
  final RoomType selectedType;
  final Function(RoomType) onTypeChanged;

  const RoomTypeSelectorWidget({
    Key? key,
    required this.selectedType,
    required this.onTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع الغرفة',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        SizedBox(height: 1.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline,
            ),
          ),
          child: Column(
            children: [
              _buildRoomTypeOption(
                type: RoomType.voiceOnly,
                title: 'صوت فقط',
                subtitle: 'محادثة صوتية بدون فيديو',
                icon: 'mic',
                isFirst: true,
              ),
              Divider(
                height: 1,
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
              _buildRoomTypeOption(
                type: RoomType.video,
                title: 'فيديو فقط',
                subtitle: 'مكالمة فيديو بدون صوت',
                icon: 'videocam',
              ),
              Divider(
                height: 1,
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
              _buildRoomTypeOption(
                type: RoomType.both,
                title: 'صوت وفيديو',
                subtitle: 'مكالمة كاملة بالصوت والفيديو',
                icon: 'video_call',
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomTypeOption({
    required RoomType type,
    required String title,
    required String subtitle,
    required String icon,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final isSelected = selectedType == type;

    return InkWell(
      onTap: () => onTypeChanged(type),
      borderRadius: BorderRadius.vertical(
        top: isFirst ? Radius.circular(12) : Radius.zero,
        bottom: isLast ? Radius.circular(12) : Radius.zero,
      ),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.vertical(
            top: isFirst ? Radius.circular(12) : Radius.zero,
            bottom: isLast ? Radius.circular(12) : Radius.zero,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.surface,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.lightTheme.primaryColor
                      : AppTheme.lightTheme.colorScheme.outline,
                  width: 2,
                ),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: icon,
                  size: 6.w,
                  color: isSelected
                      ? Colors.white
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: isSelected
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              CustomIconWidget(
                iconName: 'check_circle',
                size: 5.w,
                color: AppTheme.lightTheme.primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}
