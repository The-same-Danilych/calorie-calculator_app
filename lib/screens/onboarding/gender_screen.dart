import 'package:flutter/material.dart';

import 'app_state.dart';
import 'progress_header.dart';

/// Экран выбора пола.
class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  String? _selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ваш пол'),
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
            ProgressHeader(currentStep: 1, totalSteps: totalOnboardingSteps),
            const SizedBox(height: 16),
            const Text(
              'Выберите ваш пол',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            RadioGroup<String>(
              groupValue: _selectedGender,
              onChanged: (value) => setState(() => _selectedGender = value),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Мужской'),
                    value: 'male',
                    activeColor: Colors.green,
                  ),
                  RadioListTile<String>(
                    title: const Text('Женский'),
                    value: 'female',
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _selectedGender == null
                  ? null
                  : () {
                      AppState().onboardingData.gender = _selectedGender;
                      Navigator.pushNamed(context, '/onboarding/age');
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