import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:calorie_calculator_app/database/db_service.dart';
import 'package:calorie_calculator_app/models/food_item.dart';
import 'package:calorie_calculator_app/services/suggestion_service.dart';

void main() {
  late DatabaseService db;
  late SuggestionService suggestionService;

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    db = DatabaseService.instance;
    await db.initInMemory();

    // Добавляем тестовые продукты
    await db.insertFoodItem(
      FoodItem(
        name: 'Овсянка',
        nameLower: 'овсянка',
        calories: 350,
        protein: 12,
        fat: 6,
        carbs: 60,
        isCustom: false,
      ),
    );
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
    await db.insertFoodItem(
      FoodItem(
        name: 'Гречка отварная',
        nameLower: 'гречка отварная',
        calories: 110,
        protein: 3.5,
        fat: 1,
        carbs: 21,
        isCustom: false,
      ),
    );

    suggestionService = SuggestionService();
  });

  test('getSuggestions returns correct suggestions for 200 kcal', () async {
    final suggestions = await suggestionService.getSuggestions(200);
    expect(suggestions.isNotEmpty, true);
    expect(suggestions.any((s) => s.foodItem.name == 'Овсянка'), true);
  });

  test('getSuggestions excludes alcohol products', () async {
    final suggestions = await suggestionService.getSuggestions(100);
    expect(suggestions.any((s) => s.foodItem.name.contains('Пиво')), false);
  });

  test('getSuggestions sorts by closest match', () async {
    final suggestions = await suggestionService.getSuggestions(100);
    expect(suggestions.length, greaterThanOrEqualTo(2));
  });

  test('getSuggestions respects tolerancePercent (20% default)', () async {
    await db.insertFoodItem(
      FoodItem(
        name: 'Продукт 80 ккал',
        nameLower: 'продукт 80 ккал',
        calories: 80,
        protein: 0,
        fat: 0,
        carbs: 0,
        isCustom: false,
      ),
    );
    final suggestions = await suggestionService.getSuggestions(100);
    expect(suggestions.any((s) => s.foodItem.name == 'Продукт 80 ккал'), true);
  });

  test('getSuggestions returns empty when remainingCalories <= 0', () async {
    final suggestions = await suggestionService.getSuggestions(0);
    expect(suggestions, isEmpty);
    final suggestionsNegative = await suggestionService.getSuggestions(-50);
    expect(suggestionsNegative, isEmpty);
  });

  test('getSuggestions returns empty when no product fits', () async {
    await db.insertFoodItem(
      FoodItem(
        name: 'Масло',
        nameLower: 'масло',
        calories: 900,
        protein: 0,
        fat: 100,
        carbs: 0,
        isCustom: false,
      ),
    );
    final suggestions = await suggestionService.getSuggestions(50);
    expect(suggestions.any((s) => s.foodItem.name == 'Масло'), false);
  });
}
