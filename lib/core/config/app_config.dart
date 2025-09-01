import 'package:flutter/foundation.dart';

/// تكوين التطبيق المركزي
class AppConfig {
  static AppConfig? _instance;
  static AppConfig get instance => _instance ??= AppConfig._();
  
  AppConfig._();

  // معلومات التطبيق
  static const String appName = 'لقاء شات';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';
  
  // إعدادات البيئة
  bool get isProduction => kReleaseMode;
  bool get isDevelopment => kDebugMode;
  bool get isProfile => kProfileMode;
  
  // URLs الخدمات
  String get supabaseUrl => const String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );
  
  String get supabaseAnonKey => const String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );
  
  String get openAIApiKey => const String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );
  
  String get geminiApiKey => const String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
  
  String get anthropicApiKey => const String.fromEnvironment(
    'ANTHROPIC_API_KEY',
    defaultValue: '',
  );
  
  String get perplexityApiKey => const String.fromEnvironment(
    'PERPLEXITY_API_KEY',
    defaultValue: '',
  );

  // إعدادات الشبكة
  Duration get connectionTimeout => Duration(seconds: 30);
  Duration get receiveTimeout => Duration(seconds: 30);
  int get maxRetryAttempts => 3;
  
  // إعدادات التخزين المؤقت
  Duration get cacheExpiry => Duration(hours: 24);
  int get maxCacheSize => 100 * 1024 * 1024; // 100MB
  
  // إعدادات الصوت والفيديو
  Map<String, dynamic> get audioConfig => {
    'sampleRate': 44100,
    'bitRate': 128000,
    'channels': 2,
    'format': 'aac',
  };
  
  Map<String, dynamic> get videoConfig => {
    'width': 1280,
    'height': 720,
    'frameRate': 30,
    'bitRate': 2000000,
    'codec': 'h264',
  };
  
  // إعدادات WebRTC
  List<Map<String, String>> get iceServers => [
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun1.l.google.com:19302'},
    {'urls': 'stun:stun2.l.google.com:19302'},
  ];
  
  // إعدادات الأمان
  bool get enableEncryption => isProduction;
  bool get enableLogging => isDevelopment;
  bool get enableAnalytics => isProduction;
  
  // حدود التطبيق
  int get maxRoomParticipants => 50;
  int get maxMessageLength => 1000;
  int get maxFileSize => 50 * 1024 * 1024; // 50MB
  
  // إعدادات الإشعارات
  Map<String, dynamic> get notificationConfig => {
    'channelId': 'leqaa_chat_notifications',
    'channelName': 'إشعارات لقاء شات',
    'channelDescription': 'إشعارات التطبيق العامة',
    'importance': 'high',
    'priority': 'high',
  };
  
  // إعدادات اللغة
  String get defaultLanguage => 'ar';
  List<String> get supportedLanguages => ['ar', 'en'];
  
  // إعدادات الواجهة
  Map<String, dynamic> get uiConfig => {
    'animationDuration': 300,
    'borderRadius': 12.0,
    'elevation': 2.0,
    'iconSize': 24.0,
  };
  
  // إعدادات الأداء
  Map<String, dynamic> get performanceConfig => {
    'enablePerformanceMonitoring': isDevelopment,
    'maxMemoryUsage': 512 * 1024 * 1024, // 512MB
    'gcThreshold': 100 * 1024 * 1024, // 100MB
  };

  /// التحقق من صحة التكوين
  bool validateConfig() {
    final errors = <String>[];
    
    if (supabaseUrl.isEmpty || supabaseUrl == 'https://your-project.supabase.co') {
      errors.add('SUPABASE_URL غير محدد');
    }
    
    if (supabaseAnonKey.isEmpty || supabaseAnonKey == 'your-anon-key') {
      errors.add('SUPABASE_ANON_KEY غير محدد');
    }
    
    if (errors.isNotEmpty) {
      debugPrint('أخطاء في التكوين: ${errors.join(', ')}');
      return false;
    }
    
    return true;
  }
  
  /// طباعة معلومات التكوين (للتطوير فقط)
  void printConfigInfo() {
    if (isDevelopment) {
      debugPrint('=== معلومات تكوين التطبيق ===');
      debugPrint('اسم التطبيق: $appName');
      debugPrint('الإصدار: $appVersion');
      debugPrint('رقم البناء: $buildNumber');
      debugPrint('البيئة: ${isProduction ? 'إنتاج' : 'تطوير'}');
      debugPrint('Supabase URL: ${supabaseUrl.substring(0, 20)}...');
      debugPrint('تفعيل التشفير: $enableEncryption');
      debugPrint('تفعيل التسجيل: $enableLogging');
      debugPrint('================================');
    }
  }
}