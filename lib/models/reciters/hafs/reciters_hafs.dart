import 'package:risala/main.dart';

class RecitersHafs {
  final int id;
  final String urlReciter;
  final int number;
  final String reciterName;

  RecitersHafs({
    required this.id,
    required this.urlReciter,
    required this.number,
    required this.reciterName,
  });

  factory RecitersHafs.fromMap(Map<String, dynamic> json) {
    return RecitersHafs(
      id: json['id'] ?? 0,
      urlReciter: json['base_url'] ?? "",
      number: json['number'] ?? 0,
      reciterName: json[sharedPref.getString("selectedValue") ?? "ar"]
              ?['reciter_name'] ??
          '',
    );
  }
}
