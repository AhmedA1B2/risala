import 'package:risala/main.dart';

class RecitersQaloun {
  final String id;
  final String urlReciter;
  final int number;
  final String reciterName;

  RecitersQaloun({
    required this.id,
    required this.urlReciter,
    required this.number,
    required this.reciterName,
  });

  factory RecitersQaloun.fromMap(Map<String, dynamic> json) {
    return RecitersQaloun(
      id: json['id'] ?? "",
      urlReciter: json['base_url'] ?? "",
      number: json['number'] ?? 0,
      reciterName: json[sharedPref.getString("selectedValue") ?? "ar"]
              ?['reciter_name'] ??
          '',
    );
  }
}
