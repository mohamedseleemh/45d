import 'package:flutter/foundation.dart';

import '../utils/app_logger.dart';
import '../config/app_config.dart';

/// خدمة التحليلات والإحصائيات (مع احترام الخصوصية)
class AnalyticsService {
  static AnalyticsService? _instance;
  static AnalyticsService get instance => _instance ??= AnalyticsService._();
  
  AnalyticsService._();

  bool _isInitialized = false;
  final Map<String, dynamic> _sessionData = {};
  final List<AnalyticsEvent> _events = [];

  /// تهيئة خدمة التحليلات
  Future<void> initialize() async {
    try {
      if (!AppConfig.instance.enableAnalytics) {
        AppLogger.i('التحليلات معطلة في هذه البيئة');
        return;
      }

      _sessionData['session_id'] = DateTime.now().millisecondsSinceEpoch.toString();
      _sessionData['app_version'] = AppConfig.appVersion;
      _sessionData['platform'] = kIsWeb ? 'web' : 'mobile';
      _sessionData['started_at'] = DateTime.now().toIso8601String();

      _isInitialized = true;
      AppLogger.i('تم تهيئة خدمة التحليلات');
    } catch (e) {
      AppLogger.e('فشل في تهيئة خدمة التحليلات', error: e);
    }
  }

  /// تسجيل حدث
  void logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) {
    if (!_isInitialized || !AppConfig.instance.enableAnalytics) return;

    try {
      final event = AnalyticsEvent(
        name: name,
        parameters: parameters ?? {},
        timestamp: DateTime.now(),
      );

      _events.add(event);
      
      // الاحتفاظ بآخر 1000 حدث فقط
      if (_events.length > 1000) {
        _events.removeRange(0, _events.length - 1000);
      }

      AppLogger.d('تم تسجيل الحدث: $name');
      
      // في الإنتاج، يمكن إرسال الأحداث لخدمة تحليلات خارجية
      if (kReleaseMode) {
        _sendEventToAnalyticsService(event);
      }
    } catch (e) {
      AppLogger.e('فشل في تسجيل الحدث', error: e);
    }
  }

  /// تسجيل دخول المستخدم
  void logUserLogin(String userId) {
    logEvent(
      name: 'user_login',
      parameters: {
        'user_id': _hashUserId(userId),
        'login_method': 'email_password',
      },
    );
  }

  /// تسجيل خروج المستخدم
  void logUserLogout(String userId) {
    logEvent(
      name: 'user_logout',
      parameters: {
        'user_id': _hashUserId(userId),
        'session_duration': _getSessionDuration(),
      },
    );
  }

  /// تسجيل إنشاء غرفة
  void logRoomCreated({
    required String roomId,
    required String roomType,
    required String privacy,
    required int participantLimit,
  }) {
    logEvent(
      name: 'room_created',
      parameters: {
        'room_type': roomType,
        'privacy': privacy,
        'participant_limit': participantLimit,
      },
    );
  }

  /// تسجيل الانضمام للغرفة
  void logRoomJoined({
    required String roomId,
    required String roomType,
    required int participantCount,
  }) {
    logEvent(
      name: 'room_joined',
      parameters: {
        'room_type': roomType,
        'participant_count': participantCount,
      },
    );
  }

  /// تسجيل مغادرة الغرفة
  void logRoomLeft({
    required String roomId,
    required Duration sessionDuration,
  }) {
    logEvent(
      name: 'room_left',
      parameters: {
        'session_duration_minutes': sessionDuration.inMinutes,
      },
    );
  }

  /// تسجيل إرسال رسالة
  void logMessageSent({
    required String roomId,
    required String messageType,
  }) {
    logEvent(
      name: 'message_sent',
      parameters: {
        'message_type': messageType,
      },
    );
  }

  /// تسجيل خطأ في التطبيق
  void logError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
  }) {
    logEvent(
      name: 'app_error',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
        'has_stack_trace': stackTrace != null,
      },
    );
  }

  /// تسجيل أداء العملية
  void logPerformance({
    required String operationName,
    required int durationMs,
    Map<String, dynamic>? additionalData,
  }) {
    logEvent(
      name: 'performance_metric',
      parameters: {
        'operation': operationName,
        'duration_ms': durationMs,
        'is_slow': durationMs > 1000,
        ...?additionalData,
      },
    );
  }

  /// تسجيل استخدام ميزة
  void logFeatureUsage(String featureName) {
    logEvent(
      name: 'feature_used',
      parameters: {
        'feature_name': featureName,
      },
    );
  }

  /// تسجيل تغيير الإعدادات
  void logSettingsChanged({
    required String settingName,
    required dynamic oldValue,
    required dynamic newValue,
  }) {
    logEvent(
      name: 'settings_changed',
      parameters: {
        'setting_name': settingName,
        'old_value': oldValue.toString(),
        'new_value': newValue.toString(),
      },
    );
  }

  /// الحصول على إحصائيات الجلسة
  Map<String, dynamic> getSessionStats() {
    return {
      'session_id': _sessionData['session_id'],
      'duration_minutes': _getSessionDuration(),
      'events_count': _events.length,
      'app_version': AppConfig.appVersion,
    };
  }

  /// الحصول على أحداث الجلسة
  List<AnalyticsEvent> getSessionEvents() {
    return List.from(_events);
  }

  /// مسح بيانات التحليلات
  void clearAnalyticsData() {
    _events.clear();
    _sessionData.clear();
    AppLogger.i('تم مسح بيانات التحليلات');
  }

  /// تشفير معرف المستخدم للخصوصية
  String _hashUserId(String userId) {
    // تشفير بسيط لحماية خصوصية المستخدم
    return userId.hashCode.abs().toString();
  }

  /// حساب مدة الجلسة
  int _getSessionDuration() {
    final startedAt = _sessionData['started_at'] as String?;
    if (startedAt != null) {
      final startTime = DateTime.parse(startedAt);
      return DateTime.now().difference(startTime).inMinutes;
    }
    return 0;
  }

  /// إرسال الحدث لخدمة التحليلات الخارجية
  void _sendEventToAnalyticsService(AnalyticsEvent event) {
    // في الإنتاج، يمكن إرسال الأحداث لخدمة مثل:
    // - Firebase Analytics
    // - Google Analytics
    // - Mixpanel
    // - أو خدمة تحليلات مخصصة
    
    if (kDebugMode) {
      AppLogger.d('إرسال حدث للتحليلات: ${event.name}');
    }
  }
}

/// نموذج حدث التحليلات
class AnalyticsEvent {
  final String name;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;

  const AnalyticsEvent({
    required this.name,
    required this.parameters,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'parameters': parameters,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return AnalyticsEvent(
      name: json['name'],
      parameters: Map<String, dynamic>.from(json['parameters']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  @override
  String toString() {
    return 'AnalyticsEvent(name: $name, parameters: $parameters, timestamp: $timestamp)';
  }
}