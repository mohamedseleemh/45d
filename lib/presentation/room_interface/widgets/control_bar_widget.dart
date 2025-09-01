import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ControlBarWidget extends StatelessWidget {
  final bool isMuted;
  final bool isVideoEnabled;
  final bool isSpeakerOn;
  final bool isRoomOwner;
  final VoidCallback onMuteToggle;
  final VoidCallback onVideoToggle;
  final VoidCallback onSpeakerToggle;
  final VoidCallback onLeaveRoom;
  final VoidCallback onShowParticipants;
  final VoidCallback onShowSettings;
  final VoidCallback onEndRoom;

  const ControlBarWidget({
    Key? key,
    required this.isMuted,
    required this.isVideoEnabled,
    required this.isSpeakerOn,
    required this.isRoomOwner,
    required this.onMuteToggle,
    required this.onVideoToggle,
    required this.onSpeakerToggle,
    required this.onLeaveRoom,
    required this.onShowParticipants,
    required this.onShowSettings,
    required this.onEndRoom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4.w),
          topRight: Radius.circular(4.w),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main controls row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mute/Unmute button
                _buildControlButton(
                  icon: isMuted ? 'mic_off' : 'mic',
                  label: isMuted ? 'إلغاء الكتم' : 'كتم',
                  isActive: !isMuted,
                  backgroundColor: isMuted
                      ? AppTheme.errorLight
                      : AppTheme.lightTheme.primaryColor,
                  onTap: onMuteToggle,
                ),

                // Video toggle button
                _buildControlButton(
                  icon: isVideoEnabled ? 'videocam' : 'videocam_off',
                  label: isVideoEnabled ? 'إيقاف الكاميرا' : 'تشغيل الكاميرا',
                  isActive: isVideoEnabled,
                  backgroundColor: isVideoEnabled
                      ? AppTheme.lightTheme.primaryColor
                      : AppTheme.lightTheme.colorScheme.outline,
                  onTap: onVideoToggle,
                ),

                // Speaker toggle button
                _buildControlButton(
                  icon: isSpeakerOn ? 'volume_up' : 'hearing',
                  label: isSpeakerOn ? 'مكبر الصوت' : 'سماعة الأذن',
                  isActive: isSpeakerOn,
                  backgroundColor: isSpeakerOn
                      ? AppTheme.lightTheme.primaryColor
                      : AppTheme.lightTheme.colorScheme.outline,
                  onTap: onSpeakerToggle,
                ),

                // Leave room button
                _buildControlButton(
                  icon: 'call_end',
                  label: 'مغادرة',
                  isActive: false,
                  backgroundColor: AppTheme.errorLight,
                  onTap: onLeaveRoom,
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Secondary controls row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Participants button
                _buildSecondaryButton(
                  icon: 'people',
                  label: 'المشاركون',
                  onTap: onShowParticipants,
                ),

                // Settings button (only for room owner)
                if (isRoomOwner)
                  _buildSecondaryButton(
                    icon: 'settings',
                    label: 'الإعدادات',
                    onTap: onShowSettings,
                  ),

                // End room button (only for room owner)
                if (isRoomOwner)
                  _buildSecondaryButton(
                    icon: 'meeting_room',
                    label: 'إنهاء الغرفة',
                    onTap: onEndRoom,
                    isDestructive: true,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required String icon,
    required String label,
    required bool isActive,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: icon,
                color: Colors.white,
                size: 6.w,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppTheme.errorLight.withValues(alpha: 0.1)
              : AppTheme.lightTheme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(2.w),
          border: Border.all(
            color: isDestructive
                ? AppTheme.errorLight
                : AppTheme.lightTheme.primaryColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isDestructive
                  ? AppTheme.errorLight
                  : AppTheme.lightTheme.primaryColor,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: isDestructive
                    ? AppTheme.errorLight
                    : AppTheme.lightTheme.primaryColor,
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
