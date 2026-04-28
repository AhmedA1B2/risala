import 'package:flutter/material.dart';
import 'package:risala/main.dart';
import 'package:risala/vars/colors.dart';
import 'usage_tracker.dart';

class Streak extends StatefulWidget {
  const Streak({super.key});

  @override
  State<Streak> createState() => _StreakState();
}

class _StreakState extends State<Streak> {
  int streakCount = 0;
  bool isGoalCompleted = false;
  late UsageTracker usageTracker;

  @override
  void initState() {
    super.initState();

    _loadInitialData();

    usageTracker = UsageTracker(
      onStreakUpdated: _onStreakUpdated,
    );

    usageTracker.init();
  }

  void _onStreakUpdated(int count, bool completed) {
    if (!mounted) return;

    setState(() {
      streakCount = count;
      isGoalCompleted = completed;
    });

    sharedPref.setBool("isGoalCompleted", completed);

    _updateNotifierSafely(completed);
  }

  void _updateNotifierSafely(bool value) {
    if (isGoalCompletedNotifier.value == value) return;

    // 🔥 أهم سطر: يمنع crash أثناء build
    Future.microtask(() {
      if (mounted) {
        isGoalCompletedNotifier.value = value;
      }
    });
  }

  Future<void> _loadInitialData() async {
    final count = sharedPref.getInt("streakCount") ?? 0;
    final seconds = sharedPref.getInt("todayUsageSeconds") ?? 0;
    final completed = seconds >= 180;

    if (!mounted) return;

    setState(() {
      streakCount = count;
      isGoalCompleted = completed;
    });

    sharedPref.setBool("isGoalCompleted", completed);

    _updateNotifierSafely(completed);
  }

  String getStreakImagePath() {
    String folder = isGoalCompleted ? "1" : "0";

    if (isGoalCompleted && sharedPref.getBool("isVideoWatched") != true) {
      sharedPref.setBool("showVideo", true);
    }

    String fileName;
    if (streakCount <= 9) {
      fileName = "1.png";
    } else if (streakCount <= 29) {
      fileName = "2.png";
    } else if (streakCount <= 49) {
      fileName = "3.png";
    } else if (streakCount <= 99) {
      fileName = "4.png";
    } else {
      fileName = "5.png";
    }

    return "assets/images/streak/$folder/$fileName";
  }

  void _showStreakInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: scandColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.orange),
              SizedBox(width: 8),
              Text("الستريك اليومي", style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "استخدم التطبيق لمدة 3 دقائق يومياً لزيادة الستريك الخاص بك.\nإذا لم تدخل للتطبيق لـ 3 أيام متتالية، سيعود الستريك للصفر!",
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildTierRow("1.png", "0 - 9 أيام", 0),
              _buildTierRow("2.png", "10 - 29 يوم", 10),
              _buildTierRow("3.png", "30 - 49 يوم", 30),
              _buildTierRow("4.png", "50 - 99 يوم", 50),
              _buildTierRow("5.png", "100+ يوم", 100),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text("حسناً", style: TextStyle(color: Colors.orange)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTierRow(String fileName, String title, int requiredDays) {
    bool isUnlocked = streakCount >= requiredDays;
    String folder = isUnlocked ? "1" : "0";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Image.asset("assets/images/streak/$folder/$fileName", width: 32),
          const SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              color: isUnlocked ? Colors.white : Colors.white38,
              fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Icon(
            isUnlocked ? Icons.check_circle : Icons.lock,
            color: isUnlocked ? Colors.green : Colors.white38,
            size: 20,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showStreakInfoDialog,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$streakCount",
            style: const TextStyle(
              color: whiteColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(width: 8),
          Image.asset(
            getStreakImagePath(),
            width: 32,
            key: ValueKey(getStreakImagePath()),
          )
        ],
      ),
    );
  }
}
