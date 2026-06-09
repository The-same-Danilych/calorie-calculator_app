import '../database/db_service.dart';
import '../models/diary_entry.dart';

/// Сервис для работы с дневником питания.
class DiaryService {
  final DatabaseService _db = DatabaseService.instance;

  /// Возвращает сводку за день: общие КБЖУ и записи по приёмам пищи.
  Future<Map<String, dynamic>> getDaySummary(int userId, DateTime date) async {
    final entries = await _db.getEntriesForDate(userId, date);
    
    final Map<String, List<DiaryEntry>> meals = {
      'breakfast': [],
      'lunch': [],
      'dinner': [],
      'snack': [],
    };
    
    double totalCalories = 0;
    double totalProtein = 0;
    double totalFat = 0;
    double totalCarbs = 0;
    
    for (var entry in entries) {
      if (meals.containsKey(entry.mealType)) {
        meals[entry.mealType]!.add(entry);
      }
      
      totalCalories += entry.calories;
      totalProtein += entry.protein;
      totalFat += entry.fat;
      totalCarbs += entry.carbs;
      
      entry.foodItem = await _db.getFoodItem(entry.foodItemId);
    }
    
    return {
      'totals': {
        'calories': totalCalories,
        'protein': totalProtein,
        'fat': totalFat,
        'carbs': totalCarbs,
      },
      'meals': meals,
    };
  }
  
  Future<int> addEntry(DiaryEntry entry) async {
    return await _db.insertDiaryEntry(entry);
  }
  
  Future<int> updateEntry(DiaryEntry entry) async {
    return await _db.updateDiaryEntry(entry);
  }
  
  Future<int> deleteEntry(int entryId) async {
    return await _db.deleteDiaryEntry(entryId);
  }

  /// Возвращает список калорий за последние 7 дней.
  Future<List<Map<String, dynamic>>> getWeekCalories(int userId) async {
    final now = DateTime.now();
    final List<Map<String, dynamic>> result = [];
    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final summary = await getDaySummary(userId, date);
      result.add({
        'date': date,
        'calories': summary['totals']['calories'],
      });
    }
    return result;
  }
}