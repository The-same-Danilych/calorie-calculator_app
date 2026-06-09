/// Количество шагов онбординга (без приветственного экрана).
const int totalOnboardingSteps = 6;

/// Данные, собираемые в процессе онбординга.
class OnboardingData {
  String? name;
  String? gender;
  int? years;
  double? heightCm;
  double? weightKg;
  String? activity;
  String? goal;
}

/// Глобальное состояние онбординга (синглтон).
class AppState {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  final OnboardingData onboardingData = OnboardingData();

  /// Сброс данных онбординга.
  void resetOnboarding() {
    onboardingData.name = null;
    onboardingData.gender = null;
    onboardingData.years = null;
    onboardingData.heightCm = null;
    onboardingData.weightKg = null;
    onboardingData.activity = null;
    onboardingData.goal = null;
  }
}