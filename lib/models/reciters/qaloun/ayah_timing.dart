class AyahTiming {
  final int ayah;
  final int startTime;
  final int endTime;

  AyahTiming(
      {required this.ayah, required this.startTime, required this.endTime});

  factory AyahTiming.fromJson(Map<String, dynamic> json) {
    return AyahTiming(
      ayah: json['ayah'],
      startTime: int.parse(json['start_time'].toString()),
      endTime: int.parse(json['end_time'].toString()),
    );
  }
}
