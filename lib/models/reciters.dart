import 'package:risala/main.dart';

class Reciters {
  final int id;
  final int number;
  final String reciterName;

  Reciters({
    required this.id,
    required this.number,
    required this.reciterName,
  });

  factory Reciters.fromMap(Map<String, dynamic> json) {
    return Reciters(
      id: json['id'] ?? 0,
      number: json['number'] ?? 0,
      reciterName: json[sharedPref.getString("selectedValue") ?? "ar"]
              ?['reciter_name'] ??
          '',
    );
  }
}
