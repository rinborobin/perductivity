class MoodleCalendarImportResult {
  final int imported;
  final int created;
  final int updated;

  const MoodleCalendarImportResult({
    required this.imported,
    required this.created,
    required this.updated,
  });
}

abstract class MoodleIcalRepository {
  Future<MoodleCalendarImportResult> importCalendar(String url);
}
