import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Сервис для запроса разрешений (уведомления, хранилище).
class PermissionService {
  static Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    List<Permission> permissions = [];

    permissions.add(Permission.notification);

    if (Platform.isAndroid) {
      if (await _isAndroidVersionAtLeast33()) {
        permissions.add(Permission.photos);
      } else {
        permissions.add(Permission.storage);
      }
    }

    Map<Permission, PermissionStatus> statuses = await permissions.request();
    return statuses;
  }

  static Future<bool> _isAndroidVersionAtLeast33() async {
    if (!Platform.isAndroid) return false;
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt >= 33;
  }

  static Future<bool> areAllPermissionsGranted() async {
    bool notificationsGranted = await Permission.notification.isGranted;
    bool photosGranted = false;

    if (Platform.isAndroid) {
      if (await _isAndroidVersionAtLeast33()) {
        photosGranted = await Permission.photos.isGranted;
      } else {
        photosGranted = await Permission.storage.isGranted;
      }
    }

    return notificationsGranted && photosGranted;
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}