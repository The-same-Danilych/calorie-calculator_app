import 'package:flutter/material.dart';

import 'app_state.dart';
import 'progress_header.dart';

/// Экран ввода имени.
class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Имя'),
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
              ProgressHeader(currentStep: 0, totalSteps: totalOnboardingSteps),
              const SizedBox(height: 16),
              const Text(
                'Как к вам обращаться?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Имя',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Пожалуйста, введите ваше имя';
                  }
                  if (value.trim().length > 100) {
                    return 'Имя не должно превышать 100 символов';
                  }
                  return null;
                },
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    AppState().onboardingData.name = _nameController.text.trim();
                    Navigator.pushNamed(context, '/onboarding/gender');
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