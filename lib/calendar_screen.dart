import 'package:flutter/material.dart';
import 'database_helper.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  Set<String> _recordedDates = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dates = await DatabaseHelper.instance.getAllDates();
    setState(() {
      _recordedDates = dates.map((d) => d.substring(0, 10)).toSet();
    });
  }

  int get _countThisMonth => _recordedDates.where((d) {
        final dt = DateTime.tryParse(d);
        return dt != null &&
            dt.year == _focusedMonth.year &&
            dt.month == _focusedMonth.month;
      }).length;

  void _prevMonth() => setState(() {
        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
      });

  void _nextMonth() => setState(() {
        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('カレンダー'),
      ),
      body: Column(
        children: [
          _MonthNavigator(
            month: _focusedMonth,
            onPrev: _prevMonth,
            onNext: _nextMonth,
          ),
          _CalendarGrid(
            focusedMonth: _focusedMonth,
            recordedDates: _recordedDates,
          ),
          const SizedBox(height: 16),
          Text(
            '${_focusedMonth.month}月の計測: $_countThisMonth回',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _MonthNavigator extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthNavigator({required this.month, required this.onPrev, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left, color: Colors.white),
          ),
          Text(
            '${month.year}年${month.month}月',
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final Set<String> recordedDates;

  const _CalendarGrid({required this.focusedMonth, required this.recordedDates});

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0=日, 6=土

    const weekLabels = ['日', '月', '火', '水', '木', '金', '土'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: weekLabels
                .map((w) => Expanded(
                      child: Center(
                        child: Text(w,
                            style: TextStyle(
                                color: w == '日'
                                    ? Colors.redAccent
                                    : w == '土'
                                        ? Colors.blueAccent
                                        : Colors.white54,
                                fontSize: 12)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: startWeekday + daysInMonth,
            itemBuilder: (_, i) {
              if (i < startWeekday) return const SizedBox();
              final day = i - startWeekday + 1;
              final dateStr =
                  '${focusedMonth.year}-${focusedMonth.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
              final hasRecord = recordedDates.contains(dateStr);
              final isToday = DateTime.now().year == focusedMonth.year &&
                  DateTime.now().month == focusedMonth.month &&
                  DateTime.now().day == day;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$day',
                    style: TextStyle(
                      color: isToday
                          ? const Color(0xFF00E5FF)
                          : Colors.white70,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasRecord ? const Color(0xFF00E5FF) : Colors.transparent,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
