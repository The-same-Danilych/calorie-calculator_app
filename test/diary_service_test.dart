import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:calorie_calculator_app/database/db_service.dart';
import 'package:calorie_calculator_app/models/user.dart';
import 'package:calorie_calculator_app/models/food_item.dart';
import 'package:calorie_calculator_app/models/diary_entry.dart';
import 'package:calorie_calculator_app/services/diary_service.dart';

void main() {
  late DatabaseService db;
  late DiaryService diaryService;
  late int userId;
  late int foodId;

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    db = DatabaseService.instance;
    await db.initInMemory();

    final user = User(
      name: 'Тест',
      gender: 'male',
      years: 30,
      heightCm: 180,
      weightKg: 80,
      activity: 'moderate',
      goal: 'maintain',
      calorieGoal: 2500,
      proteinGoal: 150,
      fatGoal: 55,
      carbGoal: 300,
    );
    userId = await db.insertUser(user);

    final food = FoodItem(
      name: 'Овсянка',
      nameLower: 'овсянка',
      calories: 350,
      protein: 12,
      fat: 6,
      carbs: 60,
      isCustom: false,
    );
    foodId = await db.insertFoodItem(food);

    diaryService = DiaryService();
  });

  test('addEntry and getDaySummary return correct totals', () async {
    final entry = DiaryEntry(
      userId: userId,
      foodItemId: foodId,
      grams: 100,
      mealType: 'breakfast',
      eatenAt: DateTime(2025, 6, 10, 8, 0),
      calories: 350,
      protein: 12,
      fat: 6,
      carbs: 60,
    );
    await diaryService.addEntry(entry);

    final summary = await diaryService.getDaySummary(
      userId,
      DateTime(2025, 6, 10),
    );
    expect(summary['totals']['calories'], 350);
    expect((summary['meals']['breakfast'] as List).length, 1);
  });

  test('updateEntry modifies grams and recalculates nutrition', () async {
    final entry = DiaryEntry(
      userId: userId,
      foodItemId: foodId,
      grams: 100,
      mealType: 'lunch',
      eatenAt: DateTime(2025, 6, 10, 12, 0),
      calories: 350,
      protein: 12,
      fat: 6,
      carbs: 60,
    );
    final id = await diaryService.addEntry(entry);

    final updated = DiaryEntry(
      id: id,
      userId: userId,
      foodItemId: foodId,
      grams: 200,
      mealType: 'lunch',
      eatenAt: DateTime(2025, 6, 10, 12, 0),
      calories: 700,
      protein: 24,
      fat: 12,
      carbs: 120,
    );
    await diaryService.updateEntry(updated);

    final summary = await diaryService.getDaySummary(
      userId,
      DateTime(2025, 6, 10),
    );
    expect(summary['totals']['calories'], 700);
  });

  test('deleteEntry removes entry', () async {
    final entry = DiaryEntry(
      userId: userId,
      foodItemId: foodId,
      grams: 50,
      mealType: 'snack',
      eatenAt: DateTime(2025, 6, 10, 16, 0),
      calories: 175,
      protein: 6,
      fat: 3,
      carbs: 30,
    );
    final id = await diaryService.addEntry(entry);
    await diaryService.deleteEntry(id);

    final summary = await diaryService.getDaySummary(
      userId,
      DateTime(2025, 6, 10),
    );
    expect(summary['totals']['calories'], 0);
  });
}
