import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RoomCardWidget extends StatelessWidget {
  final Map<String, dynamic> roomData;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const RoomCardWidget({
    Key? key,
    required this.roomData,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isActive = roomData['isActive'] as bool? ?? false;
    final roomType = roomData['type'] as String? ?? 'voice';
    final participantCount = roomData['participantCount'] as int? ?? 0;
    final maxParticipants = roomData['maxParticipants'] as int? ?? 10;
    final roomName = roomData['name'] as String? ?? '';
    final ownerAvatar = roomData['ownerAvatar'] as String? ?? '';
    final ownerName = roomData['ownerName'] as String? ?? '';

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(color: AppTheme.lightTheme.primaryColor, width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Room type indicator
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: roomType == 'video'
                        ? AppTheme.lightTheme.colorScheme.tertiary
                            .withValues(alpha: 0.1)
                        : AppTheme.lightTheme.colorScheme.secondary
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: roomType == 'video' ? 'videocam' : 'mic',
                        color: roomType == 'video'
                            ? AppTheme.lightTheme.colorScheme.tertiary
                            : AppTheme.lightTheme.colorScheme.secondary,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        roomType == 'video' ? 'فيديو' : 'صوت',
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: roomType == 'video'
                              ? AppTheme.lightTheme.colorScheme.tertiary
                              : AppTheme.lightTheme.colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Active indicator with animation
                if (isActive) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.successLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'نشط',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.successLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 2.h),
            // Room name
            Text(
              roomName,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 1.h),
            // Owner and participant info
            Row(
              children: [
                // Owner avatar
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: ClipOval(
                    child: CustomImageWidget(
                      imageUrl: ownerAvatar,
                      width: 8.w,
                      height: 8.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ownerName,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'مالك الغرفة',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Participant count
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'people',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '$participantCount/$maxParticipants',
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Live audio waveform for active rooms
            if (isActive && roomType == 'voice') ...[
              SizedBox(height: 2.h),
              _buildAudioWaveform(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAudioWaveform() {
    return Container(
      height: 3.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(8, (index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 100)),
            margin: EdgeInsets.symmetric(horizontal: 0.5.w),
            width: 1.w,
            height: (1 + (index % 3)) * 1.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
