class Reciters {
  int id;
  String reciterName;

  Reciters({
    required this.id,
    required this.reciterName,
  });

  factory Reciters.fromMap(Map<String, dynamic> json) =>
      Reciters(id: json["id"] ?? 0, reciterName: json["reciter_name"] ?? "");
}
