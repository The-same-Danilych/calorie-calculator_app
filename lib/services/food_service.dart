import '../database/db_service.dart';
import '../models/food_item.dart';

/// Сервис для поиска и добавления продуктов.
class FoodService {
  final DatabaseService _db = DatabaseService.instance;

  /// Поиск продуктов по названию (регистронезависимый).
  Future<List<FoodItem>> searchFood(String query, {int limit = 10}) async {
    if (query.trim().isEmpty) return [];
    return await _db.searchFood(query, limit: limit);
  }

  /// Добавление пользовательского продукта.
  Future<int> addFoodItem(FoodItem item) async {
    return await _db.insertFoodItem(item);
  }

  Future<FoodItem?> getFoodItem(int id) async {
    return await _db.getFoodItem(id);
  }
}