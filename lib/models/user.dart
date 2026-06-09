/// Модель пользователя (в приложении один активный пользователь).
class User {
  int? id;
  String name;
  String gender;
  int years;
  double heightCm;
  double weightKg;
  String activity;
  String goal;
  double calorieGoal;
  double proteinGoal;
  double fatGoal;
  double carbGoal;

  User({
    this.id,
    required this.name,
    required this.gender,
    required this.years,
    required this.heightCm,
    required this.weightKg,
    required this.activity,
    required this.goal,
    required this.calorieGoal,
    required this.proteinGoal,
    required this.fatGoal,
    required this.carbGoal,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      gender: map['gender'],
      years: map['years'],
      heightCm: map['height_cm'].toDouble(),
      weightKg: map['weight_kg'].toDouble(),
      activity: map['activity'],
      goal: map['goal'],
      calorieGoal: map['calorie_goal'].toDouble(),
      proteinGoal: map['protein_goal'].toDouble(),
      fatGoal: map['fat_goal'].toDouble(),
      carbGoal: map['carb_goal'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'years': years,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'activity': activity,
      'goal': goal,
      'calorie_goal': calorieGoal,
      'protein_goal': proteinGoal,
      'fat_goal': fatGoal,
      'carb_goal': carbGoal,
    };
  }
}