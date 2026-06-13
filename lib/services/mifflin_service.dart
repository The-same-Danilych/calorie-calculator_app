/// Расчёт норм калорий и БЖУ по формуле Миффлина-Сан-Жеора.
class MifflinService {
  static const Map<String, double> activityMultipliers = {
    'sedentary': 1.2,
    'light': 1.375,
    'moderate': 1.55,
    'active': 1.725,
    'very_active': 1.9,
  };

  static const Map<String, double> goalAdjustments = {
    'lose': 0.8,
    'maintain': 1.0,
    'gain': 1.2,
  };

  static const double minCaloriesMale = 1500;
  static const double minCaloriesFemale = 1200;

  static double calculateBMR({
    required String gender,
    required double weightKg,
    required double heightCm,
    required int age,
  }) {
    if (gender == 'male') {
      return 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    } else {
      return 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
    }
  }

  static double calculateTDEE({
    required String gender,
    required double weightKg,
    required double heightCm,
    required int age,
    required String activity,
  }) {
    final bmr = calculateBMR(
      gender: gender,
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
    );
    final multiplier = activityMultipliers[activity] ?? 1.55;
    return bmr * multiplier;
  }

  static Map<String, double> calculateGoals({
    required String gender,
    required double weightKg,
    required double heightCm,
    required int age,
    required String activity,
    required String goal,
  }) {
    double tdee = calculateTDEE(
      gender: gender,
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      activity: activity,
    );

    double calories = tdee * (goalAdjustments[goal] ?? 1.0);

    final minCal = gender == 'male' ? minCaloriesMale : minCaloriesFemale;
    if (calories < minCal) calories = minCal;

    calories = double.parse(calories.toStringAsFixed(1));

    double protein, fat, carbs;
    if (gender == 'male') {
      protein = (calories * 0.30) / 4;
      fat = (calories * 0.20) / 9;
      carbs = (calories * 0.50) / 4;
    } else {
      protein = (calories * 0.30) / 4;
      fat = (calories * 0.10) / 9;
      carbs = (calories * 0.60) / 4;
    }

    protein = double.parse(protein.toStringAsFixed(1));
    fat = double.parse(fat.toStringAsFixed(1));
    carbs = double.parse(carbs.toStringAsFixed(1));

    return {
      'calorie_goal': calories,
      'protein_goal': protein,
      'fat_goal': fat,
      'carb_goal': carbs,
    };
  }
}