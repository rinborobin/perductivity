import 'package:flutter_test/flutter_test.dart';
import 'package:perductivity/features/moodle/data/datasource/moodle_ical_parser.dart';

void main() {
  const parser = MoodleIcalParser();

  test('parses an all-day event', () {
    final events = parser.parse('''
BEGIN:VCALENDAR
BEGIN:VEVENT
UID:assignment-1
SUMMARY:Project 1 due
DESCRIPTION:First project submission
DTSTART;VALUE=DATE:20250901
DTEND;VALUE=DATE:20250902
END:VEVENT
END:VCALENDAR
''');

    expect(events, hasLength(1));
    final event = events.single;
    expect(event.uid, 'assignment-1');
    expect(event.summary, 'Project 1 due');
    expect(event.description, 'First project submission');
    expect(event.startDate, DateTime(2025, 9, 1));
  });

  test('parses a UTC date-time and converts to local', () {
    final events = parser.parse('''
BEGIN:VCALENDAR
BEGIN:VEVENT
UID:quiz-2
SUMMARY:Quiz 2
DTSTART:20250901T080000Z
END:VEVENT
END:VCALENDAR
''');

    expect(events.single.startDate, isNotNull);
    expect(events.single.startDate!.isUtc, false);
  });

  test('parses a local date-time', () {
    final events = parser.parse('''
BEGIN:VCALENDAR
BEGIN:VEVENT
UID:meeting-3
SUMMARY:Team meeting
DTSTART;TZID=Asia/Phnom_Penh:20250901T080000
END:VEVENT
END:VCALENDAR
''');

    expect(events.single.startDate, DateTime(2025, 9, 1, 8, 0, 0));
  });

  test('unfolds wrapped lines', () {
    final events = parser.parse('''
BEGIN:VCALENDAR
BEGIN:VEVENT
UID:long-4
SUMMARY:Very long assignment title that is wrapped across multi
 ple lines in the ics file
DTSTART;VALUE=DATE:20250901
END:VEVENT
END:VCALENDAR
''');

    expect(
      events.single.summary,
      'Very long assignment title that is wrapped across multiple lines in the ics file',
    );
  });
}
