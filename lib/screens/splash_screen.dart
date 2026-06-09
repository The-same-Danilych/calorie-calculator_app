import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/db_service.dart';
import '../models/food_item.dart';
import '../services/notification_service.dart';

/// Экран-заставка: инициализация БД, загрузка начальных продуктов, проверка пользователя.
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp(context);
    });
  }

  Future<void> _initializeApp(BuildContext context) async {
    await NotificationService.initialize();
    final db = DatabaseService.instance;
    final hasPreloaded = await db.hasPreloadedFoodItems();
    if (!hasPreloaded) {
      await _preloadFoodItems(db);
    }
    final user = await db.getUser();

    final prefs = await SharedPreferences.getInstance();
    final askedNotifications = prefs.getBool('asked_notifications') ?? false;
    if (!askedNotifications) {
      await NotificationService.requestPermissions();
      await prefs.setBool('asked_notifications', true);
      final enabled = prefs.getBool('notifications_enabled') ?? true;
      if (enabled) {
        final hour = prefs.getInt('notification_hour') ?? 20;
        final minute = prefs.getInt('notification_minute') ?? 0;
        await NotificationService.scheduleDailyReminder(
          TimeOfDay(hour: hour, minute: minute),
        );
      }
    }

    await Future.delayed(const Duration(seconds: 2));

    final disclaimerShown = prefs.getBool('disclaimer_shown') ?? false;
    if (!disclaimerShown) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Важное предупреждение'),
          content: const Text(
            'Приложение предоставляет оценочные расчёты калорий и БЖУ, '
            'основанные на общих формулах. Результаты могут отличаться '
            'от реальных потребностей вашего организма.\n\n'
            'Данное приложение не даёт медицинских рекомендаций и не заменяет '
            'консультацию врача или диетолога. Перед изменением рациона питания '
            'проконсультируйтесь со специалистом.\n\n'
            'Вся ответственность за использование приложения лежит на пользователе.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await prefs.setBool('disclaimer_shown', true);
                Navigator.pop(ctx);
              },
              child: const Text('Понятно'),
            ),
          ],
        ),
      );
    }

    if (mounted) {
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  Future<void> _preloadFoodItems(DatabaseService db) async {
    try {
      final jsonString = await rootBundle.loadString('seed_data/initial_food.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);

      final List<FoodItem> foodItems = [];
      for (var json in jsonList) {
        foodItems.add(
          FoodItem(
            name: json['name'],
            nameLower: json['name'].toLowerCase(),
            calories: (json['calories'] as num).toDouble(),
            protein: (json['protein'] as num).toDouble(),
            fat: (json['fat'] as num).toDouble(),
            carbs: (json['carbs'] as num).toDouble(),
            isCustom: json['is_custom'] ?? false,
          ),
        );
      }

      await db.insertFoodItemsBatch(foodItems);
      debugPrint('Загружено ${foodItems.length} продуктов');
    } catch (e) {
      debugPrint('Ошибка загрузки начальных продуктов: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final imageSize = screenSize.height * 0.1;

    return Scaffold(
      backgroundColor: Colors.green[700],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: imageSize,
              height: imageSize,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(imageSize * 0.3),
                child: Image.asset(
                  'images/boot_picture.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error, size: 100, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Как вы себя чувствуете?',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}