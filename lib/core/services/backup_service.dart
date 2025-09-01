import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/app_logger.dart';
import '../utils/storage_helper.dart';
import '../config/app_config.dart';

/// خدمة النسخ الاحتياطي والاستعادة
class BackupService {
  static BackupService? _instance;
  static BackupService get instance => _instance ??= BackupService._();
  
  BackupService._();

  /// إنشاء نسخة احتياطية من بيانات المستخدم
  Future<String?> createBackup({
    required String userId,
    bool includeMessages = true,
    bool includeSettings = true,
    bool includeRoomHistory = true,
  }) async {
    try {
      AppLogger.i('بدء إنشاء النسخة الاحتياطية للمستخدم: $userId');

      final backupData = <String, dynamic>{
        'backup_version': '1.0',
        'app_version': AppConfig.appVersion,
        'created_at': DateTime.now().toIso8601String(),
        'user_id': userId,
      };

      // إضافة الإعدادات
      if (includeSettings) {
        backupData['user_preferences'] = StorageHelper.instance.getUserPreferences();
        backupData['notification_settings'] = StorageHelper.instance.getNotificationSettings();
        backupData['media_settings'] = StorageHelper.instance.getMediaSettings();
      }

      // إضافة تاريخ الغرف
      if (includeRoomHistory) {
        backupData['recent_rooms'] = StorageHelper.instance.getRecentRooms();
        backupData['favorite_rooms'] = StorageHelper.instance.getFavoriteRooms();
      }

      // إضافة إحصائيات الاستخدام
      backupData['usage_stats'] = StorageHelper.instance.getUsageStats();

      // تحويل لـ JSON
      final jsonString = jsonEncode(backupData);
      
      // حفظ النسخة الاحتياطية
      final backupPath = await _saveBackupToFile(userId, jsonString);
      
      AppLogger.i('تم إنشاء النسخة الاحتياطية بنجاح: $backupPath');
      return backupPath;
    } catch (e) {
      AppLogger.e('فشل في إنشاء النسخة الاحتياطية', error: e);
      return null;
    }
  }

  /// استعادة البيانات من النسخة الاحتياطية
  Future<bool> restoreBackup(String backupPath) async {
    try {
      AppLogger.i('بدء استعادة النسخة الاحتياطية من: $backupPath');

      // قراءة ملف النسخة الاحتياطية
      final backupContent = await _readBackupFile(backupPath);
      if (backupContent == null) {
        throw Exception('فشل في قراءة ملف النسخة الاحتياطية');
      }

      final backupData = jsonDecode(backupContent) as Map<String, dynamic>;
      
      // التحقق من صحة النسخة الاحتياطية
      if (!_validateBackup(backupData)) {
        throw Exception('ملف النسخة الاحتياطية غير صحيح');
      }

      // استعادة الإعدادات
      if (backupData.containsKey('user_preferences')) {
        await StorageHelper.instance.saveUserPreferences(
          Map<String, dynamic>.from(backupData['user_preferences'])
        );
      }

      if (backupData.containsKey('notification_settings')) {
        final notificationSettings = Map<String, dynamic>.from(backupData['notification_settings']);
        await StorageHelper.instance.saveNotificationSettings(
          enabled: notificationSettings['enabled'],
          soundEnabled: notificationSettings['sound_enabled'],
          vibrationEnabled: notificationSettings['vibration_enabled'],
          ringtone: notificationSettings['ringtone'],
        );
      }

      if (backupData.containsKey('media_settings')) {
        final mediaSettings = Map<String, dynamic>.from(backupData['media_settings']);
        await StorageHelper.instance.saveMediaSettings(
          preferredQuality: mediaSettings['preferred_quality'],
          autoJoinAudio: mediaSettings['auto_join_audio'],
          autoJoinVideo: mediaSettings['auto_join_video'],
          enableBackgroundBlur: mediaSettings['enable_background_blur'],
        );
      }

      // استعادة تاريخ الغرف
      if (backupData.containsKey('recent_rooms')) {
        await StorageHelper.instance.saveRecentRooms(
          List<String>.from(backupData['recent_rooms'])
        );
      }

      if (backupData.containsKey('favorite_rooms')) {
        await StorageHelper.instance.saveFavoriteRooms(
          List<String>.from(backupData['favorite_rooms'])
        );
      }

      // استعادة إحصائيات الاستخدام
      if (backupData.containsKey('usage_stats')) {
        final usageStats = Map<String, dynamic>.from(backupData['usage_stats']);
        await StorageHelper.instance.saveUsageStats(
          totalRoomsJoined: usageStats['total_rooms_joined'],
          totalMessagesSent: usageStats['total_messages_sent'],
          totalCallDurationMinutes: usageStats['total_call_duration_minutes'],
        );
      }

      AppLogger.i('تم استعادة النسخة الاحتياطية بنجاح');
      return true;
    } catch (e) {
      AppLogger.e('فشل في استعادة النسخة الاحتياطية', error: e);
      return false;
    }
  }

  /// الحصول على قائمة النسخ الاحتياطية المتاحة
  Future<List<BackupInfo>> getAvailableBackups(String userId) async {
    try {
      final backups = <BackupInfo>[];
      
      if (!kIsWeb) {
        final directory = await getApplicationDocumentsDirectory();
        final backupDir = Directory('${directory.path}/backups');
        
        if (await backupDir.exists()) {
          final files = backupDir.listSync();
          
          for (final file in files) {
            if (file is File && file.path.contains(userId) && file.path.endsWith('.backup')) {
              try {
                final content = await file.readAsString();
                final data = jsonDecode(content) as Map<String, dynamic>;
                
                backups.add(BackupInfo(
                  filePath: file.path,
                  createdAt: DateTime.parse(data['created_at']),
                  appVersion: data['app_version'],
                  fileSize: await file.length(),
                ));
              } catch (e) {
                AppLogger.w('ملف نسخة احتياطية تالف: ${file.path}');
              }
            }
          }
        }
      }

      // ترتيب حسب التاريخ (الأحدث أولاً)
      backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      AppLogger.i('تم العثور على ${backups.length} نسخة احتياطية');
      return backups;
    } catch (e) {
      AppLogger.e('فشل في جلب النسخ الاحتياطية', error: e);
      return [];
    }
  }

  /// حذف نسخة احتياطية
  Future<bool> deleteBackup(String backupPath) async {
    try {
      if (!kIsWeb) {
        final file = File(backupPath);
        if (await file.exists()) {
          await file.delete();
          AppLogger.i('تم حذف النسخة الاحتياطية: $backupPath');
          return true;
        }
      }
      return false;
    } catch (e) {
      AppLogger.e('فشل في حذف النسخة الاحتياطية', error: e);
      return false;
    }
  }

  /// حفظ النسخة الاحتياطية في ملف
  Future<String?> _saveBackupToFile(String userId, String jsonContent) async {
    try {
      if (kIsWeb) {
        // في الويب، يمكن تحميل الملف للمستخدم
        return null;
      }

      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');
      
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'backup_${userId}_$timestamp.backup';
      final file = File('${backupDir.path}/$fileName');
      
      await file.writeAsString(jsonContent);
      return file.path;
    } catch (e) {
      AppLogger.e('فشل في حفظ ملف النسخة الاحتياطية', error: e);
      return null;
    }
  }

  /// قراءة ملف النسخة الاحتياطية
  Future<String?> _readBackupFile(String filePath) async {
    try {
      if (kIsWeb) return null;

      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      AppLogger.e('فشل في قراءة ملف النسخة الاحتياطية', error: e);
      return null;
    }
  }

  /// التحقق من صحة النسخة الاحتياطية
  bool _validateBackup(Map<String, dynamic> backupData) {
    // التحقق من وجود الحقول الأساسية
    final requiredFields = ['backup_version', 'app_version', 'created_at', 'user_id'];
    
    for (final field in requiredFields) {
      if (!backupData.containsKey(field)) {
        AppLogger.w('حقل مطلوب مفقود في النسخة الاحتياطية: $field');
        return false;
      }
    }

    // التحقق من إصدار النسخة الاحتياطية
    final backupVersion = backupData['backup_version'] as String?;
    if (backupVersion != '1.0') {
      AppLogger.w('إصدار النسخة الاحتياطية غير مدعوم: $backupVersion');
      return false;
    }

    return true;
  }

  /// تنظيف النسخ الاحتياطية القديمة
  Future<void> cleanupOldBackups(String userId, {int keepCount = 5}) async {
    try {
      final backups = await getAvailableBackups(userId);
      
      if (backups.length > keepCount) {
        final backupsToDelete = backups.skip(keepCount);
        
        for (final backup in backupsToDelete) {
          await deleteBackup(backup.filePath);
        }
        
        AppLogger.i('تم حذف ${backupsToDelete.length} نسخة احتياطية قديمة');
      }
    } catch (e) {
      AppLogger.e('فشل في تنظيف النسخ الاحتياطية القديمة', error: e);
    }
  }

  /// إنشاء نسخة احتياطية تلقائية
  Future<void> createAutoBackup(String userId) async {
    try {
      // إنشاء نسخة احتياطية كل 7 أيام
      final lastBackupKey = 'last_auto_backup_$userId';
      final lastBackupTime = StorageHelper.instance.getString(lastBackupKey);
      
      if (lastBackupTime != null) {
        final lastBackup = DateTime.parse(lastBackupTime);
        final daysSinceLastBackup = DateTime.now().difference(lastBackup).inDays;
        
        if (daysSinceLastBackup < 7) {
          AppLogger.d('النسخة الاحتياطية التلقائية ليست مطلوبة بعد');
          return;
        }
      }

      final backupPath = await createBackup(userId: userId);
      if (backupPath != null) {
        await StorageHelper.instance.setString(
          lastBackupKey,
          DateTime.now().toIso8601String(),
        );
        
        // تنظيف النسخ القديمة
        await cleanupOldBackups(userId);
        
        AppLogger.i('تم إنشاء النسخة الاحتياطية التلقائية');
      }
    } catch (e) {
      AppLogger.e('فشل في إنشاء النسخة الاحتياطية التلقائية', error: e);
    }
  }
}

/// معلومات النسخة الاحتياطية
class BackupInfo {
  final String filePath;
  final DateTime createdAt;
  final String appVersion;
  final int fileSize;

  const BackupInfo({
    required this.filePath,
    required this.createdAt,
    required this.appVersion,
    required this.fileSize,
  });

  String get fileName => filePath.split('/').last;
  
  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '$fileSize بايت';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} كيلوبايت';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} ميجابايت';
    }
  }

  String get createdAtFormatted {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'منذ ${difference.inMinutes} دقيقة';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'file_path': filePath,
      'created_at': createdAt.toIso8601String(),
      'app_version': appVersion,
      'file_size': fileSize,
    };
  }

  factory BackupInfo.fromJson(Map<String, dynamic> json) {
    return BackupInfo(
      filePath: json['file_path'],
      createdAt: DateTime.parse(json['created_at']),
      appVersion: json['app_version'],
      fileSize: json['file_size'],
    );
  }
}