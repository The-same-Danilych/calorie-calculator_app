import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/db_service.dart';
import '../services/notification_service.dart';
import '../services/food_preload_service.dart';

/// Экран-заставка: инициализация БД, загрузка начальных продуктов, проверка пользователя.
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _userName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp(context);
    });
  }

  Future<void> _initializeApp(BuildContext context) async {
    try {
      await NotificationService.initialize();
    } catch (e) {
      debugPrint('Notification init error: $e');
    }

    final db = DatabaseService.instance;

    FoodPreloadService().preloadIfNeeded();

    final user = await db.getUser();

    if (user != null && mounted) {
      setState(() {
        _userName = user.name;
      });
    }

    final prefs = await SharedPreferences.getInstance();
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

    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final imageSize = screenSize.height * 0.1;
    final greetingText = _userName == null
        ? 'Как вы себя чувствуете?'
        : 'Как вы себя чувствуете, $_userName?';

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
            Text(
              greetingText,
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
