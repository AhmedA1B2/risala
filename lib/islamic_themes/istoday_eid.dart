bool isToDatEid(DateTime now) {
  final Set<String> specialDays = {
    "2026-5-27",
    "2026-5-28",
    "2026-5-29",
  };

  final key = "${now.year}-${now.month}-${now.day}";
  return specialDays.contains(key);
}
