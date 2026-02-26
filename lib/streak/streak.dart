import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      onStreakUpdated: (count, completed) {
        setState(() {
          streakCount = count;
          isGoalCompleted = completed;
        });
      },
    );
    usageTracker.init();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      streakCount = prefs.getInt("streakCount") ?? 0;
      int seconds = prefs.getInt("todayUsageSeconds") ?? 0;
      isGoalCompleted = seconds >= 180;
    });
  }

  String getStreakImagePath() {
    String folder = isGoalCompleted ? "1" : "0";
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

  // 💡 الدالة المسؤولة عن إظهار النافذة المنبثقة
  void _showStreakInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: scandColor, // لون خلفية مناسب
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
              // استدعاء دالة بناء صفوف المستويات
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

  // 💡 دالة لبناء كل مستوى في النافذة المنبثقة للتحقق هل هو مفتوح أم مغلق
  Widget _buildTierRow(String fileName, String title, int requiredDays) {
    // المستوى يكون "مفتوحاً" إذا كان الستريك الحالي أكبر من أو يساوي المطلوب للمستوى
    bool isUnlocked = streakCount >= requiredDays;
    // إذا مفتوح نأخذ من مجلد 1، إذا مغلق من مجلد 0
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
              color: isUnlocked
                  ? Colors.white
                  : Colors.white38, // لون باهت إذا كان مغلقاً
              fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          if (isUnlocked)
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
          if (!isUnlocked)
            const Icon(Icons.lock, color: Colors.white38, size: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 💡 استخدام GestureDetector لجعل العنصر قابلاً للنقر
    return GestureDetector(
      onTap: _showStreakInfoDialog, // فتح النافذة عند الضغط
      child: Container(
        padding: const EdgeInsets.all(4.0),
        color: Colors.transparent, // لجعل المساحة كلها قابلة للنقر
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "$streakCount",
              style: const TextStyle(
                  color: whiteColor, fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(width: 8),
            Image.asset(
              getStreakImagePath(),
              width: 32,
              key: ValueKey(getStreakImagePath()),
            )
          ],
        ),
      ),
    );
  }
}
