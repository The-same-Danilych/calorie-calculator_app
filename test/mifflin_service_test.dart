import 'package:flutter_test/flutter_test.dart';
import 'package:calorie_calculator_app/services/mifflin_service.dart';

void main() {
  group('MifflinService', () {
    group('calculateBMR', () {
      test('returns correct BMR for male', () {
        final bmr = MifflinService.calculateBMR(
          gender: 'male',
          weightKg: 80,
          heightCm: 180,
          age: 30,
        );
        expect(bmr, 1780.0);
      });

      test('returns correct BMR for female', () {
        final bmr = MifflinService.calculateBMR(
          gender: 'female',
          weightKg: 65,
          heightCm: 165,
          age: 25,
        );
        expect(bmr, 1395.25);
      });

      test('handles edge case: very low weight', () {
        final bmr = MifflinService.calculateBMR(
          gender: 'male',
          weightKg: 20,
          heightCm: 150,
          age: 18,
        );
        expect(bmr, greaterThan(0));
      });
    });

    group('calculateTDEE', () {
      test('returns TDEE for sedentary male', () {
        final tdee = MifflinService.calculateTDEE(
          gender: 'male',
          weightKg: 70,
          heightCm: 170,
          age: 30,
          activity: 'sedentary',
        );
        expect(tdee, closeTo(1938, 5));
      });

      test('returns TDEE for very active female', () {
        final tdee = MifflinService.calculateTDEE(
          gender: 'female',
          weightKg: 60,
          heightCm: 160,
          age: 28,
          activity: 'very_active',
        );
        expect(tdee, closeTo(2468, 10));
      });

      test('uses default multiplier for unknown activity', () {
        final tdee = MifflinService.calculateTDEE(
          gender: 'male',
          weightKg: 80,
          heightCm: 180,
          age: 30,
          activity: 'unknown',
        );
        expect(tdee, closeTo(2759, 5));
      });
    });

    group('calculateGoals', () {
      test('returns calorie goal not below minimum for female', () {
        final goals = MifflinService.calculateGoals(
          gender: 'female',
          weightKg: 50,
          heightCm: 150,
          age: 20,
          activity: 'sedentary',
          goal: 'lose',
        );
        expect(goals['calorie_goal'], 1200.0);
      });

      test('returns correct macros for male losing weight', () {
        final goals = MifflinService.calculateGoals(
          gender: 'male',
          weightKg: 100,
          heightCm: 180,
          age: 40,
          activity: 'moderate',
          goal: 'lose',
        );
        expect(goals['protein_goal'], greaterThan(100));
        expect(goals['fat_goal'], greaterThan(30));
        expect(goals['carb_goal'], greaterThan(150));
      });

      test('returns goals with one decimal place', () {
        final goals = MifflinService.calculateGoals(
          gender: 'female',
          weightKg: 55,
          heightCm: 165,
          age: 35,
          activity: 'light',
          goal: 'maintain',
        );
        expect(goals['calorie_goal'] is double, true);
        expect(
          goals['calorie_goal'].toString().split('.').last.length,
          lessThanOrEqualTo(1),
        );
      });
    });
  });
}
