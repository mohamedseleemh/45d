import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../shared/models/room_model.dart';
import '../../widgets/custom_image_widget.dart';

/// بطاقة غرفة محسنة مع أنيميشن وتفاصيل أكثر
class EnhancedRoomCard extends StatefulWidget {
  final RoomModel room;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const EnhancedRoomCard({
    Key? key,
    required this.room,
    required this.onTap,
    this.onLongPress,
    this.isFavorite = false,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  State<EnhancedRoomCard> createState() => _EnhancedRoomCardState();
}

class _EnhancedRoomCardState extends State<EnhancedRoomCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  Color _getStatusColor() {
    if (!widget.room.isActive) return AppTheme.lightTheme.colorScheme.outline;
    if (widget.room.isFull) return AppTheme.warningLight;
    return AppTheme.successLight;
  }

  String _getStatusText() {
    if (!widget.room.isActive) return 'غير نشطة';
    if (widget.room.isFull) return 'ممتلئة';
    return 'متاحة';
  }

  Widget _buildRoomTypeChip() {
    Color chipColor;
    String chipText;
    String iconName;

    switch (widget.room.type) {
      case 'voice':
        chipColor = AppTheme.lightTheme.colorScheme.secondary;
        chipText = 'صوت';
        iconName = 'mic';
        break;
      case 'video':
        chipColor = AppTheme.lightTheme.colorScheme.tertiary;
        chipText = 'فيديو';
        iconName = 'videocam';
        break;
      case 'both':
        chipColor = AppTheme.lightTheme.primaryColor;
        chipText = 'صوت وفيديو';
        iconName = 'video_call';
        break;
      default:
        chipColor = AppTheme.lightTheme.colorScheme.outline;
        chipText = 'غير محدد';
        iconName = 'help_outline';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: chipColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: chipColor,
            size: 3.w,
          ),
          SizedBox(width: 1.w),
          Text(
            chipText,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyIndicator() {
    if (widget.room.isPublic) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: CustomIconWidget(
        iconName: widget.room.isPrivate ? 'lock' : 'mail',
        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        size: 3.w,
      ),
    );
  }

  Widget _buildParticipantIndicator() {
    final fillPercentage = widget.room.fillPercentage;
    Color indicatorColor;

    if (fillPercentage >= 0.9) {
      indicatorColor = AppTheme.errorLight;
    } else if (fillPercentage >= 0.7) {
      indicatorColor = AppTheme.warningLight;
    } else {
      indicatorColor = AppTheme.successLight;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: indicatorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: 'people',
            color: indicatorColor,
            size: 3.w,
          ),
          SizedBox(width: 1.w),
          Text(
            widget.room.participantCountText,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: indicatorColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowLight,
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value / 2),
                  ),
                ],
                border: widget.room.isActive
                    ? Border.all(
                        color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
                        width: 1,
                      )
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with image and status
                  Container(
                    height: 20.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      gradient: widget.room.imageUrl != null
                          ? null
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.lightTheme.primaryColor,
                                AppTheme.lightTheme.primaryColor.withValues(alpha: 0.7),
                              ],
                            ),
                    ),
                    child: Stack(
                      children: [
                        // Background image
                        if (widget.room.imageUrl != null)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: CustomImageWidget(
                                imageUrl: widget.room.imageUrl!,
                                width: double.infinity,
                                height: 20.h,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                        // Gradient overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.7),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Top row with status and favorite
                        Positioned(
                          top: 2.h,
                          left: 3.w,
                          right: 3.w,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Status indicator
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 0.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 2.w,
                                      height: 2.w,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 1.w),
                                    Text(
                                      _getStatusText(),
                                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Favorite button
                              if (widget.onFavoriteToggle != null)
                                GestureDetector(
                                  onTap: widget.onFavoriteToggle,
                                  child: Container(
                                    padding: EdgeInsets.all(2.w),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: CustomIconWidget(
                                      iconName: widget.isFavorite ? 'favorite' : 'favorite_border',
                                      color: widget.isFavorite 
                                          ? AppTheme.errorLight 
                                          : Colors.white,
                                      size: 4.w,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Bottom row with room type and privacy
                        Positioned(
                          bottom: 2.h,
                          left: 3.w,
                          right: 3.w,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildRoomTypeChip(),
                              _buildPrivacyIndicator(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Room name
                        Text(
                          widget.room.name,
                          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        if (widget.room.description != null && widget.room.description!.isNotEmpty) ...[
                          SizedBox(height: 1.h),
                          Text(
                            widget.room.description!,
                            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        SizedBox(height: 2.h),

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
                                child: widget.room.owner?.avatarUrl != null
                                    ? CustomImageWidget(
                                        imageUrl: widget.room.owner!.avatarUrl!,
                                        width: 8.w,
                                        height: 8.w,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: AppTheme.lightTheme.primaryColor,
                                        child: Center(
                                          child: Text(
                                            widget.room.owner?.initials ?? 'م',
                                            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ),

                            SizedBox(width: 2.w),

                            // Owner info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.room.owner?.displayName ?? 'مالك الغرفة',
                                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'مالك الغرفة',
                                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Participant indicator
                            _buildParticipantIndicator(),
                          ],
                        ),

                        // Live indicator for active rooms
                        if (widget.room.isActive && widget.room.currentParticipants > 0) ...[
                          SizedBox(height: 2.h),
                          _buildLiveIndicator(),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiveIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.successLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.successLight.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated live dot
          AnimatedContainer(
            duration: Duration(milliseconds: 1000),
            width: 2.w,
            height: 2.w,
            decoration: BoxDecoration(
              color: AppTheme.successLight,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            'مباشر الآن',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.successLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 2.w),
          // Audio waveform animation
          if (widget.room.isVoiceOnly || widget.room.supportsBoth)
            _buildAudioWaveform(),
        ],
      ),
    );
  }

  Widget _buildAudioWaveform() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          margin: EdgeInsets.symmetric(horizontal: 0.2.w),
          width: 0.8.w,
          height: (1 + (index % 3)) * 0.8.h,
          decoration: BoxDecoration(
            color: AppTheme.successLight.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }
}