import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:risala/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsageTracker with WidgetsBindingObserver {
  static const int requiredSeconds = 180;

  Timer? _timer;
  int _todaySeconds = 0;
  bool isGoalCompleted = false;
  String _currentDateStr = "";

  // الدالة التي تربط بين المتتبع والواجهة
  final Function(int streak, bool completed)? onStreakUpdated;

  UsageTracker({this.onStreakUpdated});

  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    _currentDateStr = _formatDate(DateTime.now());
    await _checkNewDay();
    _startTimer();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkIfDayChanged();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      _checkIfDayChanged();

      _todaySeconds++;

      if (_todaySeconds == requiredSeconds) {
        isGoalCompleted = true;
        await _tryIncreaseStreak();
      }

      if (_todaySeconds % 10 == 0) {
        await _saveTodayUsage();
      }
    });
  }

  Future<void> _checkIfDayChanged() async {
    String realToday = _formatDate(DateTime.now());
    if (_currentDateStr != realToday) {
      _currentDateStr = realToday;

      // بمجرد استدعاء هذه الدالة، ستقوم هي بتحديث الواجهة بالبيانات الجديدة
      await _checkNewDay();
    }
  }

  Future<void> _checkNewDay() async {
    final prefs = await SharedPreferences.getInstance();

    final today = _formatDate(DateTime.now());

    final lastOpenDate = prefs.getString("lastOpenDate");

    if (lastOpenDate != today) {
      await prefs.setBool("isVideoWatched", false);

      await prefs.setInt("todayUsageSeconds", 0);

      _todaySeconds = 0;

      isGoalCompleted = false;

      showVideoNotifier.value = false;

      await _checkBrokenStreak(lastOpenDate);

      await prefs.setString("lastOpenDate", today);

      if (onStreakUpdated != null) {
        int streak = prefs.getInt("streakCount") ?? 0;
        onStreakUpdated!(streak, false);
      }
    } else {
      _todaySeconds = prefs.getInt("todayUsageSeconds") ?? 0;

      isGoalCompleted = _todaySeconds >= requiredSeconds;
    }
  }

  Future<void> _checkBrokenStreak(String? lastOpenDateStr) async {
    if (lastOpenDateStr == null) return;

    DateTime lastOpenDate = DateTime.parse(lastOpenDateStr);
    DateTime today = DateTime.now();

    DateTime lastOpenDateOnly =
        DateTime(lastOpenDate.year, lastOpenDate.month, lastOpenDate.day);
    DateTime todayOnly = DateTime(today.year, today.month, today.day);

    int differenceInDays = todayOnly.difference(lastOpenDateOnly).inDays;

    if (differenceInDays >= 3) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("streakCount", 0);

      // تنبيه الواجهة بأن الستريك انكسر
      if (onStreakUpdated != null) {
        onStreakUpdated!(0, false);
      }
    }
  }

  Future<void> _tryIncreaseStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _formatDate(DateTime.now());
    final lastStreakDate = prefs.getString("lastStreakDate");

    int currentStreak = prefs.getInt("streakCount") ?? 0;

    if (lastStreakDate != today) {
      currentStreak++;
      await prefs.setInt("streakCount", currentStreak);
      await prefs.setString("lastStreakDate", today);
    }

    if (onStreakUpdated != null) {
      onStreakUpdated!(currentStreak, true);
    }
  }

  Future<void> _saveTodayUsage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("todayUsageSeconds", _todaySeconds);
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
