import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import 'app_logger.dart';

/// مساعد الأمان والتشفير للتطبيق
class SecurityHelper {
  static SecurityHelper? _instance;
  static SecurityHelper get instance => _instance ??= SecurityHelper._();
  
  SecurityHelper._();

  static const String _saltPrefix = 'leqaa_chat_';
  static const int _keyLength = 32;
  static const int _ivLength = 16;

  /// تشفير النص باستخدام AES
  String encryptText(String plainText, String password) {
    try {
      final key = _deriveKey(password);
      final iv = _generateIV();
      
      // في بيئة الإنتاج، استخدم مكتبة تشفير متقدمة
      // هذا مثال مبسط للتوضيح
      final encrypted = _simpleEncrypt(plainText, key, iv);
      
      AppLogger.d('تم تشفير النص بنجاح');
      return encrypted;
    } catch (e) {
      AppLogger.e('فشل في تشفير النص', error: e);
      rethrow;
    }
  }

  /// فك تشفير النص
  String decryptText(String encryptedText, String password) {
    try {
      final key = _deriveKey(password);
      
      // في بيئة الإنتاج، استخدم مكتبة فك تشفير متقدمة
      final decrypted = _simpleDecrypt(encryptedText, key);
      
      AppLogger.d('تم فك تشفير النص بنجاح');
      return decrypted;
    } catch (e) {
      AppLogger.e('فشل في فك تشفير النص', error: e);
      rethrow;
    }
  }

  /// إنشاء مفتاح من كلمة المرور
  Uint8List _deriveKey(String password) {
    final saltedPassword = _saltPrefix + password;
    final bytes = utf8.encode(saltedPassword);
    final digest = sha256.convert(bytes);
    return Uint8List.fromList(digest.bytes.take(_keyLength).toList());
  }

  /// إنشاء IV عشوائي
  Uint8List _generateIV() {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(_ivLength, (i) => random.nextInt(256))
    );
  }

  /// تشفير مبسط (للتوضيح فقط)
  String _simpleEncrypt(String plainText, Uint8List key, Uint8List iv) {
    // في الإنتاج، استخدم AES-256-GCM
    final bytes = utf8.encode(plainText);
    final encrypted = <int>[];
    
    for (int i = 0; i < bytes.length; i++) {
      encrypted.add(bytes[i] ^ key[i % key.length] ^ iv[i % iv.length]);
    }
    
    final combined = [...iv, ...encrypted];
    return base64.encode(combined);
  }

  /// فك تشفير مبسط (للتوضيح فقط)
  String _simpleDecrypt(String encryptedText, Uint8List key) {
    final combined = base64.decode(encryptedText);
    final iv = combined.take(_ivLength).toList();
    final encrypted = combined.skip(_ivLength).toList();
    
    final decrypted = <int>[];
    for (int i = 0; i < encrypted.length; i++) {
      decrypted.add(encrypted[i] ^ key[i % key.length] ^ iv[i % iv.length]);
    }
    
    return utf8.decode(decrypted);
  }

  /// تشفير البيانات الحساسة
  Map<String, String> encryptSensitiveData(Map<String, dynamic> data, String userKey) {
    final encrypted = <String, String>{};
    
    data.forEach((key, value) {
      if (_isSensitiveField(key)) {
        encrypted[key] = encryptText(value.toString(), userKey);
      } else {
        encrypted[key] = value.toString();
      }
    });
    
    return encrypted;
  }

  /// فك تشفير البيانات الحساسة
  Map<String, dynamic> decryptSensitiveData(Map<String, String> encryptedData, String userKey) {
    final decrypted = <String, dynamic>{};
    
    encryptedData.forEach((key, value) {
      if (_isSensitiveField(key)) {
        try {
          decrypted[key] = decryptText(value, userKey);
        } catch (e) {
          AppLogger.e('فشل في فك تشفير الحقل: $key', error: e);
          decrypted[key] = null;
        }
      } else {
        decrypted[key] = value;
      }
    });
    
    return decrypted;
  }

  /// التحقق من كون الحقل حساس
  bool _isSensitiveField(String fieldName) {
    const sensitiveFields = [
      'password',
      'token',
      'api_key',
      'secret',
      'private_key',
      'credit_card',
      'ssn',
      'phone',
      'address',
    ];
    
    return sensitiveFields.any((field) => 
      fieldName.toLowerCase().contains(field)
    );
  }

  /// إنشاء hash آمن للكلمة المرور
  String hashPassword(String password, String salt) {
    final saltedPassword = salt + password + _saltPrefix;
    final bytes = utf8.encode(saltedPassword);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// إنشاء salt عشوائي
  String generateSalt() {
    final random = Random.secure();
    final saltBytes = List.generate(32, (i) => random.nextInt(256));
    return base64.encode(saltBytes);
  }

  /// التحقق من قوة كلمة المرور
  PasswordStrength checkPasswordStrength(String password) {
    int score = 0;
    final checks = <String>[];

    // طول كلمة المرور
    if (password.length >= 8) {
      score += 1;
      checks.add('الطول مناسب');
    } else {
      checks.add('كلمة المرور قصيرة');
    }

    // وجود أحرف كبيرة
    if (password.contains(RegExp(r'[A-Z]'))) {
      score += 1;
      checks.add('تحتوي على أحرف كبيرة');
    } else {
      checks.add('تحتاج أحرف كبيرة');
    }

    // وجود أحرف صغيرة
    if (password.contains(RegExp(r'[a-z]'))) {
      score += 1;
      checks.add('تحتوي على أحرف صغيرة');
    } else {
      checks.add('تحتاج أحرف صغيرة');
    }

    // وجود أرقام
    if (password.contains(RegExp(r'[0-9]'))) {
      score += 1;
      checks.add('تحتوي على أرقام');
    } else {
      checks.add('تحتاج أرقام');
    }

    // وجود رموز خاصة
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      score += 1;
      checks.add('تحتوي على رموز خاصة');
    } else {
      checks.add('تحتاج رموز خاصة');
    }

    // تحديد مستوى القوة
    PasswordStrengthLevel level;
    if (score <= 2) {
      level = PasswordStrengthLevel.weak;
    } else if (score <= 3) {
      level = PasswordStrengthLevel.medium;
    } else if (score <= 4) {
      level = PasswordStrengthLevel.strong;
    } else {
      level = PasswordStrengthLevel.veryStrong;
    }

    return PasswordStrength(
      level: level,
      score: score,
      checks: checks,
    );
  }

  /// تنظيف البيانات من المحتوى الضار
  String sanitizeInput(String input) {
    // إزالة HTML tags
    String cleaned = input.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // إزالة JavaScript
    cleaned = cleaned.replaceAll(RegExp(r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>', caseSensitive: false), '');
    
    // إزالة SQL injection patterns
    cleaned = cleaned.replaceAll(RegExp(r'(\'|(\\\')|(\-\-)|(%27)|(%2D%2D))', caseSensitive: false), '');
    
    // تحديد طول النص
    if (cleaned.length > 1000) {
      cleaned = cleaned.substring(0, 1000);
    }
    
    return cleaned.trim();
  }

  /// التحقق من صحة URL
  bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// إنشاء token آمن
  String generateSecureToken({int length = 32}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// التحقق من صحة البريد الإلكتروني
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// التحقق من صحة رقم الهاتف
  bool isValidPhoneNumber(String phone) {
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phone);
  }

  /// فحص المحتوى للكلمات غير اللائقة
  bool containsProfanity(String content) {
    const profanityWords = [
      // قائمة الكلمات غير اللائقة (مخفية للخصوصية)
      'badword1', 'badword2', // أضف الكلمات المناسبة
    ];
    
    final lowerContent = content.toLowerCase();
    return profanityWords.any((word) => lowerContent.contains(word));
  }

  /// تنظيف المحتوى من الكلمات غير اللائقة
  String filterProfanity(String content) {
    String filtered = content;
    
    const profanityWords = [
      'badword1', 'badword2', // أضف الكلمات المناسبة
    ];
    
    for (final word in profanityWords) {
      final replacement = '*' * word.length;
      filtered = filtered.replaceAll(RegExp(word, caseSensitive: false), replacement);
    }
    
    return filtered;
  }

  /// إنشاء fingerprint للجهاز
  Future<String> getDeviceFingerprint() async {
    try {
      final deviceInfo = <String>[];
      
      if (!kIsWeb) {
        // معلومات الجهاز (بدون معلومات شخصية)
        deviceInfo.add(Platform.operatingSystem);
        deviceInfo.add(Platform.operatingSystemVersion);
      }
      
      // معلومات الشاشة
      deviceInfo.add(WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.toString());
      
      final combined = deviceInfo.join('|');
      final bytes = utf8.encode(combined);
      final digest = sha256.convert(bytes);
      
      return digest.toString().substring(0, 16);
    } catch (e) {
      AppLogger.e('فشل في إنشاء fingerprint الجهاز', error: e);
      return 'unknown_device';
    }
  }

  /// التحقق من سلامة البيانات
  bool verifyDataIntegrity(String data, String expectedHash) {
    final actualHash = sha256.convert(utf8.encode(data)).toString();
    return actualHash == expectedHash;
  }

  /// إنشاء hash للبيانات
  String createDataHash(String data) {
    return sha256.convert(utf8.encode(data)).toString();
  }
}

/// مستويات قوة كلمة المرور
enum PasswordStrengthLevel {
  weak,
  medium,
  strong,
  veryStrong,
}

/// نموذج قوة كلمة المرور
class PasswordStrength {
  final PasswordStrengthLevel level;
  final int score;
  final List<String> checks;

  const PasswordStrength({
    required this.level,
    required this.score,
    required this.checks,
  });

  String get levelText {
    switch (level) {
      case PasswordStrengthLevel.weak:
        return 'ضعيفة';
      case PasswordStrengthLevel.medium:
        return 'متوسطة';
      case PasswordStrengthLevel.strong:
        return 'قوية';
      case PasswordStrengthLevel.veryStrong:
        return 'قوية جداً';
    }
  }

  Color get levelColor {
    switch (level) {
      case PasswordStrengthLevel.weak:
        return const Color(0xFFE74C3C);
      case PasswordStrengthLevel.medium:
        return const Color(0xFFF39C12);
      case PasswordStrengthLevel.strong:
        return const Color(0xFF27AE60);
      case PasswordStrengthLevel.veryStrong:
        return const Color(0xFF2E7D5A);
    }
  }

  double get strengthPercentage {
    return (score / 5.0).clamp(0.0, 1.0);
  }
}