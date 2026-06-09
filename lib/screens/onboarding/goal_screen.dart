import 'package:flutter/material.dart';

import '../../database/db_service.dart';
import '../../models/user.dart';
import '../../services/mifflin_service.dart';
import 'app_state.dart';
import 'progress_header.dart';

/// Экран выбора цели (снижение/поддержание/набор массы).
class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  String? _selectedGoal;

  final Map<String, String> goals = {
    'lose': 'Снижение веса',
    'maintain': 'Поддержание веса',
    'gain': 'Набор массы',
  };

  Future<void> _saveUserAndFinish() async {
    final data = AppState().onboardingData;
    if (data.name == null ||
        data.gender == null ||
        data.years == null ||
        data.heightCm == null ||
        data.weightKg == null ||
        data.activity == null ||
        _selectedGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля')),
      );
      return;
    }

    final goalsMap = MifflinService.calculateGoals(
      gender: data.gender!,
      weightKg: data.weightKg!,
      heightCm: data.heightCm!,
      age: data.years!,
      activity: data.activity!,
      goal: _selectedGoal!,
    );

    final user = User(
      name: data.name!,
      gender: data.gender!,
      years: data.years!,
      heightCm: data.heightCm!,
      weightKg: data.weightKg!,
      activity: data.activity!,
      goal: _selectedGoal!,
      calorieGoal: goalsMap['calorie_goal']!,
      proteinGoal: goalsMap['protein_goal']!,
      fatGoal: goalsMap['fat_goal']!,
      carbGoal: goalsMap['carb_goal']!,
    );

    final db = DatabaseService.instance;
    await db.insertUser(user);
    AppState().resetOnboarding();

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ваша цель'),
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
            ProgressHeader(currentStep: 5, totalSteps: totalOnboardingSteps),
            const SizedBox(height: 16),
            const Text(
              'Ваша цель',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Чего вы хотите достичь?',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: RadioGroup<String>(
                groupValue: _selectedGoal,
                onChanged: (value) => setState(() => _selectedGoal = value),
                child: Column(
                  children: goals.entries.map((entry) {
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
              onPressed: _selectedGoal == null ? null : _saveUserAndFinish,
              style: _buttonStyle(),
              child: const Text('Завершить'),
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