class Quran {
  final int surahNumber;
  final int verseNumber;
  final String content;

  Quran({
    required this.surahNumber,
    required this.verseNumber,
    required this.content,
  });

  factory Quran.fromMap(Map<String, dynamic> json) {
    return Quran(
      surahNumber: json['surah_number'] ?? 0,
      verseNumber: json['verse_number'] ?? 0,
      content: json['content'] ?? '',
    );
  }
}
