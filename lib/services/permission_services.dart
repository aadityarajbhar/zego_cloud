import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionService {
  static const String _permissionStorageKey = 'permissions_granted';

  static Future<bool> requestCallPermissions() async {
    // Check if permissions were already granted
    final prefs = await SharedPreferences.getInstance();
    bool permissionsAlreadyGranted =
        prefs.getBool(_permissionStorageKey) ?? false;

    if (permissionsAlreadyGranted) {
      // Still check critical permissions that might have been revoked
      bool systemAlertWindow = await Permission.systemAlertWindow.isGranted;
      if (!systemAlertWindow) {
        systemAlertWindow =
            await Permission.systemAlertWindow.request().isGranted;
      }
      return systemAlertWindow;
    }

    // Request all permissions for first time
    Map<Permission, PermissionStatus> permissions = await [
      Permission.camera,
      Permission.microphone,
      Permission.notification,
      Permission.phone,
    ].request();

    // Request system alert window separately (most critical for background calling)
    bool systemAlertWindow =
        await Permission.systemAlertWindow.request().isGranted;

    // For Android 13+, request notification permission explicitly
    if (Platform.isAndroid) {
      var notificationPermission = await Permission.notification.status;
      if (notificationPermission.isDenied) {
        notificationPermission = await Permission.notification.request();
        if (notificationPermission.isDenied) {
          await openAppSettings();
        }
      }
    }

    bool allBasicGranted = permissions.values.every(
      (status) => status == PermissionStatus.granted,
    );

    bool allPermissionsGranted = allBasicGranted && systemAlertWindow;

    // Store permission status
    if (allPermissionsGranted) {
      await prefs.setBool(_permissionStorageKey, true);
    }

    return allPermissionsGranted;
  }

  static Future<void> openSystemSettings() async {
    await openAppSettings();
  }
}
