import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AdvancedSettingsWidget extends StatelessWidget {
  final bool autoMuteNewParticipants;
  final bool allowScreenSharing;
  final int roomDurationMinutes;
  final Function(bool) onAutoMuteChanged;
  final Function(bool) onScreenSharingChanged;
  final Function(int) onDurationChanged;

  const AdvancedSettingsWidget({
    Key? key,
    required this.autoMuteNewParticipants,
    required this.allowScreenSharing,
    required this.roomDurationMinutes,
    required this.onAutoMuteChanged,
    required this.onScreenSharingChanged,
    required this.onDurationChanged,
  }) : super(key: key);

  String _formatArabicDuration(int minutes) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    if (minutes == 0) return 'بدون حد زمني';

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    String result = '';

    if (hours > 0) {
      final hoursStr = hours.toString().split('').map((digit) {
        return arabicDigits[int.parse(digit)];
      }).join('');
      result += '$hoursStr ساعة';

      if (remainingMinutes > 0) {
        result += ' و ';
      }
    }

    if (remainingMinutes > 0) {
      final minutesStr = remainingMinutes.toString().split('').map((digit) {
        return arabicDigits[int.parse(digit)];
      }).join('');
      result += '$minutesStr دقيقة';
    }

    return result;
  }

  void _showDurationPicker(BuildContext context) {
    final durations = [0, 30, 60, 120, 180, 240, 360, 480];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'مدة الغرفة',
              style: AppTheme.lightTheme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ...durations.map((duration) => ListTile(
                  title: Text(
                    _formatArabicDuration(duration),
                    style: AppTheme.lightTheme.textTheme.bodyLarge,
                    textAlign: TextAlign.right,
                  ),
                  trailing: roomDurationMinutes == duration
                      ? CustomIconWidget(
                          iconName: 'check_circle',
                          color: AppTheme.lightTheme.primaryColor,
                          size: 5.w,
                        )
                      : null,
                  onTap: () {
                    onDurationChanged(duration);
                    Navigator.pop(context);
                  },
                )),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإعدادات المتقدمة',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        SizedBox(height: 2.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline,
            ),
            color: AppTheme.lightTheme.colorScheme.surface,
          ),
          child: Column(
            children: [
              _buildSettingTile(
                title: 'كتم المشاركين الجدد تلقائياً',
                subtitle: 'سيتم كتم الميكروفون للمشاركين الجدد',
                icon: 'mic_off',
                value: autoMuteNewParticipants,
                onChanged: onAutoMuteChanged,
                isFirst: true,
              ),
              Divider(
                height: 1,
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
              _buildSettingTile(
                title: 'السماح بمشاركة الشاشة',
                subtitle: 'يمكن للمشاركين مشاركة شاشاتهم',
                icon: 'screen_share',
                value: allowScreenSharing,
                onChanged: onScreenSharingChanged,
              ),
              Divider(
                height: 1,
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
              InkWell(
                onTap: () => _showDurationPicker(context),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(12)),
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  child: Row(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.lightTheme.colorScheme.surface,
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: 'schedule',
                            size: 6.w,
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مدة الغرفة',
                              style: AppTheme.lightTheme.textTheme.titleMedium,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              _formatArabicDuration(roomDurationMinutes),
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CustomIconWidget(
                        iconName: 'keyboard_arrow_left',
                        size: 5.w,
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required String icon,
    required bool value,
    required Function(bool) onChanged,
    bool isFirst = false,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        borderRadius: isFirst
            ? BorderRadius.vertical(top: Radius.circular(12))
            : BorderRadius.zero,
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.surface,
              border: Border.all(
                color: value
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.outline,
                width: 2,
              ),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: icon,
                size: 6.w,
                color: value
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
                  style: AppTheme.lightTheme.textTheme.titleMedium,
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.lightTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}
