/// ثوابت التطبيق - تحتوي على جميع القيم الثابتة المستخدمة في التطبيق
class AppConstants {
  // معلومات التطبيق
  static const String appName = 'لقاء شات';
  static const String appNameEnglish = 'Leqaa Chat';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'تطبيق المحادثات الصوتية والمرئية';

  // إعدادات API
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;
  static const int retryDelaySeconds = 2;
  static const int connectionTimeoutSeconds = 10;

  // إعدادات الغرف
  static const int minParticipants = 2;
  static const int maxParticipants = 50;
  static const int defaultParticipantLimit = 10;
  static const int maxRoomNameLength = 50;
  static const int maxRoomDescriptionLength = 200;
  static const int roomInactivityTimeoutMinutes = 30;

  // إعدادات الرسائل
  static const int maxMessageLength = 1000;
  static const int messagesPerPage = 50;
  static const int maxChatHistory = 1000;
  static const int messageRetentionDays = 30;

  // إعدادات رفع الملفات
  static const int maxImageSizeMB = 5;
  static const int maxAudioSizeMB = 10;
  static const int maxVideoSizeMB = 50;
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedAudioFormats = ['mp3', 'wav', 'aac', 'm4a', 'ogg'];
  static const List<String> allowedVideoFormats = ['mp4', 'mov', 'avi', 'mkv', 'webm'];

  // إعدادات WebRTC
  static const List<Map<String, String>> iceServers = [
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun1.l.google.com:19302'},
    {'urls': 'stun:stun2.l.google.com:19302'},
    {'urls': 'stun:stun3.l.google.com:19302'},
  ];

  // إعدادات الصوت
  static const int audioSampleRate = 44100;
  static const int audioBitRate = 128000;
  static const int maxRecordingDurationMinutes = 10;
  static const int audioQualityLow = 64000;
  static const int audioQualityMedium = 128000;
  static const int audioQualityHigh = 256000;

  // إعدادات الفيديو
  static const int videoWidthLow = 640;
  static const int videoHeightLow = 480;
  static const int videoWidthMedium = 1280;
  static const int videoHeightMedium = 720;
  static const int videoWidthHigh = 1920;
  static const int videoHeightHigh = 1080;
  static const int videoFrameRate = 30;
  static const int videoBitRateLow = 500000; // 500 Kbps
  static const int videoBitRateMedium = 2000000; // 2 Mbps
  static const int videoBitRateHigh = 5000000; // 5 Mbps

  // إعدادات واجهة المستخدم
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double buttonHeight = 48.0;
  static const double iconSize = 24.0;
  static const double avatarSize = 40.0;
  static const double fabSize = 56.0;

  // مدد الأنيميشن
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  static const Duration overlayAutoHideDelay = Duration(seconds: 5);

  // إعدادات التخزين المؤقت
  static const int imageCacheMaxAge = 7; // أيام
  static const int dataCacheMaxAge = 1; // أيام
  static const int maxCacheSize = 100; // ميجابايت
  static const int preferencesUpdateInterval = 5; // ثواني

  // إعدادات الإشعارات
  static const String notificationChannelId = 'leqaa_chat_notifications';
  static const String notificationChannelName = 'إشعارات لقاء شات';
  static const String notificationChannelDescription = 'إشعارات التطبيق العامة';
  static const String messageChannelId = 'chat_messages';
  static const String messageChannelName = 'رسائل المحادثة';
  static const String invitationChannelId = 'room_invitations';
  static const String invitationChannelName = 'دعوات الغرف';

  // رسائل الأخطاء
  static const String networkErrorMessage = 'تحقق من اتصال الإنترنت وحاول مرة أخرى';
  static const String serverErrorMessage = 'حدث خطأ في الخادم، يرجى المحاولة لاحقاً';
  static const String unknownErrorMessage = 'حدث خطأ غير متوقع';
  static const String permissionDeniedMessage = 'الأذونات مطلوبة لاستخدام هذه الميزة';
  static const String authenticationErrorMessage = 'يرجى تسجيل الدخول أولاً';
  static const String roomFullErrorMessage = 'الغرفة ممتلئة، لا يمكن الانضمام';
  static const String roomNotFoundErrorMessage = 'الغرفة غير موجودة أو تم حذفها';

  // رسائل النجاح
  static const String roomCreatedMessage = 'تم إنشاء الغرفة بنجاح';
  static const String roomJoinedMessage = 'تم الانضمام للغرفة بنجاح';
  static const String roomLeftMessage = 'تم مغادرة الغرفة';
  static const String messageSentMessage = 'تم إرسال الرسالة';
  static const String profileUpdatedMessage = 'تم تحديث الملف الشخصي';
  static const String settingsSavedMessage = 'تم حفظ الإعدادات';

  // أنواع الغرف
  static const String roomTypeVoice = 'voice';
  static const String roomTypeVideo = 'video';
  static const String roomTypeBoth = 'both';

  // مستويات الخصوصية
  static const String privacyPublic = 'public';
  static const String privacyPrivate = 'private';
  static const String privacyInviteOnly = 'invite_only';

  // أدوار المستخدمين
  static const String roleOwner = 'owner';
  static const String roleModerator = 'moderator';
  static const String roleParticipant = 'participant';

  // أنواع الرسائل
  static const String messageTypeText = 'text';
  static const String messageTypeSystem = 'system';
  static const String messageTypeFile = 'file';
  static const String messageTypeAudio = 'audio';
  static const String messageTypeVideo = 'video';
  static const String messageTypeImage = 'image';

  // مفاتيح التفضيلات المحفوظة
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyAutoJoinAudio = 'auto_join_audio';
  static const String keyAutoJoinVideo = 'auto_join_video';
  static const String keyPreferredQuality = 'preferred_quality';

  // القيم الافتراضية
  static const String defaultLanguage = 'ar';
  static const String defaultThemeMode = 'light';
  static const bool defaultNotificationsEnabled = true;
  static const bool defaultAutoJoinAudio = true;
  static const bool defaultAutoJoinVideo = false;
  static const String defaultPreferredQuality = 'medium';

  // أنماط التحقق
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phonePattern = r'^\+?[1-9]\d{1,14}$';
  static const String urlPattern = r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';
  static const String arabicTextPattern = r'[\u0600-\u06FF]';

  // أعلام الميزات
  static const bool enableVoiceMessages = true;
  static const bool enableVideoMessages = true;
  static const bool enableFileSharing = true;
  static const bool enableScreenSharing = true;
  static const bool enableRoomRecording = true;
  static const bool enablePushNotifications = true;
  static const bool enableBackgroundMode = true;
  static const bool enableAutoReconnect = true;

  // حدود المعدل
  static const int maxMessagesPerMinute = 30;
  static const int maxRoomsPerUser = 10;
  static const int maxParticipantsPerRoom = 50;
  static const int maxInvitationsPerDay = 100;
  static const int maxReportsPerDay = 10;

  // عتبات جودة الاتصال
  static const int excellentConnectionMs = 50;
  static const int goodConnectionMs = 150;
  static const int fairConnectionMs = 300;
  static const int poorConnectionMs = 500;
  // أكثر من 500ms يعتبر اتصال سيء جداً

  // إعدادات الأمان
  static const int maxLoginAttempts = 5;
  static const int loginCooldownMinutes = 15;
  static const int sessionTimeoutHours = 24;
  static const int passwordMinLength = 8;
  static const int passwordMaxLength = 128;

  // إعدادات التسجيل
  static const int maxRecordingDurationHours = 4;
  static const String recordingFormat = 'mp4';
  static const int recordingQualityLow = 480;
  static const int recordingQualityMedium = 720;
  static const int recordingQualityHigh = 1080;

  // إعدادات الدعوات
  static const int invitationExpiryDays = 7;
  static const int maxPendingInvitations = 50;

  // إعدادات الحظر
  static const int maxBlockedUsers = 1000;
  static const int blockCooldownHours = 24;

  // أنواع الاتصال
  static const String connectionTypeWifi = 'wifi';
  static const String connectionTypeMobile = 'mobile';
  static const String connectionTypeEthernet = 'ethernet';
  static const String connectionTypeBluetooth = 'bluetooth';
  static const String connectionTypeVpn = 'vpn';
  static const String connectionTypeOther = 'other';
  static const String connectionTypeNone = 'none';

  // مستويات الجودة
  static const String qualityLow = 'low';
  static const String qualityMedium = 'medium';
  static const String qualityHigh = 'high';
  static const String qualityAuto = 'auto';

  // حالات الغرفة
  static const String roomStatusActive = 'active';
  static const String roomStatusInactive = 'inactive';
  static const String roomStatusFull = 'full';
  static const String roomStatusPrivate = 'private';

  // أنواع الأحداث
  static const String eventUserJoined = 'user_joined';
  static const String eventUserLeft = 'user_left';
  static const String eventUserMuted = 'user_muted';
  static const String eventUserUnmuted = 'user_unmuted';
  static const String eventRoomCreated = 'room_created';
  static const String eventRoomDeleted = 'room_deleted';
  static const String eventRoomUpdated = 'room_updated';

  // مسارات التخزين
  static const String audioRecordingsPath = 'audio_recordings';
  static const String videoRecordingsPath = 'video_recordings';
  static const String profileImagesPath = 'profile_images';
  static const String roomImagesPath = 'room_images';
  static const String tempFilesPath = 'temp_files';

  // إعدادات الأداء
  static const int maxConcurrentConnections = 10;
  static const int heartbeatIntervalSeconds = 30;
  static const int reconnectDelaySeconds = 5;
  static const int maxReconnectAttempts = 5;

  // إعدادات التطبيق المحلية
  static const String defaultLocale = 'ar_SA';
  static const String fallbackLocale = 'en_US';
  static const List<String> supportedLanguages = ['ar', 'en'];

  // أنماط التاريخ والوقت
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String isoDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";

  // إعدادات الذاكرة
  static const int maxMemoryUsageMB = 512;
  static const int imageCacheSize = 100;
  static const int videoCacheSize = 50;
  static const int audioCacheSize = 200;

  // إعدادات البطارية
  static const bool enableBatteryOptimization = true;
  static const int lowBatteryThreshold = 20;
  static const int criticalBatteryThreshold = 10;

  // إعدادات الشبكة
  static const int maxBandwidthMbps = 10;
  static const int minBandwidthKbps = 64;
  static const int networkQualityCheckInterval = 10; // ثواني

  // رسائل النظام
  static const String systemMessageUserJoined = 'انضم {user} إلى الغرفة';
  static const String systemMessageUserLeft = 'غادر {user} الغرفة';
  static const String systemMessageRoomCreated = 'تم إنشاء الغرفة';
  static const String systemMessageRoomEnded = 'تم إنهاء الغرفة';
  static const String systemMessageUserPromoted = 'تم ترقية {user} إلى مشرف';
  static const String systemMessageUserMuted = 'تم كتم {user}';
  static const String systemMessageUserUnmuted = 'تم إلغاء كتم {user}';

  // إعدادات الأمان المتقدمة
  static const bool enableEndToEndEncryption = true;
  static const bool enableDataEncryption = true;
  static const bool enableSecureStorage = true;
  static const int encryptionKeyLength = 256;

  // إعدادات التحليلات
  static const bool enableAnalytics = false; // معطل للخصوصية
  static const bool enableCrashReporting = true;
  static const bool enablePerformanceMonitoring = true;

  // حدود الاستخدام
  static const int maxDailyRoomCreations = 10;
  static const int maxDailyMessages = 1000;
  static const int maxDailyInvitations = 50;
  static const int maxSimultaneousRooms = 3;

  // إعدادات التطوير
  static const bool isDebugMode = true;
  static const bool enableVerboseLogging = true;
  static const bool enableNetworkLogging = false;
  static const bool enablePerformanceProfiling = false;

  /// الحصول على حد الجودة بناءً على نوع الاتصال
  static String getQualityForConnection(String connectionType) {
    switch (connectionType) {
      case connectionTypeWifi:
      case connectionTypeEthernet:
        return qualityHigh;
      case connectionTypeMobile:
        return qualityMedium;
      case connectionTypeBluetooth:
      case connectionTypeVpn:
        return qualityLow;
      default:
        return qualityAuto;
    }
  }

  /// الحصول على معدل البت للفيديو بناءً على الجودة
  static int getVideoBitRate(String quality) {
    switch (quality) {
      case qualityLow:
        return videoBitRateLow;
      case qualityMedium:
        return videoBitRateMedium;
      case qualityHigh:
        return videoBitRateHigh;
      default:
        return videoBitRateMedium;
    }
  }

  /// الحصول على معدل البت للصوت بناءً على الجودة
  static int getAudioBitRate(String quality) {
    switch (quality) {
      case qualityLow:
        return audioQualityLow;
      case qualityMedium:
        return audioQualityMedium;
      case qualityHigh:
        return audioQualityHigh;
      default:
        return audioQualityMedium;
    }
  }

  /// التحقق من صحة تنسيق الملف
  static bool isValidImageFormat(String extension) {
    return allowedImageFormats.contains(extension.toLowerCase());
  }

  static bool isValidAudioFormat(String extension) {
    return allowedAudioFormats.contains(extension.toLowerCase());
  }

  static bool isValidVideoFormat(String extension) {
    return allowedVideoFormats.contains(extension.toLowerCase());
  }
}