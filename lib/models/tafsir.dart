class Tafsir {
  final int surah;
  final int ayah;
  final String tafsir;

  Tafsir({
    required this.surah,
    required this.ayah,
    required this.tafsir,
  });

  factory Tafsir.fromJson(Map<String, dynamic> json) {
    return Tafsir(
      surah: json['surah'],
      ayah: json['ayah'],
      tafsir: json['tafsir']['al-mukhtasar'],
    );
  }
}
