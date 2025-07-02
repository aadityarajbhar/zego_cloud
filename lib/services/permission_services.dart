import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestCallPermissions() async {
    // Request basic permissions first
    Map<Permission, PermissionStatus> permissions = await [
      Permission.camera,
      Permission.microphone,
      Permission.notification,
      Permission.phone,
    ].request();

    // Check for system alert window permission separately
    bool systemAlertWindow =
        await Permission.systemAlertWindow.request().isGranted;

    // For Android 13+, request notification permission explicitly
    if (Platform.isAndroid) {
      var notificationPermission = await Permission.notification.request();
      if (notificationPermission.isDenied) {
        // Guide user to settings if needed
        await openAppSettings();
      }
    }

    bool allBasicGranted = permissions.values.every(
      (status) => status == PermissionStatus.granted,
    );

    return allBasicGranted && systemAlertWindow;
  }

  static Future<void> requestSystemAlertWindowPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.systemAlertWindow.request();
      if (status.isDenied) {
        // Open system settings for overlay permission
        await openAppSettings();
      }
    }
  }
}
