class SavedNotification {
  final int id;
  final String title;
  final String body;
  final int hour;
  final int minute;
  final List<String> days;
  bool? show;

  SavedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.hour,
    required this.minute,
    required this.days,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "body": body,
      "hour": hour,
      "minute": minute,
      "days": days,
    };
  }

  factory SavedNotification.fromMap(Map data) {
    // دالة مساعدة للحصول على قيمة int بشكل آمن
    int safeInt(dynamic value) {
      if (value is int) {
        return value;
      } else if (value is String) {
        // إذا كانت القيمة سلسلة، حاول تحليلها إلى عدد صحيح
        return int.tryParse(value) ?? 0; // استخدم 0 كقيمة افتراضية إذا فشل التحويل
      }
      return 0; // القيمة الافتراضية للأنواع الأخرى
    }

    return SavedNotification(
      // استخدام الدالة المساعدة لضمان أن القيم تكون int
      id: safeInt(data["id"]),
      title: data["title"] as String,
      body: data["body"] as String,
      hour: safeInt(data["hour"]),
      minute: safeInt(data["minute"]),
      days: List<String>.from(data["days"] ?? []),
    );
  }
}