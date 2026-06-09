import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/diary_service.dart';
import '../services/user_service.dart';

/// Экран анализа потребления калорий за неделю (график).
class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final DiaryService _diaryService = DiaryService();
  final UserService _userService = UserService();
  User? _user;
  List<Map<String, dynamic>> _weekData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _user = await _userService.getCurrentUser();
      if (_user != null) {
        _weekData = await _diaryService.getWeekCalories(_user!.id!);
      }
    } catch (e) {
      debugPrint('Ошибка загрузки статистики: $e');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Анализ за неделю'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildChart(),
    );
  }

  Widget _buildChart() {
    if (_weekData.isEmpty) {
      return const Center(child: Text('Нет данных за последние 7 дней'));
    }

    _weekData.sort(
      (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
    );
    final maxCal = _weekData
        .map((e) => e['calories'] as double)
        .reduce((a, b) => a > b ? a : b);
    const maxHeight = 200.0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Потребление калорий по дням',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _weekData.map((item) {
                final cal = item['calories'] as double;
                final height = maxCal > 0 ? (cal / maxCal) * maxHeight : 0;
                final dateStr = (item['date'] as DateTime).day.toString();
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 40,
                      height: height.toDouble(),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(dateStr),
                    Text('${cal.toInt()}'),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}