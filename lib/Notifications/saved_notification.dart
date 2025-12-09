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
    return SavedNotification(
      id: data["id"],
      title: data["title"],
      body: data["body"],
      hour: data["hour"],
      minute: data["minute"],
      days: List<String>.from(data["days"]),
    );
  }
}
