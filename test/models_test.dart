import 'package:flutter_test/flutter_test.dart';
import 'package:calorie_calculator_app/models/user.dart';
import 'package:calorie_calculator_app/models/food_item.dart';
import 'package:calorie_calculator_app/models/diary_entry.dart';

void main() {
  group('User', () {
    test('toMap and fromMap are consistent', () {
      final original = User(
        id: 1,
        name: 'Алексей',
        gender: 'male',
        years: 30,
        heightCm: 180.0,
        weightKg: 80.0,
        activity: 'moderate',
        goal: 'maintain',
        calorieGoal: 2500.0,
        proteinGoal: 150.0,
        fatGoal: 55.0,
        carbGoal: 300.0,
      );
      final map = original.toMap();
      final restored = User.fromMap(map);
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.gender, original.gender);
      expect(restored.years, original.years);
      expect(restored.heightCm, original.heightCm);
      expect(restored.weightKg, original.weightKg);
      expect(restored.activity, original.activity);
      expect(restored.goal, original.goal);
      expect(restored.calorieGoal, original.calorieGoal);
      expect(restored.proteinGoal, original.proteinGoal);
      expect(restored.fatGoal, original.fatGoal);
      expect(restored.carbGoal, original.carbGoal);
    });
  });

  group('FoodItem', () {
    test('toMap and fromMap are consistent', () {
      final original = FoodItem(
        id: 5,
        name: 'Гречка отварная',
        nameLower: 'гречка отварная',
        calories: 110.0,
        protein: 3.5,
        fat: 1.0,
        carbs: 21.0,
        isCustom: false,
      );
      final map = original.toMap();
      final restored = FoodItem.fromMap(map);
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.nameLower, original.nameLower);
      expect(restored.calories, original.calories);
      expect(restored.protein, original.protein);
      expect(restored.fat, original.fat);
      expect(restored.carbs, original.carbs);
      expect(restored.isCustom, original.isCustom);
    });
  });

  group('DiaryEntry', () {
    test('toMap and fromMap convert DateTime correctly', () {
      final now = DateTime(2025, 6, 15, 12, 30);
      final original = DiaryEntry(
        id: 10,
        userId: 1,
        foodItemId: 3,
        grams: 200.0,
        mealType: 'lunch',
        eatenAt: now,
        calories: 250.0,
        protein: 12.0,
        fat: 8.0,
        carbs: 30.0,
      );
      final map = original.toMap();
      final restored = DiaryEntry.fromMap(map);
      expect(restored.id, original.id);
      expect(restored.userId, original.userId);
      expect(restored.foodItemId, original.foodItemId);
      expect(restored.grams, original.grams);
      expect(restored.mealType, original.mealType);
      expect(
        restored.eatenAt.toIso8601String(),
        original.eatenAt.toIso8601String(),
      );
      expect(restored.calories, original.calories);
      expect(restored.protein, original.protein);
      expect(restored.fat, original.fat);
      expect(restored.carbs, original.carbs);
    });
  });
}
