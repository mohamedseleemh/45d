import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'app_logger.dart';

/// مدير التخزين المؤقت المتقدم
class CacheManager {
  static CacheManager? _instance;
  static CacheManager get instance => _instance ??= CacheManager._();
  
  CacheManager._();

  Directory? _cacheDirectory;
  final Map<String, CacheEntry> _memoryCache = {};
  final int _maxMemoryCacheSize = 50; // عدد العناصر
  final Duration _defaultExpiry = Duration(hours: 24);

  /// تهيئة مدير التخزين المؤقت
  Future<void> initialize() async {
    try {
      if (!kIsWeb) {
        _cacheDirectory = await getTemporaryDirectory();
        await _cleanExpiredCache();
      }
      AppLogger.i('تم تهيئة مدير التخزين المؤقت');
    } catch (e) {
      AppLogger.e('فشل في تهيئة مدير التخزين المؤقت', error: e);
    }
  }

  /// حفظ البيانات في التخزين المؤقت
  Future<void> put({
    required String key,
    required dynamic data,
    Duration? expiry,
    bool useMemoryCache = true,
    bool useDiskCache = true,
  }) async {
    try {
      final cacheEntry = CacheEntry(
        key: key,
        data: data,
        timestamp: DateTime.now(),
        expiry: expiry ?? _defaultExpiry,
      );

      // حفظ في الذاكرة
      if (useMemoryCache) {
        _memoryCache[key] = cacheEntry;
        _enforceMemoryCacheLimit();
      }

      // حفظ في القرص
      if (useDiskCache && !kIsWeb && _cacheDirectory != null) {
        await _saveToDisk(key, cacheEntry);
      }

      AppLogger.d('تم حفظ البيانات في التخزين المؤقت: $key');
    } catch (e) {
      AppLogger.e('فشل في حفظ البيانات في التخزين المؤقت', error: e);
    }
  }

  /// استرجاع البيانات من التخزين المؤقت
  Future<T?> get<T>(String key) async {
    try {
      // البحث في الذاكرة أولاً
      final memoryEntry = _memoryCache[key];
      if (memoryEntry != null && !memoryEntry.isExpired) {
        AppLogger.d('تم استرجاع البيانات من ذاكرة التخزين المؤقت: $key');
        return memoryEntry.data as T?;
      }

      // البحث في القرص
      if (!kIsWeb && _cacheDirectory != null) {
        final diskEntry = await _loadFromDisk(key);
        if (diskEntry != null && !diskEntry.isExpired) {
          // إضافة للذاكرة للوصول السريع
          _memoryCache[key] = diskEntry;
          AppLogger.d('تم استرجاع البيانات من قرص التخزين المؤقت: $key');
          return diskEntry.data as T?;
        }
      }

      AppLogger.d('البيانات غير موجودة في التخزين المؤقت: $key');
      return null;
    } catch (e) {
      AppLogger.e('فشل في استرجاع البيانات من التخزين المؤقت', error: e);
      return null;
    }
  }

  /// حذف البيانات من التخزين المؤقت
  Future<void> remove(String key) async {
    try {
      // حذف من الذاكرة
      _memoryCache.remove(key);

      // حذف من القرص
      if (!kIsWeb && _cacheDirectory != null) {
        final file = File('${_cacheDirectory!.path}/$key.cache');
        if (await file.exists()) {
          await file.delete();
        }
      }

      AppLogger.d('تم حذف البيانات من التخزين المؤقت: $key');
    } catch (e) {
      AppLogger.e('فشل في حذف البيانات من التخزين المؤقت', error: e);
    }
  }

  /// مسح جميع البيانات المؤقتة
  Future<void> clear() async {
    try {
      // مسح الذاكرة
      _memoryCache.clear();

      // مسح القرص
      if (!kIsWeb && _cacheDirectory != null) {
        final files = _cacheDirectory!.listSync();
        for (final file in files) {
          if (file.path.endsWith('.cache')) {
            await file.delete();
          }
        }
      }

      AppLogger.i('تم مسح جميع البيانات المؤقتة');
    } catch (e) {
      AppLogger.e('فشل في مسح البيانات المؤقتة', error: e);
    }
  }

  /// مسح البيانات المنتهية الصلاحية
  Future<void> _cleanExpiredCache() async {
    try {
      // تنظيف الذاكرة
      _memoryCache.removeWhere((key, entry) => entry.isExpired);

      // تنظيف القرص
      if (!kIsWeb && _cacheDirectory != null) {
        final files = _cacheDirectory!.listSync();
        for (final file in files) {
          if (file.path.endsWith('.cache')) {
            try {
              final entry = await _loadFromDisk(file.path.split('/').last.replaceAll('.cache', ''));
              if (entry != null && entry.isExpired) {
                await file.delete();
              }
            } catch (e) {
              // حذف الملفات التالفة
              await file.delete();
            }
          }
        }
      }

      AppLogger.d('تم تنظيف البيانات المنتهية الصلاحية');
    } catch (e) {
      AppLogger.e('فشل في تنظيف البيانات المنتهية الصلاحية', error: e);
    }
  }

  /// فرض حد الذاكرة المؤقتة
  void _enforceMemoryCacheLimit() {
    while (_memoryCache.length > _maxMemoryCacheSize) {
      // حذف أقدم عنصر
      final oldestKey = _memoryCache.keys.reduce((a, b) => 
        _memoryCache[a]!.timestamp.isBefore(_memoryCache[b]!.timestamp) ? a : b
      );
      _memoryCache.remove(oldestKey);
    }
  }

  /// حفظ في القرص
  Future<void> _saveToDisk(String key, CacheEntry entry) async {
    try {
      final file = File('${_cacheDirectory!.path}/$key.cache');
      final jsonData = jsonEncode(entry.toJson());
      await file.writeAsString(jsonData);
    } catch (e) {
      AppLogger.e('فشل في حفظ البيانات في القرص', error: e);
    }
  }

  /// تحميل من القرص
  Future<CacheEntry?> _loadFromDisk(String key) async {
    try {
      final file = File('${_cacheDirectory!.path}/$key.cache');
      if (await file.exists()) {
        final jsonData = await file.readAsString();
        final data = jsonDecode(jsonData);
        return CacheEntry.fromJson(data);
      }
    } catch (e) {
      AppLogger.e('فشل في تحميل البيانات من القرص', error: e);
    }
    return null;
  }

  /// الحصول على حجم التخزين المؤقت
  Future<int> getCacheSize() async {
    try {
      int totalSize = 0;

      if (!kIsWeb && _cacheDirectory != null) {
        final files = _cacheDirectory!.listSync();
        for (final file in files) {
          if (file is File && file.path.endsWith('.cache')) {
            final stat = await file.stat();
            totalSize += stat.size;
          }
        }
      }

      return totalSize;
    } catch (e) {
      AppLogger.e('فشل في حساب حجم التخزين المؤقت', error: e);
      return 0;
    }
  }

  /// الحصول على إحصائيات التخزين المؤقت
  Map<String, dynamic> getCacheStats() {
    return {
      'memory_cache_size': _memoryCache.length,
      'max_memory_cache_size': _maxMemoryCacheSize,
      'memory_cache_keys': _memoryCache.keys.toList(),
    };
  }
}

/// عنصر التخزين المؤقت
class CacheEntry {
  final String key;
  final dynamic data;
  final DateTime timestamp;
  final Duration expiry;

  const CacheEntry({
    required this.key,
    required this.data,
    required this.timestamp,
    required this.expiry,
  });

  bool get isExpired {
    return DateTime.now().isAfter(timestamp.add(expiry));
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'expiry_seconds': expiry.inSeconds,
    };
  }

  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      key: json['key'],
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
      expiry: Duration(seconds: json['expiry_seconds']),
    );
  }
}