import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_export.dart';
import '../core/providers/app_state_provider.dart';
import '../core/services/audio_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/supabase_service.dart';
import '../core/services/webrtc_service.dart';
import '../core/utils/connectivity_helper.dart';
import '../core/utils/permission_handler.dart';
import '../widgets/custom_error_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
  // Initialize Supabase
  try {
    await SupabaseService.instance.initialize();
  } catch (e) {
    print('Failed to initialize Supabase: $e');
  }
  
  // Initialize WebRTC
  try {
    await WebRTCService.instance.initialize();
  } catch (e) {
    print('Failed to initialize WebRTC: $e');
  }

  // Initialize Audio Service
  try {
    await AudioService.instance.initialize();
  } catch (e) {
    print('Failed to initialize Audio Service: $e');
  }
  
  // Initialize Notification Service
  try {
    await NotificationService.instance.initialize();
  } catch (e) {
    print('Failed to initialize Notification Service: $e');
  }
  
  // Initialize Connectivity Helper
  try {
    await ConnectivityHelper.instance.initialize();
  } catch (e) {
    print('Failed to initialize Connectivity Helper: $e');
  }
  
  // Request permissions
  try {
    await PermissionHandlerUtil.instance.requestAllPermissions();
  } catch (e) {
    print('Failed to request permissions: $e');
  }
  
  // Initialize app state
  try {
    await AppStateProvider.instance.initialize();
  } catch (e) {
    print('Failed to initialize app state: $e');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppStateProvider>.value(
          value: AppStateProvider.instance,
        ),
      ],
      child: Consumer<AppStateProvider>(
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
