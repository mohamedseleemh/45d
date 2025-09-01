import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VideoGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> participants;
  final bool isLocalVideoEnabled;
  final String? localVideoPath;

  const VideoGridWidget({
    Key? key,
    required this.participants,
    required this.isLocalVideoEnabled,
    this.localVideoPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: _buildVideoGrid(),
    );
  }

  Widget _buildVideoGrid() {
    final totalParticipants =
        participants.length + (isLocalVideoEnabled ? 1 : 0);

    if (totalParticipants == 1) {
      return _buildSingleVideo();
    } else if (totalParticipants == 2) {
      return _buildTwoVideoGrid();
    } else if (totalParticipants <= 4) {
      return _buildFourVideoGrid();
    } else {
      return _buildMultiVideoGrid();
    }
  }

  Widget _buildSingleVideo() {
    if (isLocalVideoEnabled) {
      return _buildVideoTile(
        isLocal: true,
        name: "أنت",
        avatar: null,
        isVideoEnabled: true,
      );
    } else if (participants.isNotEmpty) {
      final participant = participants.first;
      return _buildVideoTile(
        isLocal: false,
        name: participant['name'] as String,
        avatar: participant['avatar'] as String?,
        isVideoEnabled: participant['isVideoEnabled'] as bool? ?? false,
      );
    }
    return Container();
  }

  Widget _buildTwoVideoGrid() {
    return Column(
      children: [
        Expanded(
          child: _buildVideoTile(
            isLocal: false,
            name: participants.isNotEmpty
                ? participants.first['name'] as String
                : "",
            avatar: participants.isNotEmpty
                ? participants.first['avatar'] as String?
                : null,
            isVideoEnabled: participants.isNotEmpty
                ? participants.first['isVideoEnabled'] as bool? ?? false
                : false,
          ),
        ),
        if (isLocalVideoEnabled)
          Expanded(
            child: _buildVideoTile(
              isLocal: true,
              name: "أنت",
              avatar: null,
              isVideoEnabled: true,
            ),
          ),
      ],
    );
  }

  Widget _buildFourVideoGrid() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: participants.isNotEmpty
                    ? _buildVideoTile(
                        isLocal: false,
                        name: participants[0]['name'] as String,
                        avatar: participants[0]['avatar'] as String?,
                        isVideoEnabled:
                            participants[0]['isVideoEnabled'] as bool? ?? false,
                      )
                    : Container(),
              ),
              Expanded(
                child: participants.length > 1
                    ? _buildVideoTile(
                        isLocal: false,
                        name: participants[1]['name'] as String,
                        avatar: participants[1]['avatar'] as String?,
                        isVideoEnabled:
                            participants[1]['isVideoEnabled'] as bool? ?? false,
                      )
                    : Container(),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: participants.length > 2
                    ? _buildVideoTile(
                        isLocal: false,
                        name: participants[2]['name'] as String,
                        avatar: participants[2]['avatar'] as String?,
                        isVideoEnabled:
                            participants[2]['isVideoEnabled'] as bool? ?? false,
                      )
                    : Container(),
              ),
              Expanded(
                child: isLocalVideoEnabled
                    ? _buildVideoTile(
                        isLocal: true,
                        name: "أنت",
                        avatar: null,
                        isVideoEnabled: true,
                      )
                    : Container(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMultiVideoGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(1.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1.w,
        mainAxisSpacing: 1.w,
        childAspectRatio: 0.75,
      ),
      itemCount: participants.length + (isLocalVideoEnabled ? 1 : 0),
      itemBuilder: (context, index) {
        if (isLocalVideoEnabled && index == 0) {
          return _buildVideoTile(
            isLocal: true,
            name: "أنت",
            avatar: null,
            isVideoEnabled: true,
          );
        }

        final participantIndex = isLocalVideoEnabled ? index - 1 : index;
        if (participantIndex < participants.length) {
          final participant = participants[participantIndex];
          return _buildVideoTile(
            isLocal: false,
            name: participant['name'] as String,
            avatar: participant['avatar'] as String?,
            isVideoEnabled: participant['isVideoEnabled'] as bool? ?? false,
          );
        }
        return Container();
      },
    );
  }

  Widget _buildVideoTile({
    required bool isLocal,
    required String name,
    String? avatar,
    required bool isVideoEnabled,
  }) {
    return Container(
      margin: EdgeInsets.all(0.5.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2.w),
        child: Stack(
          children: [
            // Video feed or avatar
            Positioned.fill(
              child: isVideoEnabled
                  ? Container(
                      color: Colors.black,
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'videocam',
                          color: Colors.white,
                          size: 8.w,
                        ),
                      ),
                    )
                  : Container(
                      color: AppTheme.lightTheme.colorScheme.primaryContainer,
                      child: Center(
                        child: avatar != null
                            ? CustomImageWidget(
                                imageUrl: avatar,
                                width: 15.w,
                                height: 15.w,
                                fit: BoxFit.cover,
                              )
                            : CircleAvatar(
                                radius: 7.5.w,
                                backgroundColor:
                                    AppTheme.lightTheme.primaryColor,
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : "U",
                                  style: AppTheme
                                      .lightTheme.textTheme.titleLarge
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontSize: 6.w,
                                  ),
                                ),
                              ),
                      ),
                    ),
            ),

            // Name label
            Positioned(
              bottom: 1.w,
              left: 1.w,
              right: 1.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.w),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(1.w),
                ),
                child: Text(
                  name,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontSize: 10.sp,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Mute indicator
            if (!isVideoEnabled)
              Positioned(
                top: 1.w,
                right: 1.w,
                child: Container(
                  padding: EdgeInsets.all(1.w),
                  decoration: BoxDecoration(
                    color: AppTheme.errorLight,
                    borderRadius: BorderRadius.circular(1.w),
                  ),
                  child: CustomIconWidget(
                    iconName: 'mic_off',
                    color: Colors.white,
                    size: 3.w,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
