import 'package:flutter/material.dart';

import '../database/db_service.dart';
import '../models/user.dart';
import '../services/mifflin_service.dart';
import '../services/user_service.dart';

/// Экран редактирования профиля (вес, рост, активность, цель).
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserService _userService = UserService();
  User? _user;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String _selectedActivity = 'moderate';
  String _selectedGoal = 'maintain';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    _user = await _userService.getCurrentUser();
    if (_user != null) {
      _weightController.text = _user!.weightKg.toString();
      _heightController.text = _user!.heightCm.toString();
      _selectedActivity = _user!.activity;
      _selectedGoal = _user!.goal;
      setState(() {});
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    if (_user == null) return;

    final newWeight = double.parse(_weightController.text);
    final newHeight = double.parse(_heightController.text);

    final newGoals = MifflinService.calculateGoals(
      gender: _user!.gender,
      weightKg: newWeight,
      heightCm: newHeight,
      age: _user!.years,
      activity: _selectedActivity,
      goal: _selectedGoal,
    );

    final updatedUser = User(
      id: _user!.id,
      name: _user!.name,
      gender: _user!.gender,
      years: _user!.years,
      heightCm: newHeight,
      weightKg: newWeight,
      activity: _selectedActivity,
      goal: _selectedGoal,
      calorieGoal: newGoals['calorie_goal']!,
      proteinGoal: newGoals['protein_goal']!,
      fatGoal: newGoals['fat_goal']!,
      carbGoal: newGoals['carb_goal']!,
    );

    await DatabaseService.instance.updateUser(updatedUser);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Профиль обновлён')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать профиль'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Вес (кг)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите вес';
                  final w = double.tryParse(value);
                  if (w == null || w < 20 || w > 500) {
                    return 'Вес от 20 до 500 кг';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(labelText: 'Рост (см)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите рост';
                  final h = double.tryParse(value);
                  if (h == null || h < 50 || h > 300) {
                    return 'Рост от 50 до 300 см';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Уровень активности',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _selectedActivity,
                items: const [
                  DropdownMenuItem(value: 'sedentary', child: Text('Сидячий')),
                  DropdownMenuItem(value: 'light', child: Text('Лёгкая')),
                  DropdownMenuItem(value: 'moderate', child: Text('Умеренная')),
                  DropdownMenuItem(value: 'active', child: Text('Высокая')),
                  DropdownMenuItem(value: 'very_active', child: Text('Экстремальная')),
                ],
                onChanged: (val) => setState(() => _selectedActivity = val!),
              ),
              const SizedBox(height: 20),
              const Text('Цель', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: _selectedGoal,
                items: const [
                  DropdownMenuItem(value: 'lose', child: Text('Снижение веса')),
                  DropdownMenuItem(value: 'maintain', child: Text('Поддержание')),
                  DropdownMenuItem(value: 'gain', child: Text('Набор массы')),
                ],
                onChanged: (val) => setState(() => _selectedGoal = val!),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: const Text(
                  'Сохранить',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}