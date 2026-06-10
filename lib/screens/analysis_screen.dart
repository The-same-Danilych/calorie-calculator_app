import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/diary_service.dart';
import '../services/user_service.dart';

/// Экран анализа потребления калорий за неделю с возможностью переключения недель.
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

  late DateTime _weekStart;
  String _weekRange = '';

  @override
  void initState() {
    super.initState();
    _weekStart = _getStartOfWeek(DateTime.now());
    _loadWeekData();
  }

  DateTime _getStartOfWeek(DateTime date) {
    final int daysToSubtract = date.weekday - DateTime.monday;
    return date.subtract(Duration(days: daysToSubtract));
  }

  Future<void> _loadWeekData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      _user = await _userService.getCurrentUser();
      if (_user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final List<Map<String, dynamic>> weekStats = [];
      for (int i = 0; i < 7; i++) {
        final day = _weekStart.add(Duration(days: i));
        final summary = await _diaryService.getDaySummary(_user!.id!, day);
        if (!mounted) return;
        weekStats.add({
          'date': day,
          'calories': summary['totals']['calories'] as double,
        });
      }

      if (mounted) {
        setState(() {
          _weekData = weekStats;
          _updateWeekRange();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Ошибка загрузки статистики: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось загрузить данные: $e')),
        );
      }
    }
  }

  void _updateWeekRange() {
    if (_weekData.isEmpty) {
      _weekRange = '';
      return;
    }
    final start = _weekData.first['date'] as DateTime;
    final end = _weekData.last['date'] as DateTime;
    final months = ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
    _weekRange = '${start.day} ${months[start.month - 1]} – ${end.day} ${months[end.month - 1]} ${end.year}';
  }

  Future<void> _previousWeek() async {
    _weekStart = _weekStart.subtract(const Duration(days: 7));
    await _loadWeekData();
  }

  Future<void> _nextWeek() async {
    final nextStart = _weekStart.add(const Duration(days: 7));
    final today = DateTime.now();
    if (nextStart.isAfter(_getStartOfWeek(today))) return;
    _weekStart = nextStart;
    await _loadWeekData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Анализ калорий'),
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
      return const Center(child: Text('Нет данных за выбранную неделю'));
    }

    _weekData.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
    final maxCal = _weekData.map((e) => e['calories'] as double).reduce((a, b) => a > b ? a : b);
    const maxHeight = 200.0;

    const dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _previousWeek,
                tooltip: 'Предыдущая неделя',
              ),
              Text(
                _weekRange,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextWeek,
                tooltip: 'Следующая неделя',
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_weekData.length, (index) {
                final item = _weekData[index];
                final cal = item['calories'] as double;
                final height = maxCal > 0 ? (cal / maxCal) * maxHeight : 0;
                final dayName = dayNames[index];
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
                    Text(dayName, style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text('${cal.toInt()}'),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '* Столбец показывает общее количество калорий за день',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}