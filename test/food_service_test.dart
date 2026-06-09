import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:calorie_calculator_app/database/db_service.dart';
import 'package:calorie_calculator_app/models/food_item.dart';
import 'package:calorie_calculator_app/services/food_service.dart';

void main() {
  late DatabaseService db;
  late FoodService foodService;

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    db = DatabaseService.instance;
    await db.initInMemory();
    foodService = FoodService();
  });

  test('searchFood returns results case-insensitive', () async {
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
    await db.insertFoodItem(
      FoodItem(
        name: 'Гречневая каша',
        nameLower: 'гречневая каша',
        calories: 110,
        protein: 4,
        fat: 1,
        carbs: 22,
        isCustom: false,
      ),
    );

    final results = await foodService.searchFood('греч');
    expect(results.length, 2);
  });

  test('searchFood returns empty for empty query', () async {
    final results = await foodService.searchFood('');
    expect(results, isEmpty);
  });

  test('searchFood respects limit', () async {
    for (int i = 1; i <= 5; i++) {
      await db.insertFoodItem(
        FoodItem(
          name: 'Продукт $i',
          nameLower: 'продукт $i',
          calories: 100,
          protein: 10,
          fat: 5,
          carbs: 20,
          isCustom: false,
        ),
      );
    }
    final results = await foodService.searchFood('продукт', limit: 3);
    expect(results.length, 3);
  });

  test('addFoodItem inserts custom food and it becomes searchable', () async {
    final newFood = FoodItem(
      name: 'Мой суперфуд',
      nameLower: 'мой суперфуд',
      calories: 200,
      protein: 15,
      fat: 8,
      carbs: 25,
      isCustom: true,
    );
    final id = await foodService.addFoodItem(newFood);
    expect(id, greaterThan(0));

    final results = await foodService.searchFood('суперфуд');
    expect(results.isNotEmpty, true);
    expect(results.first.name, 'Мой суперфуд');
    expect(results.first.isCustom, true);
  });

  test('getFoodItem returns correct item by id', () async {
    final insertedId = await db.insertFoodItem(
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
    final retrieved = await foodService.getFoodItem(insertedId);
    expect(retrieved, isNotNull);
    expect(retrieved!.name, 'Яблоко');
  });

  test('getFoodItem returns null for non-existent id', () async {
    final retrieved = await foodService.getFoodItem(9999);
    expect(retrieved, isNull);
  });
}
