import 'package:flutter/foundation.dart';

/// نظام تسجيل محسن للتطبيق مع دعم مستويات مختلفة من التسجيل
class AppLogger {
  static const String _tag = 'LeqaaChat';
  
  // مستويات التسجيل
  static const int _levelVerbose = 0;
  static const int _levelDebug = 1;
  static const int _levelInfo = 2;
  static const int _levelWarning = 3;
  static const int _levelError = 4;
  
  // المستوى الحالي للتسجيل
  static int _currentLevel = kDebugMode ? _levelDebug : _levelError;

  /// تعيين مستوى التسجيل
  static void setLogLevel(int level) {
    _currentLevel = level;
  }

  /// تسجيل رسالة مفصلة (Verbose)
  static void v(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (_currentLevel <= _levelVerbose) {
      _log('VERBOSE', message, tag: tag, error: error, stackTrace: stackTrace);
    }
  }

  /// تسجيل رسالة تطوير (Debug)
  static void d(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (_currentLevel <= _levelDebug) {
      _log('DEBUG', message, tag: tag, error: error, stackTrace: stackTrace);
    }
  }

  /// تسجيل رسالة معلومات (Info)
  static void i(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (_currentLevel <= _levelInfo) {
      _log('INFO', message, tag: tag, error: error, stackTrace: stackTrace);
    }
  }

  /// تسجيل رسالة تحذير (Warning)
  static void w(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (_currentLevel <= _levelWarning) {
      _log('WARNING', message, tag: tag, error: error, stackTrace: stackTrace);
    }
  }

  /// تسجيل رسالة خطأ (Error)
  static void e(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (_currentLevel <= _levelError) {
      _log('ERROR', message, tag: tag, error: error, stackTrace: stackTrace);
    }
  }

  /// تسجيل أحداث المصادقة
  static void auth(String message, {Object? error}) {
    i('🔐 AUTH: $message', tag: 'Authentication', error: error);
  }

  /// تسجيل أحداث الغرف
  static void room(String message, {Object? error}) {
    i('🏠 ROOM: $message', tag: 'Rooms', error: error);
  }

  /// تسجيل أحداث المحادثة
  static void chat(String message, {Object? error}) {
    i('💬 CHAT: $message', tag: 'Chat', error: error);
  }

  /// تسجيل أحداث الصوت والفيديو
  static void media(String message, {Object? error}) {
    i('🎥 MEDIA: $message', tag: 'Media', error: error);
  }

  /// تسجيل أحداث الشبكة
  static void network(String message, {Object? error}) {
    i('🌐 NETWORK: $message', tag: 'Network', error: error);
  }

  /// تسجيل أحداث قاعدة البيانات
  static void database(String message, {Object? error}) {
    i('🗄️ DATABASE: $message', tag: 'Database', error: error);
  }

  /// تسجيل أحداث الإشعارات
  static void notification(String message, {Object? error}) {
    i('🔔 NOTIFICATION: $message', tag: 'Notifications', error: error);
  }

  /// تسجيل أحداث الأذونات
  static void permission(String message, {Object? error}) {
    i('🔑 PERMISSION: $message', tag: 'Permissions', error: error);
  }

  /// تسجيل أحداث الأداء
  static void performance(String message, {Object? error}) {
    d('⚡ PERFORMANCE: $message', tag: 'Performance', error: error);
  }

  /// تسجيل أحداث واجهة المستخدم
  static void ui(String message, {Object? error}) {
    d('🎨 UI: $message', tag: 'UserInterface', error: error);
  }

  /// الدالة الأساسية للتسجيل
  static void _log(
    String level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode && level != 'ERROR') return;

    final timestamp = DateTime.now().toIso8601String();
    final logTag = tag ?? _tag;
    final logMessage = '[$timestamp] [$level] [$logTag] $message';

    // طباعة الرسالة
    debugPrint(logMessage);

    // طباعة الخطأ إن وجد
    if (error != null) {
      debugPrint('Error: $error');
    }

    // طباعة Stack Trace إن وجد
    if (stackTrace != null) {
      debugPrint('Stack Trace: $stackTrace');
    }

    // في الإنتاج، يمكن إرسال الأخطاء لخدمة مراقبة خارجية
    if (!kDebugMode && level == 'ERROR') {
      _reportErrorToService(message, error, stackTrace);
    }
  }

  /// إرسال الأخطاء لخدمة المراقبة (للإنتاج)
  static void _reportErrorToService(String message, Object? error, StackTrace? stackTrace) {
    // هنا يمكن إضافة كود لإرسال الأخطاء لخدمة مثل Crashlytics أو Sentry
    // مثال:
    // FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: message);
  }

  /// تسجيل بداية عملية
  static void startOperation(String operationName) {
    d('🚀 بدء العملية: $operationName', tag: 'Operations');
  }

  /// تسجيل انتهاء عملية
  static void endOperation(String operationName, {Duration? duration}) {
    final durationText = duration != null ? ' (${duration.inMilliseconds}ms)' : '';
    d('✅ انتهاء العملية: $operationName$durationText', tag: 'Operations');
  }

  /// تسجيل فشل عملية
  static void failOperation(String operationName, Object error) {
    e('❌ فشل العملية: $operationName', tag: 'Operations', error: error);
  }

  /// تسجيل معلومات المستخدم (بدون بيانات حساسة)
  static void userAction(String userId, String action) {
    i('👤 المستخدم ${userId.substring(0, 8)}... قام بـ: $action', tag: 'UserActions');
  }

  /// تسجيل إحصائيات الأداء
  static void performanceMetric(String metric, dynamic value) {
    d('📊 $metric: $value', tag: 'Performance');
  }

  /// تسجيل استخدام الذاكرة
  static void memoryUsage(String component, int memoryMB) {
    d('🧠 استخدام الذاكرة - $component: ${memoryMB}MB', tag: 'Memory');
  }

  /// تسجيل جودة الشبكة
  static void networkQuality(String quality, int latencyMs) {
    i('📶 جودة الشبكة: $quality (${latencyMs}ms)', tag: 'Network');
  }
}