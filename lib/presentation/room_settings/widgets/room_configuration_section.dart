import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RoomConfigurationSection extends StatelessWidget {
  final String privacyLevel;
  final int participantLimit;
  final bool autoMuteNewMembers;
  final bool allowScreenSharing;
  final Function(String) onPrivacyChanged;
  final Function(int) onParticipantLimitChanged;
  final Function(bool) onAutoMuteChanged;
  final Function(bool) onScreenSharingChanged;

  const RoomConfigurationSection({
    super.key,
    required this.privacyLevel,
    required this.participantLimit,
    required this.autoMuteNewMembers,
    required this.allowScreenSharing,
    required this.onPrivacyChanged,
    required this.onParticipantLimitChanged,
    required this.onAutoMuteChanged,
    required this.onScreenSharingChanged,
  });

  void _showPrivacySelector(BuildContext context) {
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
              'مستوى الخصوصية',
              style: AppTheme.lightTheme.textTheme.titleLarge,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 3.h),
            _buildPrivacyOption(
              context: context,
              value: 'public',
              title: 'عامة',
              subtitle: 'يمكن لأي شخص العثور على الغرفة والانضمام إليها',
              icon: 'public',
            ),
            _buildPrivacyOption(
              context: context,
              value: 'private',
              title: 'خاصة',
              subtitle: 'يمكن العثور على الغرفة ولكن تحتاج موافقة للانضمام',
              icon: 'lock',
            ),
            _buildPrivacyOption(
              context: context,
              value: 'invite_only',
              title: 'بدعوة فقط',
              subtitle: 'لا يمكن العثور على الغرفة، الانضمام بدعوة فقط',
              icon: 'mail',
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyOption({
    required BuildContext context,
    required String value,
    required String title,
    required String subtitle,
    required String icon,
  }) {
    final isSelected = privacyLevel == value;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onPrivacyChanged(value);
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
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: icon,
                  color: isSelected
                      ? Colors.white
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 6.w,
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

  String _getPrivacyTitle() {
    switch (privacyLevel) {
      case 'public':
        return 'عامة';
      case 'private':
        return 'خاصة';
      case 'invite_only':
        return 'بدعوة فقط';
      default:
        return 'عامة';
    }
  }

  String _getPrivacyIcon() {
    switch (privacyLevel) {
      case 'public':
        return 'public';
      case 'private':
        return 'lock';
      case 'invite_only':
        return 'mail';
      default:
        return 'public';
    }
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
            'إعدادات الغرفة',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: 3.h),

          // Privacy Level
          GestureDetector(
            onTap: () => _showPrivacySelector(context),
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
                        iconName: _getPrivacyIcon(),
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
                          'مستوى الخصوصية',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                        Text(
                          _getPrivacyTitle(),
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
          SizedBox(height: 3.h),

          // Participant Limit
          Text(
            'الحد الأقصى للمشاركين',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: participantLimit.toDouble(),
                  min: 2,
                  max: 50,
                  divisions: 48,
                  label: '$participantLimit مشارك',
                  onChanged: (value) =>
                      onParticipantLimitChanged(value.round()),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$participantLimit',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Auto Mute New Members
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'كتم الأعضاء الجدد تلقائياً',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                    Text(
                      'الأعضاء الجدد سيكونون مكتومين عند الانضمام',
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
                value: autoMuteNewMembers,
                onChanged: onAutoMuteChanged,
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Allow Screen Sharing
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'السماح بمشاركة الشاشة',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                    Text(
                      'المشاركون يمكنهم مشاركة شاشاتهم',
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
                value: allowScreenSharing,
                onChanged: onScreenSharingChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
