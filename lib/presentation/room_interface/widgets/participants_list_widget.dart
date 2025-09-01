import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ParticipantsListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> participants;
  final bool isRoomOwner;
  final Function(String participantId) onMuteParticipant;
  final Function(String participantId) onRemoveParticipant;
  final Function(String participantId) onPromoteParticipant;

  const ParticipantsListWidget({
    Key? key,
    required this.participants,
    required this.isRoomOwner,
    required this.onMuteParticipant,
    required this.onRemoveParticipant,
    required this.onPromoteParticipant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4.w),
          topRight: Radius.circular(4.w),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(0.25.h),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Text(
                  'المشاركون',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: Text(
                    '${participants.length + 1}',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            height: 1,
          ),

          // Participants list
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              children: [
                // Local user (always first)
                _buildParticipantTile(
                  id: 'local',
                  name: 'أنت',
                  avatar: null,
                  isMuted: false,
                  isOwner: isRoomOwner,
                  isSpeaking: true,
                  isLocal: true,
                ),

                // Other participants
                ...participants
                    .map((participant) => _buildParticipantTile(
                          id: participant['id'] as String,
                          name: participant['name'] as String,
                          avatar: participant['avatar'] as String?,
                          isMuted: participant['isMuted'] as bool? ?? false,
                          isOwner: participant['isOwner'] as bool? ?? false,
                          isSpeaking:
                              participant['isSpeaking'] as bool? ?? false,
                          isLocal: false,
                        ))
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantTile({
    required String id,
    required String name,
    String? avatar,
    required bool isMuted,
    required bool isOwner,
    required bool isSpeaking,
    required bool isLocal,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isSpeaking
            ? AppTheme.lightTheme.colorScheme.primaryContainer
                .withValues(alpha: 0.3)
            : AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        border: isSpeaking
            ? Border.all(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.5),
                width: 1,
              )
            : null,
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isSpeaking
                      ? Border.all(
                          color: AppTheme.lightTheme.primaryColor,
                          width: 2,
                        )
                      : null,
                ),
                child: ClipOval(
                  child: avatar != null
                      ? CustomImageWidget(
                          imageUrl: avatar,
                          width: 12.w,
                          height: 12.w,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: AppTheme.lightTheme.primaryColor,
                          child: Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : "U",
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                color: Colors.white,
                                fontSize: 4.w,
                              ),
                            ),
                          ),
                        ),
                ),
              ),

              // Mute indicator
              if (isMuted)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 4.w,
                    height: 4.w,
                    decoration: BoxDecoration(
                      color: AppTheme.errorLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'mic_off',
                        color: Colors.white,
                        size: 2.w,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(width: 3.w),

          // Name and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isOwner)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.primaryColor,
                          borderRadius: BorderRadius.circular(1.w),
                        ),
                        child: Text(
                          'مالك',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  isSpeaking ? 'يتحدث الآن' : (isMuted ? 'مكتوم' : 'متصل'),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: isSpeaking
                        ? AppTheme.lightTheme.primaryColor
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),

          // Owner controls
          if (this.isRoomOwner && !isLocal && !isOwner)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mute button
                GestureDetector(
                  onTap: () => onMuteParticipant(id),
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: isMuted
                          ? AppTheme.lightTheme.colorScheme.primaryContainer
                          : AppTheme.errorLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: CustomIconWidget(
                      iconName: isMuted ? 'mic' : 'mic_off',
                      color: isMuted
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.errorLight,
                      size: 4.w,
                    ),
                  ),
                ),

                SizedBox(width: 2.w),

                // More options
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'promote':
                        onPromoteParticipant(id);
                        break;
                      case 'remove':
                        onRemoveParticipant(id);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'promote',
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'admin_panel_settings',
                            color: AppTheme.lightTheme.primaryColor,
                            size: 4.w,
                          ),
                          SizedBox(width: 2.w),
                          Text('ترقية لمالك'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'person_remove',
                            color: AppTheme.errorLight,
                            size: 4.w,
                          ),
                          SizedBox(width: 2.w),
                          Text('إزالة من الغرفة'),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: CustomIconWidget(
                      iconName: 'more_vert',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 4.w,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
