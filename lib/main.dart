import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_export.dart';
import '../core/providers/enhanced_app_state_provider.dart';
import '../core/services/audio_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/supabase_service.dart';
import '../core/services/webrtc_service.dart';
import '../core/utils/connectivity_helper.dart';
import '../core/utils/permission_handler.dart';
import '../core/utils/storage_helper.dart';
import '../core/utils/app_logger.dart';
import '../widgets/custom_error_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة نظام التسجيل
  AppLogger.setLogLevel(0); // Verbose في التطوير
  AppLogger.i('🚀 بدء تشغيل التطبيق');
  
  // Initialize core services
  await _initializeServices();

  bool _hasShownError = false;

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (!_hasShownError) {
      _hasShownError = true;

      // Reset flag after 3 seconds to allow error widget on new screens
      Future.delayed(Duration(seconds: 5), () {
        _hasShownError = false;
      });

      return CustomErrorWidget(
        errorDetails: details,
      );
    }
    return SizedBox.shrink();
  };

  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  ]).then((value) {
    runApp(MyApp());
  });
}

Future<void> _initializeServices() async {
  // Initialize Storage Helper
  try {
    await StorageHelper.instance.initialize();
    AppLogger.i('✅ تم تهيئة مساعد التخزين');
  } catch (e) {
    AppLogger.e('❌ فشل في تهيئة مساعد التخزين', error: e);
  }
  
  // Initialize Supabase
  try {
    await SupabaseService.instance.initialize();
    AppLogger.i('✅ تم تهيئة Supabase');
  } catch (e) {
    AppLogger.e('❌ فشل في تهيئة Supabase', error: e);
  }
  
  // Initialize WebRTC
  try {
    await WebRTCService.instance.initialize();
    AppLogger.i('✅ تم تهيئة WebRTC');
  } catch (e) {
    AppLogger.e('❌ فشل في تهيئة WebRTC', error: e);
  }

  // Initialize Audio Service
  try {
    await AudioService.instance.initialize();
    AppLogger.i('✅ تم تهيئة خدمة الصوت');
  } catch (e) {
    AppLogger.e('❌ فشل في تهيئة خدمة الصوت', error: e);
  }
  
  // Initialize Notification Service
  try {
    await NotificationService.instance.initialize();
    AppLogger.i('✅ تم تهيئة خدمة الإشعارات');
  } catch (e) {
    AppLogger.e('❌ فشل في تهيئة خدمة الإشعارات', error: e);
  }
  
  // Initialize Connectivity Helper
  try {
    await ConnectivityHelper.instance.initialize();
    AppLogger.i('✅ تم تهيئة مساعد الاتصال');
  } catch (e) {
    AppLogger.e('❌ فشل في تهيئة مساعد الاتصال', error: e);
  }
  
  // Request permissions
  try {
    await PermissionHandlerUtil.instance.requestAllPermissions();
    AppLogger.i('✅ تم طلب الأذونات');
  } catch (e) {
    AppLogger.e('❌ فشل في طلب الأذونات', error: e);
  }
  
  // Initialize app state
  try {
    await EnhancedAppStateProvider.instance.initialize();
    AppLogger.i('✅ تم تهيئة حالة التطبيق');
  } catch (e) {
    AppLogger.e('❌ فشل في تهيئة حالة التطبيق', error: e);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<EnhancedAppStateProvider>.value(
          value: EnhancedAppStateProvider.instance,
        ),
      ],
      child: Consumer<EnhancedAppStateProvider>(
        builder: (context, appState, child) {
          return Sizer(builder: (context, orientation, screenType) {
            return MaterialApp(
              title: 'leqaa_chat',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(1.0),
                  ),
                  child: child!,
                );
              },
              // 🚨 END CRITICAL SECTION
              debugShowCheckedModeBanner: false,
              routes: AppRoutes.routes,
              initialRoute: AppRoutes.initial,
            );
          });
        },
      ),
    );
  }
}
