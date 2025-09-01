import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._();
  
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<bool> initialize() async {
    try {
      if (_isInitialized) return true;

      // Request notification permissions
      if (!kIsWeb) {
        final permission = await Permission.notification.request();
        if (!permission.isGranted) {
          if (kDebugMode) {
            print('⚠️ Notification permission denied');
          }
          return false;
        }
      }

      // Initialize notification settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = true;

      if (kDebugMode) {
        print('✅ Notification service initialized successfully');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Notification service initialization failed: $e');
      }
      return false;
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      print('📱 Notification tapped: ${response.payload}');
    }
    
    // Handle notification tap based on payload
    final payload = response.payload;
    if (payload != null) {
      // Parse payload and navigate accordingly
      // This would be implemented based on your navigation requirements
    }
  }

  Future<void> showRoomInvitation({
    required String roomName,
    required String inviterName,
    required String roomId,
  }) async {
    if (!_isInitialized) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        'room_invitations',
        'دعوات الغرف',
        channelDescription: 'إشعارات دعوات الانضمام للغرف',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        roomId.hashCode,
        'دعوة للانضمام',
        '$inviterName يدعوك للانضمام إلى "$roomName"',
        details,
        payload: 'room_invitation:$roomId',
      );

      if (kDebugMode) {
        print('✅ Room invitation notification sent');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Show room invitation failed: $e');
      }
    }
  }

  Future<void> showNewMessage({
    required String senderName,
    required String message,
    required String roomName,
    required String roomId,
  }) async {
    if (!_isInitialized) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        'chat_messages',
        'رسائل المحادثة',
        channelDescription: 'إشعارات الرسائل الجديدة',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch,
        '$senderName في $roomName',
        message,
        details,
        payload: 'new_message:$roomId',
      );

      if (kDebugMode) {
        print('✅ New message notification sent');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Show new message notification failed: $e');
      }
    }
  }

  Future<void> showRoomStarted({
    required String roomName,
    required String roomId,
  }) async {
    if (!_isInitialized) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        'room_events',
        'أحداث الغرف',
        channelDescription: 'إشعارات أحداث الغرف',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        roomId.hashCode,
        'غرفة جديدة نشطة',
        'بدأت الغرفة "$roomName" - انضم الآن!',
        details,
        payload: 'room_started:$roomId',
      );

      if (kDebugMode) {
        print('✅ Room started notification sent');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Show room started notification failed: $e');
      }
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Cancel notification failed: $e');
      }
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Cancel all notifications failed: $e');
      }
    }
  }
}