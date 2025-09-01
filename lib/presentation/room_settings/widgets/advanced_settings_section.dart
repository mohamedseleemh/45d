import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AdvancedSettingsSection extends StatelessWidget {
  final bool roomRecording;
  final bool profanityFilter;
  final int roomExpirationHours;
  final Function(bool) onRecordingChanged;
  final Function(bool) onProfanityFilterChanged;
  final Function(int) onExpirationChanged;

  const AdvancedSettingsSection({
    super.key,
    required this.roomRecording,
    required this.profanityFilter,
    required this.roomExpirationHours,
    required this.onRecordingChanged,
    required this.onProfanityFilterChanged,
    required this.onExpirationChanged,
  });

  void _showExpirationSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
              'مدة انتهاء الغرفة',
              style: AppTheme.lightTheme.textTheme.titleLarge,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 3.h),
            _buildExpirationOption(
                context: context,
                hours: 0,
                title: 'بدون انتهاء',
                subtitle: 'الغرفة ستبقى نشطة دائماً'),
            _buildExpirationOption(
                context: context,
                hours: 1,
                title: 'ساعة واحدة',
                subtitle: 'ستنتهي الغرفة بعد ساعة واحدة'),
            _buildExpirationOption(
                context: context,
                hours: 6,
                title: '6 ساعات',
                subtitle: 'ستنتهي الغرفة بعد 6 ساعات'),
            _buildExpirationOption(
                context: context,
                hours: 12,
                title: '12 ساعة',
                subtitle: 'ستنتهي الغرفة بعد 12 ساعة'),
            _buildExpirationOption(
                context: context,
                hours: 24,
                title: '24 ساعة',
                subtitle: 'ستنتهي الغرفة بعد يوم واحد'),
            _buildExpirationOption(
                context: context,
                hours: 168,
                title: 'أسبوع واحد',
                subtitle: 'ستنتهي الغرفة بعد أسبوع'),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildExpirationOption({
    required BuildContext context,
    required int hours,
    required String title,
    required String subtitle,
  }) {
    final isSelected = roomExpirationHours == hours;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onExpirationChanged(hours);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primaryContainer
              : AppTheme.lightTheme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : null,
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: AppTheme.lightTheme.textTheme.bodySmall,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
            if (isSelected)
              CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
          ],
        ),
      ),
    );
  }

  String _getExpirationTitle() {
    switch (roomExpirationHours) {
      case 0:
        return 'بدون انتهاء';
      case 1:
        return 'ساعة واحدة';
      case 6:
        return '6 ساعات';
      case 12:
        return '12 ساعة';
      case 24:
        return '24 ساعة';
      case 168:
        return 'أسبوع واحد';
      default:
        return '$roomExpirationHours ساعة';
    }
  }

  void _showRecordingInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تسجيل المحادثات',
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        content: Text(
          'عند تفعيل هذا الخيار، سيتم تسجيل جميع المحادثات الصوتية والمرئية في الغرفة. سيتم إشعار جميع المشاركين بأن المحادثة يتم تسجيلها.\n\nملاحظة: التسجيلات ستكون متاحة لمالك الغرفة فقط ويمكن حذفها في أي وقت.',
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'فهمت',
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الإعدادات المتقدمة',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: 3.h),

          // Room Recording
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'تسجيل المحادثات',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                        SizedBox(width: 2.w),
                        GestureDetector(
                          onTap: () => _showRecordingInfo(context),
                          child: CustomIconWidget(
                            iconName: 'info_outline',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 4.w,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'تسجيل جميع المحادثات الصوتية والمرئية',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
              Switch(
                value: roomRecording,
                onChanged: onRecordingChanged,
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Profanity Filter
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'فلتر الكلمات غير اللائقة',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                    Text(
                      'حذف الرسائل التي تحتوي على كلمات غير لائقة',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
              Switch(
                value: profanityFilter,
                onChanged: onProfanityFilterChanged,
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Room Expiration
          GestureDetector(
            onTap: () => _showExpirationSelector(context),
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'schedule',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 5.w,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مدة انتهاء الغرفة',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                        Text(
                          _getExpirationTitle(),
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 6.w,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
