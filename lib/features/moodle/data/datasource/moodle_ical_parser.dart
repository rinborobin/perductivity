import '../models/moodle_calendar_event.dart';

class MoodleIcalParser {
  const MoodleIcalParser();

  List<MoodleCalendarEvent> parse(String icsData) {
    final normalized = _unfoldLines(icsData.trim());
    final lines = normalized.split('\n');
    final events = <MoodleCalendarEvent>[];

    var inEvent = false;
    String? uid;
    String? summary;
    String? description;
    String? location;
    String? dtStart;
    String? dtEnd;

    for (final line in lines) {
      if (line == 'BEGIN:VEVENT') {
        inEvent = true;
        uid = null;
        summary = null;
        description = null;
        location = null;
        dtStart = null;
        dtEnd = null;
        continue;
      }

      if (line == 'END:VEVENT') {
        if (inEvent && uid != null && summary != null) {
          events.add(
            MoodleCalendarEvent(
              uid: uid,
              summary: _unescape(summary),
              description: description != null ? _unescape(description) : null,
              startDate: _parseDateTime(dtStart),
              endDate: _parseDateTime(dtEnd),
              location: location != null ? _unescape(location) : null,
            ),
          );
        }
        inEvent = false;
        continue;
      }

      if (!inEvent) continue;

      final separatorIndex = line.indexOf(':');
      if (separatorIndex == -1) continue;

      final property = line.substring(0, separatorIndex);
      final value = line.substring(separatorIndex + 1);

      final propertyName = property.split(';').first;

      switch (propertyName) {
        case 'UID':
          uid = value;
        case 'SUMMARY':
          summary = value;
        case 'DESCRIPTION':
          description = value;
        case 'LOCATION':
          location = value;
        case 'DTSTART':
          dtStart = value;
        case 'DTEND':
          dtEnd = value;
      }
    }

    return events;
  }

  String _unfoldLines(String input) {
    return input
        .replaceAll('\r\n ', '')
        .replaceAll('\r\n\t', '')
        .replaceAll('\n ', '');
  }

  String _unescape(String value) {
    return value
        .replaceAll('\\n', '\n')
        .replaceAll('\\,', ',')
        .replaceAll('\\;', ';')
        .replaceAll('\\\\', '\\');
  }

  DateTime? _parseDateTime(String? value) {
    if (value == null || value.isEmpty) return null;

    final cleaned = value.trim();

    if (cleaned.length == 8) {
      final year = int.tryParse(cleaned.substring(0, 4));
      final month = int.tryParse(cleaned.substring(4, 6));
      final day = int.tryParse(cleaned.substring(6, 8));
      if (year != null && month != null && day != null) {
        return DateTime(year, month, day);
      }
      return null;
    }

    String digits;
    final isUtc = cleaned.endsWith('Z');
    if (isUtc) {
      digits = cleaned.substring(0, cleaned.length - 1);
    } else {
      digits = cleaned;
    }

    if (digits.length != 15 || digits[8] != 'T') return null;

    final year = int.tryParse(digits.substring(0, 4));
    final month = int.tryParse(digits.substring(4, 6));
    final day = int.tryParse(digits.substring(6, 8));
    final hour = int.tryParse(digits.substring(9, 11));
    final minute = int.tryParse(digits.substring(11, 13));
    final second = int.tryParse(digits.substring(13, 15));

    if (year == null ||
        month == null ||
        day == null ||
        hour == null ||
        minute == null ||
        second == null) {
      return null;
    }

    if (isUtc) {
      return DateTime.utc(year, month, day, hour, minute, second).toLocal();
    }
    return DateTime(year, month, day, hour, minute, second);
  }
}
