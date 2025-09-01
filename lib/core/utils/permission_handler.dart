import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerUtil {
  static PermissionHandlerUtil? _instance;
  static PermissionHandlerUtil get instance => _instance ??= PermissionHandlerUtil._();
  
  PermissionHandlerUtil._();

  // Check if all required permissions are granted
  Future<bool> checkAllPermissions() async {
    if (kIsWeb) return true;

    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.notification,
    ];

    for (final permission in permissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        return false;
      }
    }

    return true;
  }

  // Request all required permissions
  Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    if (kIsWeb) {
      return {
        Permission.camera: PermissionStatus.granted,
        Permission.microphone: PermissionStatus.granted,
        Permission.notification: PermissionStatus.granted,
      };
    }

    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.notification,
    ];

    return await permissions.request();
  }

  // Check camera permission
  Future<bool> checkCameraPermission() async {
    if (kIsWeb) return true;
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  // Request camera permission
  Future<bool> requestCameraPermission() async {
    if (kIsWeb) return true;
    
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Check microphone permission
  Future<bool> checkMicrophonePermission() async {
    if (kIsWeb) return true;
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  // Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    if (kIsWeb) return true;
    
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  // Check notification permission
  Future<bool> checkNotificationPermission() async {
    if (kIsWeb) return true;
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  // Request notification permission
  Future<bool> requestNotificationPermission() async {
    if (kIsWeb) return true;
    
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // Check storage permission (for file uploads)
  Future<bool> checkStoragePermission() async {
    if (kIsWeb) return true;
    final status = await Permission.storage.status;
    return status.isGranted;
  }

  // Request storage permission
  Future<bool> requestStoragePermission() async {
    if (kIsWeb) return true;
    
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  // Check if permission is permanently denied
  Future<bool> isPermissionPermanentlyDenied(Permission permission) async {
    if (kIsWeb) return false;
    final status = await permission.status;
    return status.isPermanentlyDenied;
  }

  // Open app settings for permission management
  Future<bool> openAppSettings() async {
    if (kIsWeb) return false;
    return await openAppSettings();
  }

  // Get permission status message in Arabic
  String getPermissionStatusMessage(Permission permission, PermissionStatus status) {
    final permissionName = _getPermissionNameInArabic(permission);
    
    switch (status) {
      case PermissionStatus.granted:
        return 'تم منح إذن $permissionName';
      case PermissionStatus.denied:
        return 'تم رفض إذن $permissionName';
      case PermissionStatus.restricted:
        return 'إذن $permissionName مقيد';
      case PermissionStatus.limited:
        return 'إذن $permissionName محدود';
      case PermissionStatus.permanentlyDenied:
        return 'تم رفض إذن $permissionName نهائياً. يرجى تفعيله من الإعدادات';
      default:
        return 'حالة إذن $permissionName غير معروفة';
    }
  }

  String _getPermissionNameInArabic(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'الكاميرا';
      case Permission.microphone:
        return 'الميكروفون';
      case Permission.notification:
        return 'الإشعارات';
      case Permission.storage:
        return 'التخزين';
      case Permission.photos:
        return 'الصور';
      case Permission.location:
        return 'الموقع';
      default:
        return 'غير معروف';
    }
  }

  // Show permission rationale dialog
  Future<bool> showPermissionRationale({
    required BuildContext context,
    required Permission permission,
    required String reason,
  }) async {
    final permissionName = _getPermissionNameInArabic(permission);
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'إذن $permissionName مطلوب',
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        content: Text(
          reason,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'إلغاء',
              textDirection: TextDirection.rtl,
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'منح الإذن',
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    ) ?? false;
  }
}