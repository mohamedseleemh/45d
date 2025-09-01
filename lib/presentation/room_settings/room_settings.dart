import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/advanced_settings_section.dart';
import './widgets/danger_zone_section.dart';
import './widgets/moderation_tools_section.dart';
import './widgets/participant_management_section.dart';
import './widgets/room_configuration_section.dart';
import './widgets/room_info_section.dart';

class RoomSettings extends StatefulWidget {
  const RoomSettings({super.key});

  @override
  State<RoomSettings> createState() => _RoomSettingsState();
}

class _RoomSettingsState extends State<RoomSettings> {
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;

  // Room Information
  String _roomName = 'غرفة المطورين العرب';
  String _roomDescription =
      'مساحة للنقاش والتعلم حول تطوير التطبيقات والبرمجة باللغة العربية';
  String _roomImageUrl =
      'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3';

  // Room Configuration
  String _privacyLevel = 'public';
  int _participantLimit = 20;
  bool _autoMuteNewMembers = false;
  bool _allowScreenSharing = true;

  // Advanced Settings
  bool _roomRecording = false;
  bool _profanityFilter = true;
  int _roomExpirationHours = 0;

  // Moderation
  bool _autoModeration = true;

  // Mock data
  final List<Map<String, dynamic>> _participants = [
    {
      'id': '1',
      'name': 'محمد أحمد',
      'avatar':
          'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
      'role': 'owner',
      'isOnline': true,
      'isMuted': false,
    },
    {
      'id': '2',
      'name': 'فاطمة علي',
      'avatar':
          'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
      'role': 'participant',
      'isOnline': true,
      'isMuted': false,
    },
    {
      'id': '3',
      'name': 'أحمد محمود',
      'avatar':
          'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
      'role': 'participant',
      'isOnline': false,
      'isMuted': true,
    },
    {
      'id': '4',
      'name': 'نور حسن',
      'avatar':
          'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
      'role': 'participant',
      'isOnline': true,
      'isMuted': false,
    },
  ];

  final List<Map<String, dynamic>> _blockedUsers = [
    {
      'id': '5',
      'name': 'مستخدم محظور',
      'avatar':
          'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
      'blockedDate': '2025-08-25',
    },
  ];

  final List<Map<String, dynamic>> _reportedMessages = [
    {
      'id': 'msg1',
      'content': 'رسالة تحتوي على محتوى غير لائق',
      'senderName': 'مستخدم مجهول',
      'senderAvatar':
          'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
      'reportCount': 3,
    },
    {
      'id': 'msg2',
      'content': 'رسالة أخرى مبلغ عنها',
      'senderName': 'مستخدم آخر',
      'senderAvatar':
          'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
      'reportCount': 1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _hasUnsavedChanges) {
          _showUnsavedChangesDialog();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'إعدادات الغرفة',
            textDirection: TextDirection.rtl,
          ),
          leading: IconButton(
            onPressed: () {
              if (_hasUnsavedChanges) {
                _showUnsavedChangesDialog();
              } else {
                Navigator.pop(context);
              }
            },
            icon: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          actions: [
            if (_hasUnsavedChanges)
              TextButton(
                onPressed: _isSaving ? null : _saveChanges,
                child: _isSaving
                    ? SizedBox(
                        width: 4.w,
                        height: 4.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      )
                    : Text(
                        'حفظ التغييرات',
                        style: TextStyle(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              // Room Information Section
              RoomInfoSection(
                roomName: _roomName,
                roomDescription: _roomDescription,
                roomImageUrl: _roomImageUrl,
                onNameChanged: (value) {
                  setState(() {
                    _roomName = value;
                    _hasUnsavedChanges = true;
                  });
                },
                onDescriptionChanged: (value) {
                  setState(() {
                    _roomDescription = value;
                    _hasUnsavedChanges = true;
                  });
                },
                onImageChanged: (value) {
                  setState(() {
                    _roomImageUrl = value;
                    _hasUnsavedChanges = true;
                  });
                },
              ),
              SizedBox(height: 4.h),

              // Participant Management Section
              ParticipantManagementSection(
                participants: _participants,
                onParticipantAction: _handleParticipantAction,
              ),
              SizedBox(height: 4.h),

              // Room Configuration Section
              RoomConfigurationSection(
                privacyLevel: _privacyLevel,
                participantLimit: _participantLimit,
                autoMuteNewMembers: _autoMuteNewMembers,
                allowScreenSharing: _allowScreenSharing,
                onPrivacyChanged: (value) {
                  setState(() {
                    _privacyLevel = value;
                    _hasUnsavedChanges = true;
                  });
                },
                onParticipantLimitChanged: (value) {
                  setState(() {
                    _participantLimit = value;
                    _hasUnsavedChanges = true;
                  });
                },
                onAutoMuteChanged: (value) {
                  setState(() {
                    _autoMuteNewMembers = value;
                    _hasUnsavedChanges = true;
                  });
                },
                onScreenSharingChanged: (value) {
                  setState(() {
                    _allowScreenSharing = value;
                    _hasUnsavedChanges = true;
                  });
                },
              ),
              SizedBox(height: 4.h),

              // Advanced Settings Section
              AdvancedSettingsSection(
                roomRecording: _roomRecording,
                profanityFilter: _profanityFilter,
                roomExpirationHours: _roomExpirationHours,
                onRecordingChanged: (value) {
                  setState(() {
                    _roomRecording = value;
                    _hasUnsavedChanges = true;
                  });
                },
                onProfanityFilterChanged: (value) {
                  setState(() {
                    _profanityFilter = value;
                    _hasUnsavedChanges = true;
                  });
                },
                onExpirationChanged: (value) {
                  setState(() {
                    _roomExpirationHours = value;
                    _hasUnsavedChanges = true;
                  });
                },
              ),
              SizedBox(height: 4.h),

              // Moderation Tools Section
              ModerationToolsSection(
                blockedUsers: _blockedUsers,
                reportedMessages: _reportedMessages,
                autoModeration: _autoModeration,
                onUnblockUser: _handleUnblockUser,
                onMessageAction: _handleMessageAction,
                onAutoModerationChanged: (value) {
                  setState(() {
                    _autoModeration = value;
                    _hasUnsavedChanges = true;
                  });
                },
              ),
              SizedBox(height: 4.h),

              // Danger Zone Section
              DangerZoneSection(
                onTransferOwnership: _handleTransferOwnership,
                onDeleteRoom: _handleDeleteRoom,
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  void _handleParticipantAction(String userId, String action) {
    setState(() {
      final participantIndex =
          _participants.indexWhere((p) => p['id'] == userId);
      if (participantIndex != -1) {
        switch (action) {
          case 'promote':
            _participants[participantIndex]['role'] = 'co-owner';
            _showSuccessMessage('تم ترقية المشارك إلى مشرف مساعد');
            break;
          case 'mute':
            _participants[participantIndex]['isMuted'] = true;
            _showSuccessMessage('تم كتم صوت المشارك');
            break;
          case 'unmute':
            _participants[participantIndex]['isMuted'] = false;
            _showSuccessMessage('تم إلغاء كتم صوت المشارك');
            break;
          case 'remove':
            _participants.removeAt(participantIndex);
            _showSuccessMessage('تم إزالة المشارك من الغرفة');
            break;
        }
        _hasUnsavedChanges = true;
      }
    });
  }

  void _handleUnblockUser(String userId) {
    setState(() {
      _blockedUsers.removeWhere((user) => user['id'] == userId);
      _hasUnsavedChanges = true;
    });
    _showSuccessMessage('تم إلغاء حظر المستخدم');
  }

  void _handleMessageAction(String messageId, String action) {
    setState(() {
      if (action == 'delete' || action == 'dismiss') {
        _reportedMessages.removeWhere((msg) => msg['id'] == messageId);
        _hasUnsavedChanges = true;
      }
    });
    _showSuccessMessage(
        action == 'delete' ? 'تم حذف الرسالة' : 'تم تجاهل البلاغ');
  }

  void _handleTransferOwnership() {
    _showSuccessMessage('تم نقل ملكية الغرفة بنجاح');
    Navigator.pushReplacementNamed(context, '/room-list');
  }

  void _handleDeleteRoom() {
    _showSuccessMessage('تم حذف الغرفة نهائياً');
    Navigator.pushReplacementNamed(context, '/room-list');
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isSaving = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isSaving = false;
      _hasUnsavedChanges = false;
    });

    _showSuccessMessage('تم حفظ التغييرات بنجاح');
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تغييرات غير محفوظة',
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        content: Text(
          'لديك تغييرات غير محفوظة. هل تريد حفظها قبل المغادرة؟',
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'تجاهل التغييرات',
              textDirection: TextDirection.rtl,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _saveChanges();
              Navigator.pop(context);
            },
            child: Text(
              'حفظ والخروج',
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
