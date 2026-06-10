import '../database/db_service.dart';
import '../models/food_item.dart';

/// Подбор еды закрывающей необходимую калорийность 
class SuggestionService {
  final DatabaseService _db = DatabaseService.instance;

  static const List<String> _alcoholKeywords = [
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
    'ликер',
    'наливка',
    'абсент',
    'джин',
    'текила',
    'кальвадос',
    'граппа',
    'арманьяк',
    'сидр',
    'пунш',
    'глинтвейн',
  ];

  static const double maxGramsPerPortion = 500.0;

  Future<List<Suggestion>> getSuggestions(
    double remainingCalories, {
    double tolerancePercent = 20.0,
    int maxResults = 5,
  }) async {
    if (remainingCalories <= 0) return [];

    final allFoods = await _db.getNonAlcoholicFoods(
      excludeKeywords: _alcoholKeywords,
    );

    final suggestions = <Suggestion>[];

    for (final food in allFoods) {
      if (food.calories <= 0) continue;

      final gramsNeeded = (remainingCalories / food.calories) * 100;

      if (gramsNeeded > maxGramsPerPortion) continue;
      if (gramsNeeded < 10) continue;

      final actualCalories = (gramsNeeded / 100) * food.calories;
      final errorPercent =
          ((actualCalories - remainingCalories).abs() / remainingCalories) *
          100;

      if (errorPercent <= tolerancePercent) {
        suggestions.add(
          Suggestion(
            foodItem: food,
            grams: gramsNeeded,
            calories: actualCalories,
          ),
        );
      }
    }

    suggestions.sort(
      (a, b) => (a.calories - remainingCalories).abs().compareTo(
        (b.calories - remainingCalories).abs(),
      ),
    );

    return suggestions.take(maxResults).toList();
  }
}

class Suggestion {
  final FoodItem foodItem;
  final double grams;
  final double calories;

  Suggestion({
    required this.foodItem,
    required this.grams,
    required this.calories,
  });
}
