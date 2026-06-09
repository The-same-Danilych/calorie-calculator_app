import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/diary_entry.dart';
import '../models/food_item.dart';
import '../models/user.dart';

/// Сервис для работы с локальной базой данных SQLite.
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'calories.db');
    final db = await openDatabase(path, version: 2, onCreate: _onCreate);
    await db.execute('PRAGMA foreign_keys = ON;');
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        gender TEXT NOT NULL,
        years INTEGER NOT NULL,
        height_cm REAL NOT NULL,
        weight_kg REAL NOT NULL,
        activity TEXT NOT NULL,
        goal TEXT NOT NULL,
        calorie_goal REAL NOT NULL,
        protein_goal REAL NOT NULL,
        fat_goal REAL NOT NULL,
        carb_goal REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE food_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        name_lower TEXT NOT NULL,
        calories REAL NOT NULL,
        protein REAL NOT NULL,
        fat REAL NOT NULL,
        carbs REAL NOT NULL,
        is_custom INTEGER NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_food_name ON food_items(name_lower);');

    await db.execute('''
      CREATE TABLE diary_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        food_item_id INTEGER NOT NULL,
        grams REAL NOT NULL,
        meal_type TEXT NOT NULL,
        eaten_at TEXT NOT NULL,
        calories REAL NOT NULL,
        protein REAL NOT NULL,
        fat REAL NOT NULL,
        carbs REAL NOT NULL,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(food_item_id) REFERENCES food_items(id)
      )
    ''');
    await db.execute('CREATE INDEX idx_diary_date ON diary_entries(eaten_at);');
  }

  Future<User?> getUser() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users', limit: 1);
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    if (user.id == null) return 0;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<FoodItem>> searchFood(String query, {int limit = 10}) async {
    final db = await database;
    final lowerQuery = query.trim().toLowerCase();
    final List<Map<String, dynamic>> maps = await db.query(
      'food_items',
      where: 'name_lower LIKE ?',
      whereArgs: ['%$lowerQuery%'],
      orderBy: 'is_custom DESC, name ASC',
      limit: limit,
    );
    return maps.map((m) => FoodItem.fromMap(m)).toList();
  }

  Future<int> insertFoodItem(FoodItem item) async {
    final db = await database;
    return await db.insert('food_items', item.toMap());
  }

  Future<FoodItem?> getFoodItem(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'food_items',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return FoodItem.fromMap(maps.first);
  }

  Future<int> getFoodItemCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM food_items',
    );
    final count = result.first['count'] as int;
    return count;
  }

  Future<bool> hasPreloadedFoodItems() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT EXISTS(SELECT 1 FROM food_items WHERE is_custom = 0 LIMIT 1) as has',
    );
    final has = result.first['has'] as int? ?? 0;
    return has == 1;
  }

  Future<void> insertFoodItemsBatch(List<FoodItem> items) async {
    final db = await database;
    final batch = db.batch();
    for (final item in items) {
      batch.insert('food_items', item.toMap());
    }
    await batch.commit();
  }

  Future<int> insertDiaryEntry(DiaryEntry entry) async {
    final db = await database;
    return await db.insert('diary_entries', entry.toMap());
  }

  Future<int> updateDiaryEntry(DiaryEntry entry) async {
    final db = await database;
    return await db.update(
      'diary_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteDiaryEntry(int id) async {
    final db = await database;
    return await db.delete('diary_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<DiaryEntry>> getEntriesForDate(int userId, DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final List<Map<String, dynamic>> maps = await db.query(
      'diary_entries',
      where: 'user_id = ? AND eaten_at >= ? AND eaten_at < ?',
      whereArgs: [
        userId,
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
      ],
      orderBy: 'meal_type, id',
    );
    return maps.map((m) => DiaryEntry.fromMap(m)).toList();
  }

  Future<List<FoodItem>> getAllFoodItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('food_items');
    return maps.map((m) => FoodItem.fromMap(m)).toList();
  }

  Future<List<FoodItem>> getNonAlcoholicFoods({
    required List<String> excludeKeywords,
  }) async {
    final db = await database;

    final query = '''
    SELECT id, name, name_lower, calories, protein, fat, carbs, is_custom
    FROM food_items
    WHERE calories > 0
    ''';

    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    final allFoods = maps.map((m) => FoodItem.fromMap(m)).toList();

    return allFoods.where((food) {
      final lowerName = food.name.toLowerCase();
      return !excludeKeywords.any(
        (keyword) => lowerName.contains(keyword.toLowerCase()),
      );
    }).toList();
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> initInMemory() async {
    final uniquePath =
        'file:memdb_${DateTime.now().microsecondsSinceEpoch}?mode=memory&cache=shared';
    final db = await openDatabase(uniquePath, version: 2, onCreate: _onCreate);
    await db.execute('PRAGMA foreign_keys = ON;');
    _database = db;
  }
}
