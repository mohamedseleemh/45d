import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'app_logger.dart';

/// مراقب الأداء المتقدم للتطبيق
class AppPerformanceMonitor {
  static AppPerformanceMonitor? _instance;
  static AppPerformanceMonitor get instance => _instance ??= AppPerformanceMonitor._();
  
  AppPerformanceMonitor._();

  final Map<String, DateTime> _operationStartTimes = {};
  final Map<String, List<int>> _operationDurations = {};
  final List<PerformanceMetric> _metrics = [];
  
  Timer? _memoryMonitorTimer;
  Timer? _performanceReportTimer;

  /// بدء مراقبة الأداء
  void startMonitoring() {
    if (kDebugMode) {
      _startMemoryMonitoring();
      _startPerformanceReporting();
      AppLogger.performance('بدء مراقبة الأداء');
    }
  }

  /// إيقاف مراقبة الأداء
  void stopMonitoring() {
    _memoryMonitorTimer?.cancel();
    _performanceReportTimer?.cancel();
    AppLogger.performance('إيقاف مراقبة الأداء');
  }

  /// بدء مراقبة عملية
  void startOperation(String operationName) {
    _operationStartTimes[operationName] = DateTime.now();
    AppLogger.performance('بدء العملية: $operationName');
  }

  /// انتهاء مراقبة عملية
  void endOperation(String operationName) {
    final startTime = _operationStartTimes[operationName];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      final durationMs = duration.inMilliseconds;
      
      // حفظ مدة العملية
      _operationDurations.putIfAbsent(operationName, () => []);
      _operationDurations[operationName]!.add(durationMs);
      
      // إضافة مقياس الأداء
      _metrics.add(PerformanceMetric(
        name: operationName,
        value: durationMs.toDouble(),
        unit: 'ms',
        timestamp: DateTime.now(),
      ));
      
      _operationStartTimes.remove(operationName);
      AppLogger.performance('انتهاء العملية: $operationName (${durationMs}ms)');
      
      // تحذير إذا كانت العملية بطيئة
      if (durationMs > 1000) {
        AppLogger.w('عملية بطيئة: $operationName استغرقت ${durationMs}ms');
      }
    }
  }

  /// مراقبة استخدام الذاكرة
  void _startMemoryMonitoring() {
    _memoryMonitorTimer = Timer.periodic(Duration(seconds: 30), (timer) async {
      try {
        if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
          final memoryInfo = await _getMemoryInfo();
          _metrics.add(PerformanceMetric(
            name: 'memory_usage',
            value: memoryInfo['used']?.toDouble() ?? 0,
            unit: 'MB',
            timestamp: DateTime.now(),
          ));
          
          AppLogger.performance('استخدام الذاكرة: ${memoryInfo['used']}MB');
          
          // تحذير عند استخدام ذاكرة عالي
          if ((memoryInfo['used'] ?? 0) > 200) {
            AppLogger.w('استخدام ذاكرة عالي: ${memoryInfo['used']}MB');
          }
        }
      } catch (e) {
        AppLogger.e('خطأ في مراقبة الذاكرة', error: e);
      }
    });
  }

  /// تقرير الأداء الدوري
  void _startPerformanceReporting() {
    _performanceReportTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      _generatePerformanceReport();
    });
  }

  /// الحصول على معلومات الذاكرة
  Future<Map<String, int>> _getMemoryInfo() async {
    try {
      if (Platform.isAndroid) {
        final result = await Process.run('cat', ['/proc/meminfo']);
        final lines = result.stdout.toString().split('\n');
        
        int totalMemory = 0;
        int freeMemory = 0;
        
        for (final line in lines) {
          if (line.startsWith('MemTotal:')) {
            totalMemory = int.parse(line.split(RegExp(r'\s+'))[1]) ~/ 1024;
          } else if (line.startsWith('MemAvailable:')) {
            freeMemory = int.parse(line.split(RegExp(r'\s+'))[1]) ~/ 1024;
          }
        }
        
        return {
          'total': totalMemory,
          'free': freeMemory,
          'used': totalMemory - freeMemory,
        };
      }
    } catch (e) {
      AppLogger.e('فشل في الحصول على معلومات الذاكرة', error: e);
    }
    
    return {'total': 0, 'free': 0, 'used': 0};
  }

  /// إنشاء تقرير الأداء
  void _generatePerformanceReport() {
    if (_metrics.isEmpty) return;

    final report = StringBuffer();
    report.writeln('📊 تقرير الأداء:');
    report.writeln('================');
    
    // إحصائيات العمليات
    _operationDurations.forEach((operation, durations) {
      if (durations.isNotEmpty) {
        final avgDuration = durations.reduce((a, b) => a + b) / durations.length;
        final maxDuration = durations.reduce((a, b) => a > b ? a : b);
        final minDuration = durations.reduce((a, b) => a < b ? a : b);
        
        report.writeln('العملية: $operation');
        report.writeln('  متوسط الوقت: ${avgDuration.toStringAsFixed(2)}ms');
        report.writeln('  أقصى وقت: ${maxDuration}ms');
        report.writeln('  أقل وقت: ${minDuration}ms');
        report.writeln('  عدد التنفيذات: ${durations.length}');
        report.writeln('');
      }
    });

    // إحصائيات الذاكرة
    final memoryMetrics = _metrics.where((m) => m.name == 'memory_usage').toList();
    if (memoryMetrics.isNotEmpty) {
      final avgMemory = memoryMetrics.map((m) => m.value).reduce((a, b) => a + b) / memoryMetrics.length;
      final maxMemory = memoryMetrics.map((m) => m.value).reduce((a, b) => a > b ? a : b);
      
      report.writeln('استخدام الذاكرة:');
      report.writeln('  متوسط الاستخدام: ${avgMemory.toStringAsFixed(2)}MB');
      report.writeln('  أقصى استخدام: ${maxMemory.toStringAsFixed(2)}MB');
      report.writeln('');
    }

    AppLogger.performance(report.toString());
  }

  /// الحصول على إحصائيات العملية
  Map<String, dynamic> getOperationStats(String operationName) {
    final durations = _operationDurations[operationName] ?? [];
    
    if (durations.isEmpty) {
      return {'count': 0};
    }

    final avgDuration = durations.reduce((a, b) => a + b) / durations.length;
    final maxDuration = durations.reduce((a, b) => a > b ? a : b);
    final minDuration = durations.reduce((a, b) => a < b ? a : b);

    return {
      'count': durations.length,
      'average_ms': avgDuration,
      'max_ms': maxDuration,
      'min_ms': minDuration,
    };
  }

  /// الحصول على جميع المقاييس
  List<PerformanceMetric> getAllMetrics() {
    return List.from(_metrics);
  }

  /// مسح المقاييس القديمة
  void clearOldMetrics({Duration? olderThan}) {
    final cutoffTime = DateTime.now().subtract(olderThan ?? Duration(hours: 1));
    _metrics.removeWhere((metric) => metric.timestamp.isBefore(cutoffTime));
    
    AppLogger.performance('تم مسح المقاييس القديمة');
  }

  /// تسجيل مقياس مخصص
  void recordMetric({
    required String name,
    required double value,
    String unit = '',
  }) {
    _metrics.add(PerformanceMetric(
      name: name,
      value: value,
      unit: unit,
      timestamp: DateTime.now(),
    ));
    
    AppLogger.performanceMetric(name, value);
  }
}

/// نموذج مقياس الأداء
class PerformanceMetric {
  final String name;
  final double value;
  final String unit;
  final DateTime timestamp;

  const PerformanceMetric({
    required this.name,
    required this.value,
    required this.unit,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'unit': unit,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'PerformanceMetric(name: $name, value: $value$unit, timestamp: $timestamp)';
  }
}