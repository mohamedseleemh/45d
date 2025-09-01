class AppConstants {
  // App Information
  static const String appName = 'لقاء شات';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'تطبيق المحادثات الصوتية والمرئية';

  // API Configuration
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;
  static const int retryDelaySeconds = 2;

  // Room Configuration
  static const int minParticipants = 2;
  static const int maxParticipants = 50;
  static const int defaultParticipantLimit = 10;
  static const int maxRoomNameLength = 50;
  static const int maxRoomDescriptionLength = 200;

  // Message Configuration
  static const int maxMessageLength = 1000;
  static const int messagesPerPage = 50;
  static const int maxChatHistory = 1000;

  // File Upload Configuration
  static const int maxImageSizeMB = 5;
  static const int maxAudioSizeMB = 10;
  static const int maxVideoSizeMB = 50;
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedAudioFormats = ['mp3', 'wav', 'aac', 'm4a'];
  static const List<String> allowedVideoFormats = ['mp4', 'mov', 'avi'];

  // WebRTC Configuration
  static const List<Map<String, String>> iceServers = [
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun1.l.google.com:19302'},
    {'urls': 'stun:stun2.l.google.com:19302'},
  ];

  // Audio Configuration
  static const int audioSampleRate = 44100;
  static const int audioBitRate = 128000;
  static const int maxRecordingDurationMinutes = 10;

  // Video Configuration
  static const int videoWidth = 1280;
  static const int videoHeight = 720;
  static const int videoFrameRate = 30;
  static const int videoBitRate = 2000000; // 2 Mbps

  // UI Configuration
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double buttonHeight = 48.0;
  static const double iconSize = 24.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Cache Configuration
  static const int imageCacheMaxAge = 7; // days
  static const int dataCacheMaxAge = 1; // days
  static const int maxCacheSize = 100; // MB

  // Notification Configuration
  static const String notificationChannelId = 'leqaa_chat_notifications';
  static const String notificationChannelName = 'إشعارات لقاء شات';
  static const String notificationChannelDescription = 'إشعارات التطبيق العامة';

  // Error Messages
  static const String networkErrorMessage = 'تحقق من اتصال الإنترنت وحاول مرة أخرى';
  static const String serverErrorMessage = 'حدث خطأ في الخادم، يرجى المحاولة لاحقاً';
  static const String unknownErrorMessage = 'حدث خطأ غير متوقع';
  static const String permissionDeniedMessage = 'الأذونات مطلوبة لاستخدام هذه الميزة';

  // Success Messages
  static const String roomCreatedMessage = 'تم إنشاء الغرفة بنجاح';
  static const String roomJoinedMessage = 'تم الانضمام للغرفة بنجاح';
  static const String messageSentMessage = 'تم إرسال الرسالة';
  static const String profileUpdatedMessage = 'تم تحديث الملف الشخصي';

  // Room Types
  static const String roomTypeVoice = 'voice';
  static const String roomTypeVideo = 'video';
  static const String roomTypeBoth = 'both';

  // Privacy Levels
  static const String privacyPublic = 'public';
  static const String privacyPrivate = 'private';
  static const String privacyInviteOnly = 'invite_only';

  // User Roles
  static const String roleOwner = 'owner';
  static const String roleModerator = 'moderator';
  static const String roleParticipant = 'participant';

  // Message Types
  static const String messageTypeText = 'text';
  static const String messageTypeSystem = 'system';
  static const String messageTypeFile = 'file';

  // Shared Preferences Keys
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyNotificationsEnabled = 'notifications_enabled';

  // Default Values
  static const String defaultLanguage = 'ar';
  static const bool defaultNotificationsEnabled = true;
  static const bool defaultDarkMode = false;

  // Validation Patterns
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phonePattern = r'^\+?[1-9]\d{1,14}$';
  static const String urlPattern = r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';

  // Feature Flags
  static const bool enableVoiceMessages = true;
  static const bool enableVideoMessages = true;
  static const bool enableFileSharing = true;
  static const bool enableScreenSharing = true;
  static const bool enableRoomRecording = true;
  static const bool enablePushNotifications = true;

  // Rate Limiting
  static const int maxMessagesPerMinute = 30;
  static const int maxRoomsPerUser = 10;
  static const int maxParticipantsPerRoom = 50;

  // Connection Quality Thresholds
  static const int excellentConnectionMs = 50;
  static const int goodConnectionMs = 150;
  static const int fairConnectionMs = 300;
  // Above 300ms is considered poor
}