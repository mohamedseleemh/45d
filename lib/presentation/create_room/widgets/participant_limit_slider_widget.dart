import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ParticipantLimitSliderWidget extends StatelessWidget {
  final int participantLimit;
  final Function(int) onLimitChanged;

  const ParticipantLimitSliderWidget({
    Key? key,
    required this.participantLimit,
    required this.onLimitChanged,
  }) : super(key: key);

  String _formatArabicNumber(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((digit) {
      return arabicDigits[int.parse(digit)];
    }).join('');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'عدد المشاركين',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatArabicNumber(participantLimit),
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline,
            ),
            color: AppTheme.lightTheme.colorScheme.surface,
          ),
          child: Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppTheme.lightTheme.primaryColor,
                  inactiveTrackColor:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
                  thumbColor: AppTheme.lightTheme.primaryColor,
                  overlayColor:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
                  trackHeight: 4.0,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 20.0),
                  valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                  valueIndicatorColor: AppTheme.lightTheme.primaryColor,
                  valueIndicatorTextStyle:
                      AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: Slider(
                  value: participantLimit.toDouble(),
                  min: 2,
                  max: 50,
                  divisions: 48,
                  label: _formatArabicNumber(participantLimit),
                  onChanged: (value) => onLimitChanged(value.round()),
                ),
              ),
              SizedBox(height: 1.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatArabicNumber(2),
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _formatArabicNumber(50),
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Text(
                participantLimit <= 10
                    ? 'مجموعة صغيرة - مناسبة للمحادثات الشخصية'
                    : participantLimit <= 25
                        ? 'مجموعة متوسطة - مناسبة للاجتماعات'
                        : 'مجموعة كبيرة - مناسبة للفعاليات',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
