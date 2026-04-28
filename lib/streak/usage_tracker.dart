import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsageTracker with WidgetsBindingObserver {
  static const int requiredSeconds = 180;

  Timer? _timer;
  int _todaySeconds = 0;
  bool isGoalCompleted = false;
  String _currentDateStr = "";

  // الدالة تستقبل قيمتين: عدد الستريك، وهل اكتمل هدف اليوم أم لا
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

  // هذه الدالة تعمل عندما يخرج المستخدم من التطبيق ويعود إليه (تحديث تلقائي)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkIfDayChanged();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      // التحقق كل ثانية إذا دخلنا في يوم جديد (تجاوزنا منتصف الليل)
      _checkIfDayChanged();

      _todaySeconds++;

      // 1. تحقق من الوصول للهدف لأول مرة في هذه الجلسة
      if (_todaySeconds == requiredSeconds) {
        isGoalCompleted = true;
        await _tryIncreaseStreak();
      }

      // 2. حفظ التقدم كل 10 ثوانٍ للأداء
      if (_todaySeconds % 10 == 0) {
        await _saveTodayUsage();
      }
    });
  }

  // دالة مخصصة لاكتشاف إذا تغير اليوم الفعلي (التقويم) ليعود المجلد لـ 0
  Future<void> _checkIfDayChanged() async {
    String realToday = _formatDate(DateTime.now());
    if (_currentDateStr != realToday) {
      _currentDateStr = realToday;
      await _checkNewDay(); // تحديث البيانات لليوم الجديد

      // إخبار الواجهة أن الهدف لم يكتمل اليوم ليعود للمجلد 0
      if (onStreakUpdated != null) {
        final prefs = await SharedPreferences.getInstance();
        int currentStreak = prefs.getInt("streakCount") ?? 0;
        onStreakUpdated!(currentStreak, false);
      }
    }
  }

  Future<void> _checkNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _formatDate(DateTime.now());
    final lastOpenDate = prefs.getString("lastOpenDate");

    if (lastOpenDate != today) {
      await prefs.setInt("todayUsageSeconds", 0);
      _todaySeconds = 0;
      isGoalCompleted = false;

      await _checkBrokenStreak(lastOpenDate);
      await prefs.setString("lastOpenDate", today);
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
