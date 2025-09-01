import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_logger.dart';

/// معالج الأخطاء المركزي للتطبيق
class ErrorHandler {
  /// معالجة الأخطاء وتحويلها لرسائل مفهومة للمستخدم
  static String handleError(dynamic error) {
    AppLogger.e('خطأ في التطبيق', error: error);

    if (error is AuthException) {
      return _handleAuthError(error);
    } else if (error is PostgrestException) {
      return _handleDatabaseError(error);
    } else if (error is StorageException) {
      return _handleStorageError(error);
    } else if (error is Exception) {
      return _handleGeneralException(error);
    } else {
      return 'حدث خطأ غير متوقع';
    }
  }

  /// معالجة أخطاء المصادقة
  static String _handleAuthError(AuthException error) {
    switch (error.message.toLowerCase()) {
      case 'invalid login credentials':
        return 'بيانات تسجيل الدخول غير صحيحة';
      case 'email not confirmed':
        return 'يرجى تأكيد البريد الإلكتروني أولاً';
      case 'user already registered':
        return 'هذا البريد الإلكتروني مسجل مسبقاً';
      case 'weak password':
        return 'كلمة المرور ضعيفة، يرجى اختيار كلمة مرور أقوى';
      case 'email rate limit exceeded':
        return 'تم تجاوز الحد المسموح لإرسال الرسائل، حاول لاحقاً';
      case 'signup disabled':
        return 'التسجيل معطل حالياً';
      case 'invalid email':
        return 'البريد الإلكتروني غير صحيح';
      case 'password too short':
        return 'كلمة المرور قصيرة جداً';
      case 'session expired':
        return 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى';
      default:
        return 'خطأ في المصادقة: ${error.message}';
    }
  }

  /// معالجة أخطاء قاعدة البيانات
  static String _handleDatabaseError(PostgrestException error) {
    AppLogger.database('خطأ في قاعدة البيانات', error: error);

    switch (error.code) {
      case '23505': // Unique violation
        return 'البيانات موجودة مسبقاً';
      case '23503': // Foreign key violation
        return 'البيانات المرجعية غير موجودة';
      case '23514': // Check violation
        return 'البيانات المدخلة غير صحيحة';
      case '42501': // Insufficient privilege
        return 'ليس لديك صلاحية للقيام بهذا الإجراء';
      case 'PGRST116': // No rows found
        return 'البيانات المطلوبة غير موجودة';
      case 'PGRST301': // Row level security
        return 'ليس لديك صلاحية للوصول لهذه البيانات';
      default:
        if (error.message.contains('duplicate key')) {
          return 'البيانات موجودة مسبقاً';
        } else if (error.message.contains('not found')) {
          return 'البيانات المطلوبة غير موجودة';
        } else if (error.message.contains('permission')) {
          return 'ليس لديك صلاحية للقيام بهذا الإجراء';
        }
        return 'خطأ في قاعدة البيانات';
    }
  }

  /// معالجة أخطاء التخزين
  static String _handleStorageError(StorageException error) {
    AppLogger.e('خطأ في التخزين', error: error);

    switch (error.message.toLowerCase()) {
      case 'file too large':
        return 'حجم الملف كبير جداً';
      case 'invalid file type':
        return 'نوع الملف غير مدعوم';
      case 'storage quota exceeded':
        return 'تم تجاوز حد التخزين المسموح';
      case 'file not found':
        return 'الملف غير موجود';
      case 'upload failed':
        return 'فشل في رفع الملف';
      default:
        return 'خطأ في التخزين: ${error.message}';
    }
  }

  /// معالجة الاستثناءات العامة
  static String _handleGeneralException(Exception error) {
    final message = error.toString();

    if (message.contains('SocketException') || message.contains('NetworkException')) {
      return 'تحقق من اتصال الإنترنت وحاول مرة أخرى';
    } else if (message.contains('TimeoutException')) {
      return 'انتهت مهلة الاتصال، حاول مرة أخرى';
    } else if (message.contains('FormatException')) {
      return 'تنسيق البيانات غير صحيح';
    } else if (message.contains('Permission')) {
      return 'الأذونات مطلوبة لاستخدام هذه الميزة';
    } else if (message.contains('Camera')) {
      return 'خطأ في الكاميرا، تحقق من الأذونات';
    } else if (message.contains('Microphone')) {
      return 'خطأ في الميكروفون، تحقق من الأذونات';
    } else if (message.contains('Storage')) {
      return 'خطأ في الوصول للتخزين';
    }

    return 'حدث خطأ غير متوقع';
  }

  /// تسجيل خطأ مع تفاصيل إضافية
  static void logError({
    required String operation,
    required dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  }) {
    final errorMessage = 'فشل في العملية: $operation';
    
    AppLogger.e(
      errorMessage,
      error: error,
      stackTrace: stackTrace,
    );

    if (additionalData != null) {
      AppLogger.d('بيانات إضافية: $additionalData');
    }
  }

  /// تسجيل نجاح عملية
  static void logSuccess(String operation, {Map<String, dynamic>? data}) {
    AppLogger.i('✅ نجحت العملية: $operation');
    
    if (data != null) {
      AppLogger.d('البيانات: $data');
    }
  }

  /// تسجيل بداية عملية
  static void logOperationStart(String operation) {
    AppLogger.d('🚀 بدء العملية: $operation');
  }

  /// تسجيل انتهاء عملية مع الوقت المستغرق
  static void logOperationEnd(String operation, DateTime startTime) {
    final duration = DateTime.now().difference(startTime);
    AppLogger.d('⏱️ انتهاء العملية: $operation (${duration.inMilliseconds}ms)');
  }

  /// تسجيل معلومات المستخدم (بدون بيانات حساسة)
  static void logUserAction({
    required String userId,
    required String action,
    Map<String, dynamic>? metadata,
  }) {
    final userIdShort = userId.length > 8 ? userId.substring(0, 8) : userId;
    AppLogger.userAction(userIdShort, action);
    
    if (metadata != null) {
      AppLogger.d('معلومات إضافية: $metadata');
    }
  }

  /// تسجيل إحصائيات الأداء
  static void logPerformanceMetric({
    required String metric,
    required dynamic value,
    String? unit,
  }) {
    final unitText = unit != null ? ' $unit' : '';
    AppLogger.performanceMetric(metric, '$value$unitText');
  }

  /// تسجيل استخدام الذاكرة
  static void logMemoryUsage(String component, int memoryBytes) {
    final memoryMB = (memoryBytes / (1024 * 1024)).toStringAsFixed(2);
    AppLogger.memoryUsage(component, int.parse(memoryMB.split('.')[0]));
  }

  /// تسجيل جودة الاتصال
  static void logConnectionQuality({
    required String connectionType,
    required int latencyMs,
    required double bandwidthMbps,
  }) {
    AppLogger.networkQuality(connectionType, latencyMs);
    AppLogger.d('عرض النطاق: ${bandwidthMbps.toStringAsFixed(2)} Mbps');
  }

  /// تسجيل أحداث WebRTC
  static void logWebRTCEvent({
    required String event,
    required String peerId,
    Map<String, dynamic>? data,
  }) {
    AppLogger.media('WebRTC Event: $event for peer ${peerId.substring(0, 8)}...');
    
    if (data != null) {
      AppLogger.d('بيانات الحدث: $data');
    }
  }

  /// تسجيل إحصائيات الغرفة
  static void logRoomStats({
    required String roomId,
    required int participantCount,
    required int messageCount,
    Duration? duration,
  }) {
    final roomIdShort = roomId.substring(0, 8);
    AppLogger.room(
      'إحصائيات الغرفة $roomIdShort: $participantCount مشارك، $messageCount رسالة'
    );
    
    if (duration != null) {
      AppLogger.d('مدة الغرفة: ${duration.inMinutes} دقيقة');
    }
  }

  /// تسجيل أحداث الإشعارات
  static void logNotificationEvent({
    required String type,
    required String title,
    bool delivered = false,
  }) {
    final status = delivered ? 'تم التسليم' : 'تم الإرسال';
    AppLogger.notification('$type: $title - $status');
  }
}