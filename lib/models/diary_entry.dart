import 'food_item.dart';

/// Модель записи дневника питания.
class DiaryEntry {
  int? id;
  int userId;
  int foodItemId;
  double grams;
  String mealType;
  DateTime eatenAt;
  double calories;
  double protein;
  double fat;
  double carbs;

  FoodItem? foodItem;

  DiaryEntry({
    this.id,
    required this.userId,
    required this.foodItemId,
    required this.grams,
    required this.mealType,
    required this.eatenAt,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    this.foodItem,
  });

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      userId: map['user_id'],
      foodItemId: map['food_item_id'],
      grams: map['grams'].toDouble(),
      mealType: map['meal_type'],
      eatenAt: DateTime.parse(map['eaten_at']),
      calories: map['calories'].toDouble(),
      protein: map['protein'].toDouble(),
      fat: map['fat'].toDouble(),
      carbs: map['carbs'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'food_item_id': foodItemId,
      'grams': grams,
      'meal_type': mealType,
      'eaten_at': eatenAt.toIso8601String(),
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
    };
  }
}