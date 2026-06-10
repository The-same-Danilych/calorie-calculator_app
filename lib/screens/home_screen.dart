import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import '../database/db_service.dart';
import '../models/diary_entry.dart';
import '../models/user.dart';
import '../services/diary_service.dart';
import '../services/user_service.dart';
import '../services/suggestion_service.dart';
import '../services/notification_service.dart';
import 'add_food_screen.dart';

/// Главный экран дневника с отображением прогресса и списком приёмов пищи.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DiaryService _diaryService = DiaryService();
  final UserService _userService = UserService();
  final SuggestionService _suggestionService = SuggestionService();
  User? _user;
  Map<String, dynamic>? _daySummary;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  bool _notificationsHandled = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _user = await _userService.getCurrentUser();
      if (_user != null) {
        _daySummary = await _diaryService.getDaySummary(
          _user!.id!,
          _selectedDate,
        );

        if (!_notificationsHandled) {
          _notificationsHandled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _requestNotificationsIfNeeded();
          });
        }
      }
    } catch (e) {
      debugPrint('Ошибка загрузки: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _requestNotificationsIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final asked = prefs.getBool('asked_notifications') ?? false;
      final status = await Permission.notification.status;

      if (status.isGranted) {
        final enabled = prefs.getBool('notifications_enabled') ?? true;
        if (enabled) {
          final hour = prefs.getInt('notification_hour') ?? 20;
          final minute = prefs.getInt('notification_minute') ?? 0;
          await NotificationService.scheduleDailyReminder(
            TimeOfDay(hour: hour, minute: minute),
          );
        }
        return;
      }

      if (!asked) {
        final result = await NotificationService.requestPermissions();
        await prefs.setBool('asked_notifications', true);
        if (result == PermissionStatus.granted) {
          final enabled = prefs.getBool('notifications_enabled') ?? true;
          if (enabled) {
            final hour = prefs.getInt('notification_hour') ?? 20;
            final minute = prefs.getInt('notification_minute') ?? 0;
            await NotificationService.scheduleDailyReminder(
              TimeOfDay(hour: hour, minute: minute),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Ошибка при настройке уведомлений: $e');
    }
  }

  void _refresh() {
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      });
      return const Scaffold(body: Center(child: Text('Ошибка')));
    }
    final totals =
        _daySummary?['totals'] ??
        {'calories': 0.0, 'protein': 0.0, 'fat': 0.0, 'carbs': 0.0};
    final meals = _daySummary?['meals'] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Дневник'),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              height: 80,
              color: Colors.green,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 16),
              child: const Text(
                'Меню',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Изменить профиль'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.pushNamed(context, '/edit_profile');
                _refresh();
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Анализ'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/analysis');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever),
              title: const Text('Удалить аккаунт'),
              onTap: () => _confirmDeleteAccount(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Настройки'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('О приложении'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about');
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProgressCard(totals),
              const SizedBox(height: 16),
              ...['breakfast', 'lunch', 'dinner', 'snack'].map(
                (mealType) =>
                    _buildMealSection(mealType, meals[mealType] ?? []),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(
            context,
            '/add_food',
            arguments: _selectedDate,
          );
          _refresh();
        },
        icon: const Icon(Icons.add),
        label: const Text('Добавить еду'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить аккаунт'),
        content: const Text(
          'Все данные будут удалены безвозвратно. Продолжить?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _deleteAccount();
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    if (_user != null) {
      await DatabaseService.instance.deleteUser(_user!.id!);
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/splash', (route) => false);
      }
    }
  }

  Widget _buildProgressCard(Map<String, double> totals) {
    final calGoal = _user!.calorieGoal;
    final proteinGoal = _user!.proteinGoal;
    final fatGoal = _user!.fatGoal;
    final carbGoal = _user!.carbGoal;

    final calPercent = calGoal > 0
        ? (totals['calories']! / calGoal).clamp(0.0, 1.0)
        : 0.0;
    final proteinPercent = proteinGoal > 0
        ? (totals['protein']! / proteinGoal).clamp(0.0, 1.0)
        : 0.0;
    final fatPercent = fatGoal > 0
        ? (totals['fat']! / fatGoal).clamp(0.0, 1.0)
        : 0.0;
    final carbsPercent = carbGoal > 0
        ? (totals['carbs']! / carbGoal).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: calPercent,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${totals['calories']!.toInt()} / ${calGoal.toInt()} ккал',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Осталось: ${max(0, calGoal - totals['calories']!).toInt()} ккал',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _suggestFoodToCoverRemaining(
                        (calGoal - totals['calories']!).toDouble(),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'Подобрать',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildLinearProgress(
              'Белки',
              totals['protein']!,
              proteinGoal,
              proteinPercent,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildLinearProgress(
              'Жиры',
              totals['fat']!,
              fatGoal,
              fatPercent,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildLinearProgress(
              'Углеводы',
              totals['carbs']!,
              carbGoal,
              carbsPercent,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinearProgress(
    String title,
    double current,
    double goal,
    double percent,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title: ${current.toInt()} / ${goal.toInt()} г'),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percent,
          backgroundColor: Colors.grey.shade300,
          color: color,
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildMealSection(String mealType, List<DiaryEntry> entries) {
    final Map<String, String> mealNames = {
      'breakfast': 'Завтрак',
      'lunch': 'Обед',
      'dinner': 'Ужин',
      'snack': 'Перекус',
    };
    final title = mealNames[mealType]!;
    final totalCal = entries.fold(0.0, (sum, e) => sum + e.calories);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text('$title (${totalCal.toInt()} ккал)'),
        children: entries.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Нет записей'),
                ),
              ]
            : entries.map((entry) => _buildEntryItem(entry)).toList(),
      ),
    );
  }

  Widget _buildEntryItem(DiaryEntry entry) {
    final food = entry.foodItem;
    final name = food?.name ?? 'Продукт';
    return ListTile(
      title: Text('$name — ${entry.grams.toInt()} г'),
      subtitle: Text(
        '${entry.calories.toInt()} ккал • '
        'Б:${entry.protein.toInt()} Ж:${entry.fat.toInt()} У:${entry.carbs.toInt()}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () => _editEntry(entry),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20),
            onPressed: () => _deleteEntry(entry.id!),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadData();
    }
  }

  void _editEntry(DiaryEntry entry) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddFoodScreen(key: UniqueKey(), entry: entry),
      ),
    );
    _refresh();
  }

  Future<void> _deleteEntry(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить запись?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _diaryService.deleteEntry(id);
      _refresh();
    }
  }

  Future<void> _suggestFoodToCoverRemaining(double remainingCalories) async {
    if (remainingCalories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Остаток калорий уже нулевой или отрицательный'),
        ),
      );
      return;
    }

    final suggestions = await _suggestionService.getSuggestions(
      remainingCalories,
    );
    if (suggestions.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Упс! Не удалось подобрать продукт. Попробуйте позже.',
            ),
          ),
        );
      }
      return;
    }

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Подберите продукт'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: suggestions.length,
            itemBuilder: (ctx, index) {
              final s = suggestions[index];
              return ListTile(
                title: Text(s.foodItem.name),
                subtitle: Text(
                  '${s.grams.toStringAsFixed(0)} г · ${s.calories.toStringAsFixed(0)} ккал',
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _addSuggestionToDiary(s);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }

  Future<void> _addSuggestionToDiary(Suggestion suggestion) async {
    final user = _user;
    if (user == null) return;

    final entry = DiaryEntry(
      userId: user.id!,
      foodItemId: suggestion.foodItem.id!,
      grams: suggestion.grams,
      mealType: 'snack',
      eatenAt: _selectedDate,
      calories: suggestion.calories,
      protein: (suggestion.grams / 100) * suggestion.foodItem.protein,
      fat: (suggestion.grams / 100) * suggestion.foodItem.fat,
      carbs: (suggestion.grams / 100) * suggestion.foodItem.carbs,
    );
    await _diaryService.addEntry(entry);
    _refresh();
  }
}
