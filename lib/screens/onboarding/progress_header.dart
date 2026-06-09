import 'package:flutter/material.dart';

/// Индикатор прогресса онбординга.
class ProgressHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProgressHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final value = currentStep / totalSteps;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: LinearProgressIndicator(
        value: value,
        backgroundColor: Colors.grey[300],
        color: Colors.black,
        minHeight: 8,
      ),
    );
  }
}