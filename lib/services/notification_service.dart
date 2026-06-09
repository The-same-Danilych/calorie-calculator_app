import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

/// Сервис для локальных уведомлений.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    try {
      tz.initializeTimeZones();
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

  static Future<PermissionStatus> requestPermissions() async {
    final status = await Permission.notification.request();
    return status;
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
      ),
    );

    await _notifications.zonedSchedule(
      id: 0,
      title: 'Не забудьте про дневник!',
      body: 'Заполните сегодняшний рацион питания',
      scheduledDate: scheduled,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}