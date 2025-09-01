import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TopOverlayWidget extends StatelessWidget {
  final String roomName;
  final int participantCount;
  final String connectionQuality;
  final VoidCallback onBackPressed;

  const TopOverlayWidget({
    Key? key,
    required this.roomName,
    required this.participantCount,
    required this.connectionQuality,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.black.withValues(alpha: 0.3),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Back button
            GestureDetector(
              onTap: onBackPressed,
              child: Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: Colors.white,
                    size: 5.w,
                  ),
                ),
              ),
            ),

            SizedBox(width: 3.w),

            // Room info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Room name
                  Text(
                    roomName,
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 0.5.h),

                  // Participant count
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'people',
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 4.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '$participantCount مشارك',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Connection quality indicator
            _buildConnectionQualityIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionQualityIndicator() {
    Color qualityColor;
    String qualityText;
    IconData qualityIcon;

    switch (connectionQuality.toLowerCase()) {
      case 'excellent':
        qualityColor = AppTheme.successLight;
        qualityText = 'ممتاز';
        qualityIcon = Icons.signal_cellular_4_bar;
        break;
      case 'good':
        qualityColor = AppTheme.lightTheme.primaryColor;
        qualityText = 'جيد';
        qualityIcon = Icons.help_outline;
        break;
      case 'fair':
        qualityColor = AppTheme.warningLight;
        qualityText = 'متوسط';
        qualityIcon = Icons.help_outline;
        break;
      case 'poor':
        qualityColor = AppTheme.errorLight;
        qualityText = 'ضعيف';
        qualityIcon = Icons.help_outline;
        break;
      default:
        qualityColor = AppTheme.lightTheme.colorScheme.outline;
        qualityText = 'غير معروف';
        qualityIcon = Icons.signal_cellular_0_bar;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            qualityIcon,
            color: qualityColor,
            size: 4.w,
          ),
          SizedBox(width: 1.w),
          Text(
            qualityText,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
