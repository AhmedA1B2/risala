class Surah {
  int number;
  String name;
  String englishName;
  String englishNameTranslation;
  int numberOfAyahs;
  String revelationType;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });

  factory Surah.fromMap(Map<String, dynamic> json) => Surah(
        number: json["number"] ?? 0,
        name: json["name"] ?? "",
        englishName: json["englishName"] ?? "",
        englishNameTranslation: json["englishNameTranslation"] ?? "",
        numberOfAyahs: json["numberOfAyahs"] ?? 0,
        revelationType: json["revelationType"] ?? "",
      );
}
