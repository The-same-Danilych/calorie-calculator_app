import 'package:flutter/material.dart';

import 'app_state.dart';
import 'progress_header.dart';

/// Экран ввода роста и веса.
class BodyScreen extends StatefulWidget {
  const BodyScreen({super.key});

  @override
  State<BodyScreen> createState() => _BodyScreenState();
}

class _BodyScreenState extends State<BodyScreen> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Рост и вес'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProgressHeader(currentStep: 3, totalSteps: totalOnboardingSteps),
              const SizedBox(height: 16),
              const Text(
                'Укажите пожалуйста ваш рост и вес',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(
                  labelText: 'Рост (см)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите рост';
                  final double? h = double.tryParse(value);
                  if (h == null) return 'Введите число';
                  if (h < 50 || h > 300) {
                    return 'Рост должен быть от 50 до 300 см';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Вес (кг)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите вес';
                  final double? w = double.tryParse(value);
                  if (w == null) return 'Введите число';
                  if (w < 20 || w > 500) {
                    return 'Вес должен быть от 20 до 500 кг';
                  }
                  return null;
                },
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    AppState().onboardingData.heightCm =
                        double.parse(_heightController.text);
                    AppState().onboardingData.weightKg =
                        double.parse(_weightController.text);
                    Navigator.pushNamed(context, '/onboarding/activity');
                  }
                },
                style: _buttonStyle(),
                child: const Text('Продолжить'),
              ),
            ],
          ),
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