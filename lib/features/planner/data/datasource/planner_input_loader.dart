import 'dart:io';
import 'dart:typed_data';
import '../../../moodle/data/datasource/moodle_ical_client.dart';
import '../../../moodle/data/models/moodle_calendar_event.dart';

class PlannerInputLoader {
  Future<Uint8List> loadPdfBytes(File file) async {
    return file.readAsBytes();
  }

  Future<String> loadMarkdownText(File file) async {
    return file.readAsString();
  }

  Future<String> loadMoodleIcalEvents(String url) async {
    final client = MoodleIcalClient();
    try {
      final events = await client.fetchEvents(url);
      return eventsToText(events);
    } finally {
      client.close();
    }
  }

  static String eventsToText(List<MoodleCalendarEvent> events) {
    if (events.isEmpty) return '';
    final buffer = StringBuffer();
    buffer.writeln('Moodle calendar events:');
    for (final event in events) {
      final due = event.startDate != null
          ? '${event.startDate!.year}-'
                '${event.startDate!.month.toString().padLeft(2, '0')}-'
                '${event.startDate!.day.toString().padLeft(2, '0')}'
          : 'unknown date';
      buffer.writeln('- ${event.summary} (due $due)');
    }
    return buffer.toString().trim();
  }
}
