import 'package:flutter/material.dart';

import 'app_state.dart';
import 'progress_header.dart';

/// Экран выбора физической активности.
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  String? _selectedActivity;

  final Map<String, String> activities = {
    'sedentary': 'Сидячий образ жизни (офисная работа, мало движения)',
    'light': 'Лёгкая активность (лёгкие упражнения 1-3 дня в неделю)',
    'moderate': 'Умеренная активность (спорт 3-5 дней в неделю)',
    'active': 'Высокая активность (интенсивные тренировки 6-7 дней)',
    'very_active': 'Экстремальная активность (физическая работа + спорт)',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Физическая активность'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProgressHeader(currentStep: 4, totalSteps: totalOnboardingSteps),
            const SizedBox(height: 16),
            const Text(
              'Ваша физическая активность',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Выберите уровень, который лучше всего описывает ваш образ жизни',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: RadioGroup<String>(
                groupValue: _selectedActivity,
                onChanged: (value) => setState(() => _selectedActivity = value),
                child: Column(
                  children: activities.entries.map((entry) {
                    return RadioListTile<String>(
                      title: Text(entry.value),
                      value: entry.key,
                      activeColor: Colors.green,
                    );
                  }).toList(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _selectedActivity == null
                  ? null
                  : () {
                      AppState().onboardingData.activity = _selectedActivity;
                      Navigator.pushNamed(context, '/onboarding/goal');
                    },
              style: _buttonStyle(),
              child: const Text('Продолжить'),
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 60),
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}