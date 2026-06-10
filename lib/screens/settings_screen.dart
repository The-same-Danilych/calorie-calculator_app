import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notification_service.dart';
import '../theme_provider.dart';

/// Экран настроек: тёмная тема, уведомления, время напоминания.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        final hour = prefs.getInt('notification_hour') ?? 20;
        final minute = prefs.getInt('notification_minute') ?? 0;
        _notificationTime = TimeOfDay(hour: hour, minute: minute);
      });
    }
  }

  Future<void> _saveNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    if (mounted) setState(() => _notificationsEnabled = value);
    if (value) {
      await NotificationService.scheduleDailyReminder(_notificationTime);
    } else {
      await NotificationService.cancelAll();
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
    );
    if (newTime != null && mounted) {
      setState(() => _notificationTime = newTime);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('notification_hour', newTime.hour);
      await prefs.setInt('notification_minute', newTime.minute);
      if (_notificationsEnabled) {
        await NotificationService.scheduleDailyReminder(newTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Тёмная тема'),
            subtitle: const Text('Меняется сразу'),
            value: themeProvider.isDarkMode,
            onChanged: (_) => themeProvider.toggleTheme(),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Уведомления'),
            subtitle: const Text('Напоминание заполнить дневник'),
            value: _notificationsEnabled,
            onChanged: _saveNotificationsEnabled,
          ),
          if (_notificationsEnabled)
            ListTile(
              title: const Text('Время уведомления'),
              subtitle: Text(
                '${_notificationTime.hour}:${_notificationTime.minute.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.access_time),
              onTap: _selectTime,
            ),
        ],
      ),
    );
  }
}