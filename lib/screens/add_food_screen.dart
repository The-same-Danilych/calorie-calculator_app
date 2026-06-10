import 'package:flutter/material.dart';

import '../models/diary_entry.dart';
import '../models/food_item.dart';
import '../services/diary_service.dart';
import '../services/food_service.dart';
import '../services/user_service.dart';

/// Экран добавления или редактирования записи приёма пищи.
class AddFoodScreen extends StatefulWidget {
  final DiaryEntry? entry;
  final DateTime? selectedDate;

  const AddFoodScreen({super.key, this.entry, this.selectedDate});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final FoodService _foodService = FoodService();
  final DiaryService _diaryService = DiaryService();
  final UserService _userService = UserService();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _gramsController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();

  String _selectedMeal = 'breakfast';
  FoodItem? _selectedFood;
  List<FoodItem> _searchResults = [];
  bool _isSearching = false;
  bool _isEditing = false;
  int? _editingEntryId;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _isEditing = true;
      _editingEntryId = widget.entry!.id;
      _selectedMeal = widget.entry!.mealType;
      _selectedDate = widget.entry!.eatenAt;
      _gramsController.text = widget.entry!.grams.toString();
      _loadFoodItem(widget.entry!.foodItemId);
    } else if (widget.selectedDate != null) {
      _selectedDate = widget.selectedDate!;
    } else {
      _selectedDate = DateTime.now();
    }
    _gramsController.addListener(() => setState(() {}));
    _caloriesController.addListener(() => setState(() {}));
    _proteinController.addListener(() => setState(() {}));
    _fatController.addListener(() => setState(() {}));
    _carbsController.addListener(() => setState(() {}));
  }

  Future<void> _loadFoodItem(int id) async {
    final food = await _foodService.getFoodItem(id);
    if (mounted && food != null) {
      setState(() {
        _selectedFood = food;
        _nameController.text = food.name;
        _caloriesController.text = food.calories.toString();
        _proteinController.text = food.protein.toString();
        _fatController.text = food.fat.toString();
        _carbsController.text = food.carbs.toString();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _gramsController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  Future<void> _searchFood(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults.clear());
      return;
    }
    if (mounted) setState(() => _isSearching = true);
    final results = await _foodService.searchFood(query);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  void _selectFood(FoodItem food) {
    setState(() {
      _selectedFood = food;
      _nameController.text = food.name;
      _caloriesController.text = food.calories.toString();
      _proteinController.text = food.protein.toString();
      _fatController.text = food.fat.toString();
      _carbsController.text = food.carbs.toString();
      if (_gramsController.text.trim().isEmpty) {
        _gramsController.text = '100';
      }
      _searchResults.clear();
      _searchController.clear();
    });
  }

  void _clearSelectedFood() {
    setState(() {
      _selectedFood = null;
      _nameController.clear();
      _caloriesController.clear();
      _proteinController.clear();
      _fatController.clear();
      _carbsController.clear();
    });
  }

  bool get _isFormValid {
    final grams = double.tryParse(_gramsController.text);
    final calories = double.tryParse(_caloriesController.text);
    final protein = double.tryParse(_proteinController.text);
    final fat = double.tryParse(_fatController.text);
    final carbs = double.tryParse(_carbsController.text);
    if (_nameController.text.trim().isEmpty) return false;
    if (grams == null || grams <= 0) return false;
    if (calories == null || calories < 0) return false;
    if (protein == null || protein < 0) return false;
    if (fat == null || fat < 0) return false;
    if (carbs == null || carbs < 0) return false;
    return true;
  }

  double get _previewCalories {
    final grams = double.tryParse(_gramsController.text) ?? 0;
    final cal100 = double.tryParse(_caloriesController.text) ?? 0;
    return grams * cal100 / 100;
  }

  double get _previewProtein {
    final grams = double.tryParse(_gramsController.text) ?? 0;
    final prot100 = double.tryParse(_proteinController.text) ?? 0;
    return grams * prot100 / 100;
  }

  double get _previewFat {
    final grams = double.tryParse(_gramsController.text) ?? 0;
    final fat100 = double.tryParse(_fatController.text) ?? 0;
    return grams * fat100 / 100;
  }

  double get _previewCarbs {
    final grams = double.tryParse(_gramsController.text) ?? 0;
    final carbs100 = double.tryParse(_carbsController.text) ?? 0;
    return grams * carbs100 / 100;
  }

  Future<void> _saveEntry() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля корректно')),
      );
      return;
    }

    final grams = double.parse(_gramsController.text);
    final calories = double.parse(_caloriesController.text);
    final protein = double.parse(_proteinController.text);
    final fat = double.parse(_fatController.text);
    final carbs = double.parse(_carbsController.text);
    final mealType = _selectedMeal;
    final newName = _nameController.text.trim();

    int foodItemId;

    bool hasChanges = true;
    if (_selectedFood != null) {
      hasChanges =
          _selectedFood!.name != newName ||
          _selectedFood!.calories != calories ||
          _selectedFood!.protein != protein ||
          _selectedFood!.fat != fat ||
          _selectedFood!.carbs != carbs;
    }

    if (_selectedFood == null || hasChanges) {
      final newFood = FoodItem(
        name: newName,
        nameLower: newName.toLowerCase(),
        calories: calories,
        protein: protein,
        fat: fat,
        carbs: carbs,
        isCustom: true,
      );
      foodItemId = await _foodService.addFoodItem(newFood);
    } else {
      foodItemId = _selectedFood!.id!;
    }

    final user = await _userService.getCurrentUser();
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Пользователь не найден')));
      return;
    }

    final entryCalories = grams * calories / 100;
    final entryProtein = grams * protein / 100;
    final entryFat = grams * fat / 100;
    final entryCarbs = grams * carbs / 100;

    if (_isEditing && _editingEntryId != null) {
      final entry = DiaryEntry(
        id: _editingEntryId,
        userId: user.id!,
        foodItemId: foodItemId,
        grams: grams,
        mealType: mealType,
        eatenAt: _selectedDate,
        calories: entryCalories,
        protein: entryProtein,
        fat: entryFat,
        carbs: entryCarbs,
      );
      await _diaryService.updateEntry(entry);
    } else {
      final entry = DiaryEntry(
        userId: user.id!,
        foodItemId: foodItemId,
        grams: grams,
        mealType: mealType,
        eatenAt: _selectedDate,
        calories: entryCalories,
        protein: entryProtein,
        fat: entryFat,
        carbs: entryCarbs,
      );
      await _diaryService.addEntry(entry);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редактировать' : 'Добавить продукт'),
        actions: [
          if (_selectedFood != null)
            IconButton(
              icon: const Icon(Icons.cleaning_services),
              onPressed: _clearSelectedFood,
              tooltip: 'Очистить',
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Поиск продукта',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _isSearching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                ),
                onChanged: _searchFood,
              ),
              if (_searchResults.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final food = _searchResults[index];
                      return ListTile(
                        leading: food.isCustom
                            ? const Icon(
                                Icons.assignment_turned_in_rounded,
                                size: 20,
                                color: Colors.grey,
                              )
                            : null,
                        title: Text(food.name),
                        subtitle: Text(
                          '${food.calories.toInt()} ккал | '
                          'Б:${food.protein.toInt()} Ж:${food.fat.toInt()} У:${food.carbs.toInt()}',
                        ),
                        onTap: () => _selectFood(food),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Название продукта*',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _gramsController,
                decoration: const InputDecoration(labelText: 'Количество (г)*'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              const Text(
                'КБЖУ на 100 г',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _caloriesController,
                      decoration: const InputDecoration(labelText: 'Ккал*'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _proteinController,
                      decoration: const InputDecoration(
                        labelText: 'Белки (г)*',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _fatController,
                      decoration: const InputDecoration(labelText: 'Жиры (г)*'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _carbsController,
                      decoration: const InputDecoration(
                        labelText: 'Углеводы (г)*',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Приём пищи',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'breakfast', label: Text('Завтрак')),
                  ButtonSegment(value: 'lunch', label: Text('Обед')),
                  ButtonSegment(value: 'dinner', label: Text('Ужин')),
                  ButtonSegment(value: 'snack', label: Text('Перекус')),
                ],
                selected: {_selectedMeal},
                onSelectionChanged: (Set<String> newSelection) =>
                    setState(() => _selectedMeal = newSelection.first),
              ),
              const SizedBox(height: 24),
              if (_isFormValid &&
                  double.tryParse(_gramsController.text) != null)
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text(
                          'Итого для порции',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _previewItem(
                              'Ккал',
                              _previewCalories.toStringAsFixed(0),
                              Colors.red,
                            ),
                            _previewItem(
                              'Белки',
                              _previewProtein.toStringAsFixed(1),
                              Colors.blue,
                            ),
                            _previewItem(
                              'Жиры',
                              _previewFat.toStringAsFixed(1),
                              Colors.orange,
                            ),
                            _previewItem(
                              'Углев.',
                              _previewCarbs.toStringAsFixed(1),
                              Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isFormValid ? _saveEntry : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    _isEditing ? 'Сохранить изменения' : 'Добавить в дневник',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _previewItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
