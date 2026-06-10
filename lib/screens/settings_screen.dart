import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
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

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  bool _notificationsEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadSettings();
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final status = await NotificationService.getPermissionStatus();
    final savedEnabled = prefs.getBool('notifications_enabled') ?? true;

    final actualEnabled = savedEnabled && status.isGranted;

    if (mounted) {
      setState(() {
        _notificationsEnabled = actualEnabled;
        final hour = prefs.getInt('notification_hour') ?? 20;
        final minute = prefs.getInt('notification_minute') ?? 0;
        _notificationTime = TimeOfDay(hour: hour, minute: minute);
      });
    }
  }

  Future<void> _saveNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value) {
      final status = await NotificationService.getPermissionStatus();

      if (status.isPermanentlyDenied) {
        if (mounted) {
          _showOpenSettingsDialog();
        }
        return;
      }

      if (!status.isGranted) {
        final granted = await NotificationService.requestPermissions();
        if (!granted) return;
      }

      await prefs.setBool('notifications_enabled', true);
      if (mounted) setState(() => _notificationsEnabled = true);
      await NotificationService.scheduleDailyReminder(_notificationTime);
    } else {
      await prefs.setBool('notifications_enabled', false);
      if (mounted) setState(() => _notificationsEnabled = false);
      await NotificationService.cancelAll();
    }
  }

  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Уведомления отключены'),
        content: const Text(
          'Вы ранее запретили уведомления. '
          'Чтобы включить их, откройте настройки приложения.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              NotificationService.openSettings();
            },
            child: const Text('Открыть настройки'),
          ),
        ],
      ),
    );
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
