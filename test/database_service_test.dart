import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:calorie_calculator_app/database/db_service.dart';
import 'package:calorie_calculator_app/models/food_item.dart';
import 'package:calorie_calculator_app/models/diary_entry.dart';
import 'package:calorie_calculator_app/models/user.dart';

void main() {
  late DatabaseService db;

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    db = DatabaseService.instance;
    await db.initInMemory();
  });

  test('insert and retrieve user', () async {
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
    final id = await db.insertUser(user);
    expect(id, greaterThan(0));

    final retrieved = await db.getUser();
    expect(retrieved, isNotNull);
    expect(retrieved!.name, 'Тест');
  });

  test('updateUser changes user data', () async {
    final user = User(
      name: 'Старое имя',
      gender: 'female',
      years: 25,
      heightCm: 170,
      weightKg: 60,
      activity: 'light',
      goal: 'maintain',
      calorieGoal: 2000,
      proteinGoal: 100,
      fatGoal: 50,
      carbGoal: 250,
    );
    final id = await db.insertUser(user);
    expect(id, greaterThan(0));

    final updated = User(
      id: id,
      name: 'Новое имя',
      gender: 'female',
      years: 26,
      heightCm: 171,
      weightKg: 61,
      activity: 'moderate',
      goal: 'lose',
      calorieGoal: 1800,
      proteinGoal: 110,
      fatGoal: 45,
      carbGoal: 220,
    );
    final rowsUpdated = await db.updateUser(updated);
    expect(rowsUpdated, 1);

    final retrieved = await db.getUser();
    expect(retrieved!.name, 'Новое имя');
    expect(retrieved.years, 26);
  });

  test('deleteUser removes user and cascade deletes diary entries', () async {
    final user = User(
      name: 'Удаляемый',
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
    final userId = await db.insertUser(user);
    expect(userId, greaterThan(0));

    final food = FoodItem(
      name: 'Тест продукт',
      nameLower: 'тест продукт',
      calories: 100,
      protein: 10,
      fat: 5,
      carbs: 15,
      isCustom: false,
    );
    final foodId = await db.insertFoodItem(food);
    expect(foodId, greaterThan(0));

    final entry = DiaryEntry(
      userId: userId,
      foodItemId: foodId,
      grams: 100,
      mealType: 'breakfast',
      eatenAt: DateTime.now(),
      calories: 100,
      protein: 10,
      fat: 5,
      carbs: 15,
    );
    await db.insertDiaryEntry(entry);

    await db.deleteUser(userId);

    final retrievedUser = await db.getUser();
    expect(retrievedUser, isNull);

    final entries = await db.getEntriesForDate(userId, DateTime.now());
    expect(entries, isEmpty);
  });

  test('insert and search food', () async {
    final food = FoodItem(
      name: 'Тестовый продукт',
      nameLower: 'тестовый продукт',
      calories: 100,
      protein: 10,
      fat: 5,
      carbs: 15,
      isCustom: true,
    );
    final id = await db.insertFoodItem(food);
    expect(id, greaterThan(0));

    final results = await db.searchFood('тестовый');
    expect(results.isNotEmpty, true);
    expect(results.first.name, 'Тестовый продукт');
  });

  test('getNonAlcoholicFoods excludes alcohol keywords', () async {
    await db.insertFoodItem(
      FoodItem(
        name: 'Яблоко',
        nameLower: 'яблоко',
        calories: 52,
        protein: 0.3,
        fat: 0.2,
        carbs: 14,
        isCustom: false,
      ),
    );
    await db.insertFoodItem(
      FoodItem(
        name: 'Пиво светлое',
        nameLower: 'пиво светлое',
        calories: 45,
        protein: 0.5,
        fat: 0,
        carbs: 3.5,
        isCustom: false,
      ),
    );

    final nonAlcoholic = await db.getNonAlcoholicFoods(
      excludeKeywords: [
        'пиво',
        'вино',
        'водка',
        'коньяк',
        'ром',
        'виски',
        'ликёр',
        'коктейль',
        'шнапс',
        'саке',
        'спирт',
        'алкоголь',
        'brandy',
        'whiskey',
        'vodka',
        'wine',
        'beer',
        'cocktail',
      ],
    );
    final names = nonAlcoholic.map((f) => f.name).toList();
    expect(names, isNot(contains('Пиво светлое')));
    expect(names, contains('Яблоко'));
  });

  test(
    'hasPreloadedFoodItems returns false initially, then true after inserting non-custom item',
    () async {
      var hasPreloaded = await db.hasPreloadedFoodItems();
      expect(hasPreloaded, false);

      await db.insertFoodItem(
        FoodItem(
          name: 'Гречка',
          nameLower: 'гречка',
          calories: 330,
          protein: 12,
          fat: 3,
          carbs: 66,
          isCustom: false,
        ),
      );

      hasPreloaded = await db.hasPreloadedFoodItems();
      expect(hasPreloaded, true);
    },
  );
}
