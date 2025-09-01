import 'package:flutter/material.dart';

/// Widget مخصص لعرض الأيقونات مع دعم Material Icons
/// يوفر واجهة موحدة لاستخدام الأيقونات في التطبيق
class CustomIconWidget extends StatelessWidget {
  final String iconName;
  final double? size;
  final Color? color;

  const CustomIconWidget({
    Key? key,
    required this.iconName,
    this.size,
    this.color,
  }) : super(key: key);

  /// تحويل اسم الأيقونة إلى IconData
  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      // Navigation icons
      case 'arrow_back':
        return Icons.arrow_back;
      case 'arrow_forward':
        return Icons.arrow_forward;
      case 'arrow_forward_ios':
        return Icons.arrow_forward_ios;
      case 'keyboard_arrow_left':
        return Icons.keyboard_arrow_left;
      case 'keyboard_arrow_down':
        return Icons.keyboard_arrow_down;
      case 'close':
        return Icons.close;
      case 'menu':
        return Icons.menu;

      // Communication icons
      case 'video_call':
        return Icons.video_call;
      case 'videocam':
        return Icons.videocam;
      case 'videocam_off':
        return Icons.videocam_off;
      case 'mic':
        return Icons.mic;
      case 'mic_off':
        return Icons.mic_off;
      case 'volume_up':
        return Icons.volume_up;
      case 'volume_off':
        return Icons.volume_off;
      case 'hearing':
        return Icons.hearing;
      case 'call_end':
        return Icons.call_end;
      case 'phone':
        return Icons.phone;
      case 'record_voice_over':
        return Icons.record_voice_over;

      // Chat and messaging
      case 'chat':
        return Icons.chat;
      case 'chat_bubble':
        return Icons.chat_bubble;
      case 'chat_bubble_outline':
        return Icons.chat_bubble_outline;
      case 'send':
        return Icons.send;
      case 'message':
        return Icons.message;

      // User and people
      case 'person':
        return Icons.person;
      case 'person_outline':
        return Icons.person_outline;
      case 'person_add':
        return Icons.person_add;
      case 'person_remove':
        return Icons.person_remove;
      case 'people':
        return Icons.people;
      case 'people_outline':
        return Icons.people_outline;
      case 'group':
        return Icons.group;
      case 'admin_panel_settings':
        return Icons.admin_panel_settings;

      // Authentication
      case 'login':
        return Icons.login;
      case 'logout':
        return Icons.logout;
      case 'lock':
        return Icons.lock;
      case 'lock_outline':
        return Icons.lock_outline;
      case 'lock_reset':
        return Icons.lock_reset;
      case 'email':
        return Icons.email;
      case 'visibility':
        return Icons.visibility;
      case 'visibility_off':
        return Icons.visibility_off;

      // Actions
      case 'add':
        return Icons.add;
      case 'remove':
        return Icons.remove;
      case 'edit':
        return Icons.edit;
      case 'delete':
        return Icons.delete;
      case 'delete_forever':
        return Icons.delete_forever;
      case 'save':
        return Icons.save;
      case 'refresh':
        return Icons.refresh;
      case 'search':
        return Icons.search;
      case 'filter_list':
        return Icons.filter_list;
      case 'tune':
        return Icons.tune;
      case 'more_vert':
        return Icons.more_vert;
      case 'more_horiz':
        return Icons.more_horiz;

      // Status and feedback
      case 'check':
        return Icons.check;
      case 'check_circle':
        return Icons.check_circle;
      case 'check_circle_outline':
        return Icons.check_circle_outline;
      case 'error':
        return Icons.error;
      case 'error_outline':
        return Icons.error_outline;
      case 'warning':
        return Icons.warning;
      case 'warning_amber':
        return Icons.warning_amber;
      case 'info':
        return Icons.info;
      case 'info_outline':
        return Icons.info_outline;
      case 'help':
        return Icons.help;
      case 'help_outline':
        return Icons.help_outline;

      // Media and files
      case 'camera_alt':
        return Icons.camera_alt;
      case 'photo_library':
        return Icons.photo_library;
      case 'add_a_photo':
        return Icons.add_a_photo;
      case 'file_upload':
        return Icons.file_upload;
      case 'file_download':
        return Icons.file_download;
      case 'attach_file':
        return Icons.attach_file;
      case 'screen_share':
        return Icons.screen_share;

      // Settings and configuration
      case 'settings':
        return Icons.settings;
      case 'tune_outlined':
        return Icons.tune_outlined;
      case 'palette':
        return Icons.palette;
      case 'language':
        return Icons.language;
      case 'notifications':
        return Icons.notifications;
      case 'notifications_off':
        return Icons.notifications_off;

      // Time and scheduling
      case 'schedule':
        return Icons.schedule;
      case 'access_time':
        return Icons.access_time;
      case 'timer':
        return Icons.timer;
      case 'today':
        return Icons.today;

      // Connectivity and network
      case 'wifi':
        return Icons.wifi;
      case 'wifi_off':
        return Icons.wifi_off;
      case 'signal_cellular_4_bar':
        return Icons.signal_cellular_4_bar;
      case 'signal_cellular_0_bar':
        return Icons.signal_cellular_0_bar;
      case 'network_check':
        return Icons.network_check;

      // Privacy and security
      case 'public':
        return Icons.public;
      case 'private':
        return Icons.lock;
      case 'mail':
        return Icons.mail;
      case 'mark_email_read':
        return Icons.mark_email_read;
      case 'block':
        return Icons.block;
      case 'report':
        return Icons.report;

      // Room and meeting
      case 'meeting_room':
        return Icons.meeting_room;
      case 'room':
        return Icons.room;
      case 'door_front':
        return Icons.door_front;
      case 'exit_to_app':
        return Icons.exit_to_app;

      // Bookmarks and favorites
      case 'bookmark':
        return Icons.bookmark;
      case 'bookmark_border':
        return Icons.bookmark_border;
      case 'favorite':
        return Icons.favorite;
      case 'favorite_border':
        return Icons.favorite_border;

      // UI elements
      case 'apps':
        return Icons.apps;
      case 'dashboard':
        return Icons.dashboard;
      case 'home':
        return Icons.home;
      case 'waving_hand':
        return Icons.waving_hand;

      // Default fallback
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      _getIconData(iconName),
      size: size,
      color: color,
    );
  }
}