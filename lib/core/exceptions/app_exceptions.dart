/// استثناءات التطبيق المخصصة
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}

/// استثناءات المصادقة
class AuthenticationException extends AppException {
  const AuthenticationException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
        );

  factory AuthenticationException.invalidCredentials() {
    return const AuthenticationException(
      message: 'بيانات تسجيل الدخول غير صحيحة',
      code: 'INVALID_CREDENTIALS',
    );
  }

  factory AuthenticationException.userNotFound() {
    return const AuthenticationException(
      message: 'المستخدم غير موجود',
      code: 'USER_NOT_FOUND',
    );
  }

  factory AuthenticationException.emailAlreadyExists() {
    return const AuthenticationException(
      message: 'البريد الإلكتروني مسجل مسبقاً',
      code: 'EMAIL_ALREADY_EXISTS',
    );
  }

  factory AuthenticationException.weakPassword() {
    return const AuthenticationException(
      message: 'كلمة المرور ضعيفة جداً',
      code: 'WEAK_PASSWORD',
    );
  }

  factory AuthenticationException.sessionExpired() {
    return const AuthenticationException(
      message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى',
      code: 'SESSION_EXPIRED',
    );
  }
}

/// استثناءات الغرف
class RoomException extends AppException {
  const RoomException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
        );

  factory RoomException.roomNotFound() {
    return const RoomException(
      message: 'الغرفة غير موجودة أو تم حذفها',
      code: 'ROOM_NOT_FOUND',
    );
  }

  factory RoomException.roomFull() {
    return const RoomException(
      message: 'الغرفة ممتلئة، لا يمكن الانضمام',
      code: 'ROOM_FULL',
    );
  }

  factory RoomException.accessDenied() {
    return const RoomException(
      message: 'ليس لديك صلاحية للوصول لهذه الغرفة',
      code: 'ACCESS_DENIED',
    );
  }

  factory RoomException.alreadyInRoom() {
    return const RoomException(
      message: 'أنت موجود في الغرفة بالفعل',
      code: 'ALREADY_IN_ROOM',
    );
  }

  factory RoomException.roomInactive() {
    return const RoomException(
      message: 'الغرفة غير نشطة حالياً',
      code: 'ROOM_INACTIVE',
    );
  }
}

/// استثناءات الشبكة
class NetworkException extends AppException {
  const NetworkException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
        );

  factory NetworkException.noConnection() {
    return const NetworkException(
      message: 'لا يوجد اتصال بالإنترنت',
      code: 'NO_CONNECTION',
    );
  }

  factory NetworkException.timeout() {
    return const NetworkException(
      message: 'انتهت مهلة الاتصال، حاول مرة أخرى',
      code: 'TIMEOUT',
    );
  }

  factory NetworkException.serverError() {
    return const NetworkException(
      message: 'خطأ في الخادم، يرجى المحاولة لاحقاً',
      code: 'SERVER_ERROR',
    );
  }

  factory NetworkException.badRequest() {
    return const NetworkException(
      message: 'طلب غير صحيح',
      code: 'BAD_REQUEST',
    );
  }

  factory NetworkException.unauthorized() {
    return const NetworkException(
      message: 'غير مخول للوصول',
      code: 'UNAUTHORIZED',
    );
  }
}

/// استثناءات الملفات
class FileException extends AppException {
  const FileException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
        );

  factory FileException.fileTooLarge() {
    return const FileException(
      message: 'حجم الملف كبير جداً',
      code: 'FILE_TOO_LARGE',
    );
  }

  factory FileException.invalidFormat() {
    return const FileException(
      message: 'تنسيق الملف غير مدعوم',
      code: 'INVALID_FORMAT',
    );
  }

  factory FileException.uploadFailed() {
    return const FileException(
      message: 'فشل في رفع الملف',
      code: 'UPLOAD_FAILED',
    );
  }

  factory FileException.fileNotFound() {
    return const FileException(
      message: 'الملف غير موجود',
      code: 'FILE_NOT_FOUND',
    );
  }
}

/// استثناءات الأذونات
class PermissionException extends AppException {
  const PermissionException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
        );

  factory PermissionException.cameraPermissionDenied() {
    return const PermissionException(
      message: 'إذن الكاميرا مطلوب لاستخدام هذه الميزة',
      code: 'CAMERA_PERMISSION_DENIED',
    );
  }

  factory PermissionException.microphonePermissionDenied() {
    return const PermissionException(
      message: 'إذن الميكروفون مطلوب لاستخدام هذه الميزة',
      code: 'MICROPHONE_PERMISSION_DENIED',
    );
  }

  factory PermissionException.storagePermissionDenied() {
    return const PermissionException(
      message: 'إذن التخزين مطلوب لحفظ الملفات',
      code: 'STORAGE_PERMISSION_DENIED',
    );
  }

  factory PermissionException.notificationPermissionDenied() {
    return const PermissionException(
      message: 'إذن الإشعارات مطلوب لتلقي التنبيهات',
      code: 'NOTIFICATION_PERMISSION_DENIED',
    );
  }
}

/// استثناءات الصوت والفيديو
class MediaException extends AppException {
  const MediaException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
        );

  factory MediaException.cameraInitializationFailed() {
    return const MediaException(
      message: 'فشل في تهيئة الكاميرا',
      code: 'CAMERA_INIT_FAILED',
    );
  }

  factory MediaException.microphoneInitializationFailed() {
    return const MediaException(
      message: 'فشل في تهيئة الميكروفون',
      code: 'MICROPHONE_INIT_FAILED',
    );
  }

  factory MediaException.recordingFailed() {
    return const MediaException(
      message: 'فشل في التسجيل',
      code: 'RECORDING_FAILED',
    );
  }

  factory MediaException.playbackFailed() {
    return const MediaException(
      message: 'فشل في التشغيل',
      code: 'PLAYBACK_FAILED',
    );
  }

  factory MediaException.webrtcConnectionFailed() {
    return const MediaException(
      message: 'فشل في الاتصال المباشر',
      code: 'WEBRTC_CONNECTION_FAILED',
    );
  }
}

/// استثناءات التخزين
class StorageException extends AppException {
  const StorageException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
        );

  factory StorageException.quotaExceeded() {
    return const StorageException(
      message: 'تم تجاوز حد التخزين المسموح',
      code: 'QUOTA_EXCEEDED',
    );
  }

  factory StorageException.accessDenied() {
    return const StorageException(
      message: 'ليس لديك صلاحية للوصول للتخزين',
      code: 'STORAGE_ACCESS_DENIED',
    );
  }

  factory StorageException.corruptedData() {
    return const StorageException(
      message: 'البيانات المحفوظة تالفة',
      code: 'CORRUPTED_DATA',
    );
  }
}

/// استثناءات التحقق من البيانات
class ValidationException extends AppException {
  final Map<String, String> fieldErrors;

  const ValidationException({
    required String message,
    this.fieldErrors = const {},
    String? code,
    dynamic originalError,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
        );

  factory ValidationException.invalidInput(Map<String, String> errors) {
    return ValidationException(
      message: 'البيانات المدخلة غير صحيحة',
      fieldErrors: errors,
      code: 'INVALID_INPUT',
    );
  }

  factory ValidationException.requiredFieldMissing(String fieldName) {
    return ValidationException(
      message: 'الحقل المطلوب مفقود: $fieldName',
      fieldErrors: {fieldName: 'هذا الحقل مطلوب'},
      code: 'REQUIRED_FIELD_MISSING',
    );
  }
}

/// استثناءات عامة للتطبيق
class GeneralException extends AppException {
  const GeneralException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
        );

  factory GeneralException.unknown() {
    return const GeneralException(
      message: 'حدث خطأ غير متوقع',
      code: 'UNKNOWN_ERROR',
    );
  }

  factory GeneralException.featureNotAvailable() {
    return const GeneralException(
      message: 'هذه الميزة غير متاحة حالياً',
      code: 'FEATURE_NOT_AVAILABLE',
    );
  }

  factory GeneralException.maintenanceMode() {
    return const GeneralException(
      message: 'التطبيق في وضع الصيانة، حاول لاحقاً',
      code: 'MAINTENANCE_MODE',
    );
  }
}