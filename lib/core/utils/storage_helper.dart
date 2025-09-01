import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import 'app_logger.dart';

/// مساعد التخزين المحلي - يدير حفظ واسترجاع البيانات محلياً
class StorageHelper {
  static StorageHelper? _instance;
  static StorageHelper get instance => _instance ??= StorageHelper._();
  
  StorageHelper._();

  SharedPreferences? _prefs;

  /// تهيئة التخزين المحلي
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      AppLogger.i('تم تهيئة التخزين المحلي بنجاح');
    } catch (e) {
      AppLogger.e('فشل في تهيئة التخزين المحلي', error: e);
      rethrow;
    }
  }

  /// حفظ نص
  Future<bool> setString(String key, String value) async {
    try {
      final result = await _prefs?.setString(key, value) ?? false;
      if (result) {
        AppLogger.d('تم حفظ النص: $key');
      }
      return result;
    } catch (e) {
      AppLogger.e('فشل في حفظ النص: $key', error: e);
      return false;
    }
  }

  /// استرجاع نص
  String? getString(String key, {String? defaultValue}) {
    try {
      final value = _prefs?.getString(key) ?? defaultValue;
      if (value != null) {
        AppLogger.d('تم استرجاع النص: $key');
      }
      return value;
    } catch (e) {
      AppLogger.e('فشل في استرجاع النص: $key', error: e);
      return defaultValue;
    }
  }

  /// حفظ رقم صحيح
  Future<bool> setInt(String key, int value) async {
    try {
      final result = await _prefs?.setInt(key, value) ?? false;
      if (result) {
        AppLogger.d('تم حفظ الرقم: $key = $value');
      }
      return result;
    } catch (e) {
      AppLogger.e('فشل في حفظ الرقم: $key', error: e);
      return false;
    }
  }

  /// استرجاع رقم صحيح
  int getInt(String key, {int defaultValue = 0}) {
    try {
      final value = _prefs?.getInt(key) ?? defaultValue;
      AppLogger.d('تم استرجاع الرقم: $key = $value');
      return value;
    } catch (e) {
      AppLogger.e('فشل في استرجاع الرقم: $key', error: e);
      return defaultValue;
    }
  }

  /// حفظ رقم عشري
  Future<bool> setDouble(String key, double value) async {
    try {
      final result = await _prefs?.setDouble(key, value) ?? false;
      if (result) {
        AppLogger.d('تم حفظ الرقم العشري: $key = $value');
      }
      return result;
    } catch (e) {
      AppLogger.e('فشل في حفظ الرقم العشري: $key', error: e);
      return false;
    }
  }

  /// استرجاع رقم عشري
  double getDouble(String key, {double defaultValue = 0.0}) {
    try {
      final value = _prefs?.getDouble(key) ?? defaultValue;
      AppLogger.d('تم استرجاع الرقم العشري: $key = $value');
      return value;
    } catch (e) {
      AppLogger.e('فشل في استرجاع الرقم العشري: $key', error: e);
      return defaultValue;
    }
  }

  /// حفظ قيمة منطقية
  Future<bool> setBool(String key, bool value) async {
    try {
      final result = await _prefs?.setBool(key, value) ?? false;
      if (result) {
        AppLogger.d('تم حفظ القيمة المنطقية: $key = $value');
      }
      return result;
    } catch (e) {
      AppLogger.e('فشل في حفظ القيمة المنطقية: $key', error: e);
      return false;
    }
  }

  /// استرجاع قيمة منطقية
  bool getBool(String key, {bool defaultValue = false}) {
    try {
      final value = _prefs?.getBool(key) ?? defaultValue;
      AppLogger.d('تم استرجاع القيمة المنطقية: $key = $value');
      return value;
    } catch (e) {
      AppLogger.e('فشل في استرجاع القيمة المنطقية: $key', error: e);
      return defaultValue;
    }
  }

  /// حفظ قائمة نصوص
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      final result = await _prefs?.setStringList(key, value) ?? false;
      if (result) {
        AppLogger.d('تم حفظ قائمة النصوص: $key (${value.length} عنصر)');
      }
      return result;
    } catch (e) {
      AppLogger.e('فشل في حفظ قائمة النصوص: $key', error: e);
      return false;
    }
  }

  /// استرجاع قائمة نصوص
  List<String> getStringList(String key, {List<String>? defaultValue}) {
    try {
      final value = _prefs?.getStringList(key) ?? defaultValue ?? [];
      AppLogger.d('تم استرجاع قائمة النصوص: $key (${value.length} عنصر)');
      return value;
    } catch (e) {
      AppLogger.e('فشل في استرجاع قائمة النصوص: $key', error: e);
      return defaultValue ?? [];
    }
  }

  /// حفظ كائن JSON
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      final result = await setString(key, jsonString);
      if (result) {
        AppLogger.d('تم حفظ كائن JSON: $key');
      }
      return result;
    } catch (e) {
      AppLogger.e('فشل في حفظ كائن JSON: $key', error: e);
      return false;
    }
  }

  /// استرجاع كائن JSON
  Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;
      
      final value = jsonDecode(jsonString) as Map<String, dynamic>;
      AppLogger.d('تم استرجاع كائن JSON: $key');
      return value;
    } catch (e) {
      AppLogger.e('فشل في استرجاع كائن JSON: $key', error: e);
      return null;
    }
  }

  /// حفظ قائمة كائنات JSON
  Future<bool> setJsonList(String key, List<Map<String, dynamic>> value) async {
    try {
      final jsonString = jsonEncode(value);
      final result = await setString(key, jsonString);
      if (result) {
        AppLogger.d('تم حفظ قائمة JSON: $key (${value.length} عنصر)');
      }
      return result;
    } catch (e) {
      AppLogger.e('فشل في حفظ قائمة JSON: $key', error: e);
      return false;
    }
  }

  /// استرجاع قائمة كائنات JSON
  List<Map<String, dynamic>> getJsonList(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return [];
      
      final value = jsonDecode(jsonString) as List;
      final result = value.cast<Map<String, dynamic>>();
      AppLogger.d('تم استرجاع قائمة JSON: $key (${result.length} عنصر)');
      return result;
    } catch (e) {
      AppLogger.e('فشل في استرجاع قائمة JSON: $key', error: e);
      return [];
    }
  }

  /// التحقق من وجود مفتاح
  bool containsKey(String key) {
    try {
      final exists = _prefs?.containsKey(key) ?? false;
      AppLogger.d('التحقق من وجود المفتاح: $key = $exists');
      return exists;
    } catch (e) {
      AppLogger.e('فشل في التحقق من وجود المفتاح: $key', error: e);
      return false;
    }
  }

  /// حذف مفتاح
  Future<bool> remove(String key) async {
    try {
      final result = await _prefs?.remove(key) ?? false;
      if (result) {
        AppLogger.d('تم حذف المفتاح: $key');
      }
      return result;
    } catch (e) {
      AppLogger.e('فشل في حذف المفتاح: $key', error: e);
      return false;
    }
  }

  /// مسح جميع البيانات
  Future<bool> clear() async {
    try {
      final result = await _prefs?.clear() ?? false;
      if (result) {
        AppLogger.i('تم مسح جميع البيانات المحفوظة');
      }
      return result;
    } catch (e) {
      AppLogger.e('فشل في مسح البيانات', error: e);
      return false;
    }
  }

  /// الحصول على جميع المفاتيح
  Set<String> getAllKeys() {
    try {
      final keys = _prefs?.getKeys() ?? <String>{};
      AppLogger.d('تم استرجاع جميع المفاتيح: ${keys.length} مفتاح');
      return keys;
    } catch (e) {
      AppLogger.e('فشل في استرجاع المفاتيح', error: e);
      return <String>{};
    }
  }

  /// حفظ تفضيلات المستخدم
  Future<bool> saveUserPreferences(Map<String, dynamic> preferences) async {
    return await setJson('user_preferences', preferences);
  }

  /// استرجاع تفضيلات المستخدم
  Map<String, dynamic> getUserPreferences() {
    return getJson('user_preferences') ?? {};
  }

  /// حفظ بيانات الجلسة
  Future<bool> saveSessionData({
    required String userId,
    required String email,
    String? fullName,
    String? avatarUrl,
  }) async {
    final sessionData = {
      'user_id': userId,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'saved_at': DateTime.now().toIso8601String(),
    };
    
    return await setJson('session_data', sessionData);
  }

  /// استرجاع بيانات الجلسة
  Map<String, dynamic>? getSessionData() {
    return getJson('session_data');
  }

  /// مسح بيانات الجلسة
  Future<bool> clearSessionData() async {
    return await remove('session_data');
  }

  /// حفظ إعدادات الصوت والفيديو
  Future<bool> saveMediaSettings({
    String? preferredQuality,
    bool? autoJoinAudio,
    bool? autoJoinVideo,
    bool? enableBackgroundBlur,
  }) async {
    final settings = {
      'preferred_quality': preferredQuality,
      'auto_join_audio': autoJoinAudio,
      'auto_join_video': autoJoinVideo,
      'enable_background_blur': enableBackgroundBlur,
      'updated_at': DateTime.now().toIso8601String(),
    };

    return await setJson('media_settings', settings);
  }

  /// استرجاع إعدادات الصوت والفيديو
  Map<String, dynamic> getMediaSettings() {
    return getJson('media_settings') ?? {
      'preferred_quality': 'medium',
      'auto_join_audio': true,
      'auto_join_video': false,
      'enable_background_blur': false,
    };
  }

  /// حفظ آخر الغرف المستخدمة
  Future<bool> saveRecentRooms(List<String> roomIds) async {
    // الاحتفاظ بآخر 10 غرف فقط
    final recentRooms = roomIds.take(10).toList();
    return await setStringList('recent_rooms', recentRooms);
  }

  /// استرجاع آخر الغرف المستخدمة
  List<String> getRecentRooms() {
    return getStringList('recent_rooms');
  }

  /// إضافة غرفة للقائمة الحديثة
  Future<bool> addRecentRoom(String roomId) async {
    final recentRooms = getRecentRooms();
    
    // إزالة الغرفة إن كانت موجودة مسبقاً
    recentRooms.remove(roomId);
    
    // إضافة الغرفة في المقدمة
    recentRooms.insert(0, roomId);
    
    return await saveRecentRooms(recentRooms);
  }

  /// حفظ الغرف المفضلة
  Future<bool> saveFavoriteRooms(List<String> roomIds) async {
    return await setStringList('favorite_rooms', roomIds);
  }

  /// استرجاع الغرف المفضلة
  List<String> getFavoriteRooms() {
    return getStringList('favorite_rooms');
  }

  /// إضافة/إزالة غرفة من المفضلة
  Future<bool> toggleFavoriteRoom(String roomId) async {
    final favoriteRooms = getFavoriteRooms();
    
    if (favoriteRooms.contains(roomId)) {
      favoriteRooms.remove(roomId);
    } else {
      favoriteRooms.add(roomId);
    }
    
    return await saveFavoriteRooms(favoriteRooms);
  }

  /// التحقق من كون الغرفة مفضلة
  bool isRoomFavorite(String roomId) {
    return getFavoriteRooms().contains(roomId);
  }

  /// حفظ إحصائيات الاستخدام
  Future<bool> saveUsageStats({
    int? totalRoomsJoined,
    int? totalMessagesSent,
    int? totalCallDurationMinutes,
    DateTime? lastActiveDate,
  }) async {
    final currentStats = getUsageStats();
    
    final updatedStats = {
      'total_rooms_joined': totalRoomsJoined ?? currentStats['total_rooms_joined'] ?? 0,
      'total_messages_sent': totalMessagesSent ?? currentStats['total_messages_sent'] ?? 0,
      'total_call_duration_minutes': totalCallDurationMinutes ?? currentStats['total_call_duration_minutes'] ?? 0,
      'last_active_date': (lastActiveDate ?? DateTime.now()).toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    return await setJson('usage_stats', updatedStats);
  }

  /// استرجاع إحصائيات الاستخدام
  Map<String, dynamic> getUsageStats() {
    return getJson('usage_stats') ?? {
      'total_rooms_joined': 0,
      'total_messages_sent': 0,
      'total_call_duration_minutes': 0,
      'last_active_date': DateTime.now().toIso8601String(),
    };
  }

  /// تحديث عداد الغرف المنضم إليها
  Future<bool> incrementRoomsJoined() async {
    final stats = getUsageStats();
    final currentCount = stats['total_rooms_joined'] as int? ?? 0;
    return await saveUsageStats(totalRoomsJoined: currentCount + 1);
  }

  /// تحديث عداد الرسائل المرسلة
  Future<bool> incrementMessagesSent() async {
    final stats = getUsageStats();
    final currentCount = stats['total_messages_sent'] as int? ?? 0;
    return await saveUsageStats(totalMessagesSent: currentCount + 1);
  }

  /// تحديث مدة المكالمات
  Future<bool> addCallDuration(int durationMinutes) async {
    final stats = getUsageStats();
    final currentDuration = stats['total_call_duration_minutes'] as int? ?? 0;
    return await saveUsageStats(totalCallDurationMinutes: currentDuration + durationMinutes);
  }

  /// حفظ إعدادات الإشعارات
  Future<bool> saveNotificationSettings({
    bool? enabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? ringtone,
  }) async {
    final settings = {
      'enabled': enabled,
      'sound_enabled': soundEnabled,
      'vibration_enabled': vibrationEnabled,
      'ringtone': ringtone,
      'updated_at': DateTime.now().toIso8601String(),
    };

    return await setJson('notification_settings', settings);
  }

  /// استرجاع إعدادات الإشعارات
  Map<String, dynamic> getNotificationSettings() {
    return getJson('notification_settings') ?? {
      'enabled': true,
      'sound_enabled': true,
      'vibration_enabled': true,
      'ringtone': 'default',
    };
  }

  /// حفظ آخر موقع للمستخدم في التطبيق
  Future<bool> saveLastAppState({
    String? lastRoute,
    String? lastRoomId,
    Map<String, dynamic>? additionalData,
  }) async {
    final appState = {
      'last_route': lastRoute,
      'last_room_id': lastRoomId,
      'additional_data': additionalData,
      'saved_at': DateTime.now().toIso8601String(),
    };

    return await setJson('last_app_state', appState);
  }

  /// استرجاع آخر حالة للتطبيق
  Map<String, dynamic>? getLastAppState() {
    return getJson('last_app_state');
  }

  /// مسح البيانات المؤقتة
  Future<bool> clearTempData() async {
    try {
      final keysToRemove = [
        'temp_room_data',
        'temp_message_drafts',
        'temp_media_files',
        'temp_upload_queue',
      ];

      bool allSuccess = true;
      for (final key in keysToRemove) {
        final success = await remove(key);
        if (!success) allSuccess = false;
      }

      if (allSuccess) {
        AppLogger.i('تم مسح البيانات المؤقتة');
      }
      
      return allSuccess;
    } catch (e) {
      AppLogger.e('فشل في مسح البيانات المؤقتة', error: e);
      return false;
    }
  }

  /// الحصول على حجم البيانات المحفوظة (تقديري)
  int getStorageSize() {
    try {
      final keys = getAllKeys();
      int totalSize = 0;

      for (final key in keys) {
        final value = getString(key);
        if (value != null) {
          totalSize += value.length;
        }
      }

      AppLogger.d('حجم البيانات المحفوظة: ${(totalSize / 1024).toStringAsFixed(2)} KB');
      return totalSize;
    } catch (e) {
      AppLogger.e('فشل في حساب حجم البيانات', error: e);
      return 0;
    }
  }
}