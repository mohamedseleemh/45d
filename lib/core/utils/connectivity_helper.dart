import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

enum ConnectionType { none, mobile, wifi, ethernet, bluetooth, vpn, other }

class ConnectivityHelper {
  static ConnectivityHelper? _instance;
  static ConnectivityHelper get instance => _instance ??= ConnectivityHelper._();
  
  ConnectivityHelper._();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  final StreamController<ConnectionType> _connectionController = 
      StreamController<ConnectionType>.broadcast();

  Stream<ConnectionType> get connectionStream => _connectionController.stream;

  ConnectionType _currentConnectionType = ConnectionType.none;
  ConnectionType get currentConnectionType => _currentConnectionType;

  bool get isConnected => _currentConnectionType != ConnectionType.none;
  bool get isWifiConnected => _currentConnectionType == ConnectionType.wifi;
  bool get isMobileConnected => _currentConnectionType == ConnectionType.mobile;

  Future<void> initialize() async {
    try {
      // Check initial connectivity
      await _checkConnectivity();

      // Listen for connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _onConnectivityChanged,
        onError: (error) {
          if (kDebugMode) {
            print('❌ Connectivity stream error: $error');
          }
        },
      );

      if (kDebugMode) {
        print('✅ Connectivity helper initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Connectivity helper initialization failed: $e');
      }
    }
  }

  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _onConnectivityChanged(results);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Check connectivity failed: $e');
      }
      _updateConnectionType(ConnectionType.none);
    }
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      _updateConnectionType(ConnectionType.none);
      return;
    }

    // Take the first (primary) connection type
    final result = results.first;
    
    switch (result) {
      case ConnectivityResult.wifi:
        _updateConnectionType(ConnectionType.wifi);
        break;
      case ConnectivityResult.mobile:
        _updateConnectionType(ConnectionType.mobile);
        break;
      case ConnectivityResult.ethernet:
        _updateConnectionType(ConnectionType.ethernet);
        break;
      case ConnectivityResult.bluetooth:
        _updateConnectionType(ConnectionType.bluetooth);
        break;
      case ConnectivityResult.vpn:
        _updateConnectionType(ConnectionType.vpn);
        break;
      case ConnectivityResult.other:
        _updateConnectionType(ConnectionType.other);
        break;
      case ConnectivityResult.none:
      default:
        _updateConnectionType(ConnectionType.none);
        break;
    }
  }

  void _updateConnectionType(ConnectionType type) {
    if (_currentConnectionType != type) {
      _currentConnectionType = type;
      _connectionController.add(type);
      
      if (kDebugMode) {
        print('🔄 Connection type changed to: ${type.name}');
      }
    }
  }

  String getConnectionTypeInArabic() {
    switch (_currentConnectionType) {
      case ConnectionType.wifi:
        return 'واي فاي';
      case ConnectionType.mobile:
        return 'بيانات الجوال';
      case ConnectionType.ethernet:
        return 'إيثرنت';
      case ConnectionType.bluetooth:
        return 'بلوتوث';
      case ConnectionType.vpn:
        return 'في بي إن';
      case ConnectionType.other:
        return 'أخرى';
      case ConnectionType.none:
      default:
        return 'غير متصل';
    }
  }

  String getConnectionQualityMessage() {
    switch (_currentConnectionType) {
      case ConnectionType.wifi:
      case ConnectionType.ethernet:
        return 'اتصال ممتاز - جودة عالية';
      case ConnectionType.mobile:
        return 'اتصال جيد - قد تنخفض الجودة';
      case ConnectionType.bluetooth:
      case ConnectionType.other:
        return 'اتصال محدود - جودة منخفضة';
      case ConnectionType.vpn:
        return 'اتصال VPN - قد يكون بطيء';
      case ConnectionType.none:
      default:
        return 'لا يوجد اتصال بالإنترنت';
    }
  }

  // Check if connection is suitable for video calls
  bool isConnectionSuitableForVideo() {
    return _currentConnectionType == ConnectionType.wifi ||
           _currentConnectionType == ConnectionType.ethernet;
  }

  // Check if connection is suitable for voice calls
  bool isConnectionSuitableForVoice() {
    return _currentConnectionType != ConnectionType.none;
  }

  // Get recommended quality based on connection
  String getRecommendedQuality() {
    switch (_currentConnectionType) {
      case ConnectionType.wifi:
      case ConnectionType.ethernet:
        return 'high';
      case ConnectionType.mobile:
        return 'medium';
      case ConnectionType.bluetooth:
      case ConnectionType.other:
      case ConnectionType.vpn:
        return 'low';
      case ConnectionType.none:
      default:
        return 'none';
    }
  }

  Future<void> dispose() async {
    try {
      await _connectivitySubscription?.cancel();
      await _connectionController.close();
      
      if (kDebugMode) {
        print('✅ Connectivity helper disposed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Connectivity helper disposal failed: $e');
      }
    }
  }
}