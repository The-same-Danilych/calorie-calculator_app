/// Модель продукта питания.
class FoodItem {
  int? id;
  String name;
  String nameLower;
  double calories;
  double protein;
  double fat;
  double carbs;
  bool isCustom;

  FoodItem({
    this.id,
    required this.name,
    required this.nameLower,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.isCustom,
  });

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'],
      name: map['name'],
      nameLower: map['name_lower'],
      calories: map['calories'].toDouble(),
      protein: map['protein'].toDouble(),
      fat: map['fat'].toDouble(),
      carbs: map['carbs'].toDouble(),
      isCustom: map['is_custom'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'name_lower': nameLower,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'is_custom': isCustom ? 1 : 0,
    };
  }
}