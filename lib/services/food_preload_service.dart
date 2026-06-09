import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../database/db_service.dart';
import '../models/food_item.dart';

/// Первоначальное заполнение БД
class FoodPreloadService {
  static final FoodPreloadService _instance = FoodPreloadService._();
  FoodPreloadService._();
  factory FoodPreloadService() => _instance;

  Future<void> preloadIfNeeded() async {
    try {
      final db = DatabaseService.instance;
      final hasPreloaded = await db.hasPreloadedFoodItems();
      if (!hasPreloaded) {
        await _preloadFoodItems(db);
      }
    } catch (e) {
      debugPrint('Ошибка предзагрузки продуктов: $e');
    }
  }

  Future<void> _preloadFoodItems(DatabaseService db) async {
    try {
      final jsonString = await rootBundle.loadString(
        'seed_data/initial_food.json',
      );
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final List<FoodItem> foodItems = [];
      for (var json in jsonList) {
        foodItems.add(
          FoodItem(
            name: json['name'],
            nameLower: json['name'].toLowerCase(),
            calories: (json['calories'] as num).toDouble(),
            protein: (json['protein'] as num).toDouble(),
            fat: (json['fat'] as num).toDouble(),
            carbs: (json['carbs'] as num).toDouble(),
            isCustom: json['is_custom'] ?? false,
          ),
        );
      }
      await db.insertFoodItemsBatch(foodItems);
      debugPrint('Загружено ${foodItems.length} продуктов');
    } catch (e) {
      debugPrint('Ошибка загрузки начальных продуктов: $e');
    }
  }
}
