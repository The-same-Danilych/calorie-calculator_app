import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart'
    hide openAppSettings;
import 'package:permission_handler/permission_handler.dart' as ph;

/// Сервис для локальных уведомлений.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    try {
      tz.initializeTimeZones();
      _setLocalTimezone();

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
      );
      await _notifications.initialize(settings: settings);
    } catch (e) {
      debugPrint('Notify init error: $e');
    }
  }

  static void _setLocalTimezone() {
    try {
      final offsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
      final locations = tz.timeZoneDatabase.locations;
      tz.Location? match;

      for (final loc in locations.values) {
        try {
          final tzLoc = tz.getLocation(loc.name);
          final now = tz.TZDateTime.now(tzLoc);
          if (now.timeZoneOffset.inMinutes == offsetMinutes) {
            match = tzLoc;
            break;
          }
        } catch (_) {
          continue;
        }
      }

      if (match != null) {
        tz.setLocalLocation(match);
        debugPrint('Timezone set to: ${match.name}');
      }
    } catch (e) {
      debugPrint('Timezone detection error: $e');
    }
  }

  static Future<bool> requestPermissions() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<PermissionStatus> getPermissionStatus() async {
    return await Permission.notification.status;
  }

  static Future<void> openSettings() async {
    await ph.openAppSettings();
  }

  static Future<void> scheduleDailyReminder(TimeOfDay time) async {
    await cancelAll();

    final now = DateTime.now();

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reminder',
        'Ежедневное напоминание',
        channelDescription: 'Напоминание о заполнении дневника питания',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@drawable/notification_icon',
      ),
    );

    await _notifications.zonedSchedule(
      id: 0,
      title: 'Напоминание',
      body: 'Не забудьте заполнить сегодняшний рацион питания',
      scheduledDate: scheduled,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    debugPrint(
      'Notification scheduled for ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
    );
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
