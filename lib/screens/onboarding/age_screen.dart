import 'package:flutter/material.dart';

import 'app_state.dart';
import 'progress_header.dart';

/// Экран выбора возраста.
class AgeScreen extends StatefulWidget {
  const AgeScreen({super.key});

  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> {
  int? _selectedAge;

  Future<void> _showAgePicker() async {
    final int? picked = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Выберите возраст'),
          children: List.generate(106, (index) => index + 15).map((age) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, age),
              child: Text('$age лет'),
            );
          }).toList(),
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedAge = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ваш возраст'),
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
            ProgressHeader(currentStep: 2, totalSteps: totalOnboardingSteps),
            const SizedBox(height: 16),
            const Text(
              'Сколько вам полных лет?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            InkWell(
              onTap: _showAgePicker,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedAge == null
                          ? 'Нажмите, чтобы выбрать'
                          : '$_selectedAge лет',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedAge == null ? Colors.grey : Colors.black,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _selectedAge == null
                  ? null
                  : () {
                      AppState().onboardingData.years = _selectedAge;
                      Navigator.pushNamed(context, '/onboarding/body');
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