import 'package:flutter/material.dart';
import 'package:flutter/services.dart.';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding/greeting_screen.dart';
import 'screens/onboarding/name_screen.dart';
import 'screens/onboarding/gender_screen.dart';
import 'screens/onboarding/age_screen.dart';
import 'screens/onboarding/body_screen.dart';
import 'screens/onboarding/activity_screen.dart';
import 'screens/onboarding/goal_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_food_screen.dart';
import 'screens/analysis_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/settings_screen.dart';
import 'theme_provider.dart';
import 'models/diary_entry.dart';
import 'screens/about_screen.dart';


/// Запуск приложения
/// Ориентация - вертикальная
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const CalorieTrackerApp());
}

/// Главный виджет приложения.
/// Управляет темами (светлая/тёмная) и маршрутизацией.
class CalorieTrackerApp extends StatelessWidget {
  const CalorieTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Трекер калорий',
            theme: ThemeData.light().copyWith(
              primaryColor: Colors.green,
              colorScheme: const ColorScheme.light(primary: Colors.green),
              inputDecorationTheme: const InputDecorationTheme(
                labelStyle: TextStyle(color: Colors.black),
                floatingLabelStyle: TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              primaryColor: Colors.green,
              colorScheme: const ColorScheme.dark(primary: Colors.green),
              inputDecorationTheme: const InputDecorationTheme(
                labelStyle: TextStyle(color: Colors.white),
                floatingLabelStyle: TextStyle(color: Colors.white),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            initialRoute: '/splash',
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/splash':
                  return MaterialPageRoute(
                    builder: (_) => SplashScreen(),
                  );
                case '/onboarding':
                  return MaterialPageRoute(
                    builder: (_) => const GreetingScreen(),
                  );
                case '/onboarding/name':
                  return MaterialPageRoute(builder: (_) => const NameScreen());
                case '/onboarding/gender':
                  return MaterialPageRoute(
                    builder: (_) => const GenderScreen(),
                  );
                case '/onboarding/age':
                  return MaterialPageRoute(builder: (_) => const AgeScreen());
                case '/onboarding/body':
                  return MaterialPageRoute(builder: (_) => const BodyScreen());
                case '/onboarding/activity':
                  return MaterialPageRoute(
                    builder: (_) => const ActivityScreen(),
                  );
                case '/onboarding/goal':
                  return MaterialPageRoute(builder: (_) => const GoalScreen());
                case '/home':
                  return MaterialPageRoute(builder: (_) => const HomeScreen());
                case '/add_food':
                  final args = settings.arguments;
                  if (args is DiaryEntry) {
                    return MaterialPageRoute(
                      builder: (_) => AddFoodScreen(entry: args),
                    );
                  } else if (args is DateTime) {
                    return MaterialPageRoute(
                      builder: (_) => AddFoodScreen(selectedDate: args),
                    );
                  } else {
                    return MaterialPageRoute(
                      builder: (_) => const AddFoodScreen(),
                    );
                  }
                case '/analysis':
                  return MaterialPageRoute(
                    builder: (_) => const AnalysisScreen(),
                  );
                case '/edit_profile':
                  return MaterialPageRoute(
                    builder: (_) => const EditProfileScreen(),
                  );
                case '/settings':
                  return MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  );
                case '/about':
                  return MaterialPageRoute(builder: (_) => const AboutScreen());
                default:
                  return MaterialPageRoute(
                    builder: (_) => const Scaffold(
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Ошибка!',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.black,
                              ),
                            ),
                            Icon(Icons.error, size: 100, color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                  );
              }
            },
          );
        },
      ),
    );
  }
}
