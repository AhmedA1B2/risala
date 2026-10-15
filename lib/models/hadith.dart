class Hadith {
  String author;
  String arabic;
  String title;
  String english;
  String narrator;
  String text;

  Hadith({
    required this.author,
    required this.arabic,
    required this.title,
    required this.english,
    required this.narrator,
    required this.text,
  });

  factory Hadith.fromMap(Map<String, dynamic> json) => Hadith(
        author: json["author"] ?? "",
        arabic: json["arabic"] ?? "",
        title: json["title"] ?? "",
        english: json["english"] ?? "",
        narrator: json["narrator"] ?? "",
        text: json["text"] ?? "",
      );
}
