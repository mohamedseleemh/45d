import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VoiceParticipantsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> participants;
  final bool isLocalMuted;

  const VoiceParticipantsWidget({
    Key? key,
    required this.participants,
    required this.isLocalMuted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: _buildParticipantsCircle(),
      ),
    );
  }

  Widget _buildParticipantsCircle() {
    final allParticipants = [
      {
        'id': 'local',
        'name': 'أنت',
        'avatar': null,
        'isSpeaking': !isLocalMuted,
        'isMuted': isLocalMuted,
      },
      ...participants,
    ];

    return Container(
      width: 80.w,
      height: 80.w,
      child: Stack(
        children: [
          // Background circle
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.lightTheme.colorScheme.surface
                  .withValues(alpha: 0.1),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),

          // Participants positioned in circle
          ...allParticipants.asMap().entries.map((entry) {
            final index = entry.key;
            final participant = entry.value;
            return _buildParticipantPosition(
                participant, index, allParticipants.length);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildParticipantPosition(
      Map<String, dynamic> participant, int index, int total) {
    final angle = (2 * 3.14159 * index) / total;
    final radius = 30.w;
    final centerX = 40.w;
    final centerY = 40.w;

    final x = centerX + radius * cos(angle) - 8.w;
    final y = centerY + radius * sin(angle) - 8.w;

    return Positioned(
      left: x,
      top: y,
      child: _buildParticipantAvatar(participant),
    );
  }

  Widget _buildParticipantAvatar(Map<String, dynamic> participant) {
    final isSpeaking = participant['isSpeaking'] as bool? ?? false;
    final isMuted = participant['isMuted'] as bool? ?? false;
    final name = participant['name'] as String;
    final avatar = participant['avatar'] as String?;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16.w,
          height: 16.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSpeaking
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.outline,
              width: isSpeaking ? 3 : 2,
            ),
            boxShadow: isSpeaking
                ? [
                    BoxShadow(
                      color: AppTheme.lightTheme.primaryColor
                          .withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Avatar
              ClipOval(
                child: avatar != null
                    ? CustomImageWidget(
                        imageUrl: avatar,
                        width: 16.w,
                        height: 16.w,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 16.w,
                        height: 16.w,
                        color: AppTheme.lightTheme.primaryColor,
                        child: Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : "U",
                            style: AppTheme.lightTheme.textTheme.titleLarge
                                ?.copyWith(
                              color: Colors.white,
                              fontSize: 5.w,
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
                    width: 5.w,
                    height: 5.w,
                    decoration: BoxDecoration(
                      color: AppTheme.errorLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'mic_off',
                        color: Colors.white,
                        size: 2.5.w,
                      ),
                    ),
                  ),
                ),

              // Speaking indicator
              if (isSpeaking && !isMuted)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.lightTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.lightTheme.primaryColor
                            .withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        SizedBox(height: 1.h),

        // Name
        Container(
          constraints: BoxConstraints(maxWidth: 20.w),
          child: Text(
            name,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Audio waveform for speaking participants
        if (isSpeaking && !isMuted)
          Container(
            margin: EdgeInsets.only(top: 0.5.h),
            child: _buildAudioWaveform(),
          ),
      ],
    );
  }

  Widget _buildAudioWaveform() {
    return Container(
      width: 12.w,
      height: 2.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 100)),
            width: 1.5.w,
            height: (1 + (index % 3)) * 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor,
              borderRadius: BorderRadius.circular(0.5.w),
            ),
          );
        }),
      ),
    );
  }

  double cos(double angle) {
    return math.cos(angle);
  }

  double sin(double angle) {
    return math.sin(angle);
  }
}
