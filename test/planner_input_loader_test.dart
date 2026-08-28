import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:perductivity/features/moodle/data/models/moodle_calendar_event.dart';
import 'package:perductivity/features/planner/data/datasource/planner_input_loader.dart';

void main() {
  test('eventsToText renders due dates as YYYY-MM-DD lines', () {
    final events = [
      MoodleCalendarEvent(
        uid: 'a',
        summary: 'Assignment 1',
        startDate: DateTime(2026, 9, 5),
      ),
      MoodleCalendarEvent(
        uid: 'b',
        summary: 'Quiz',
        startDate: DateTime(2026, 9, 12, 8, 30),
      ),
    ];

    final text = PlannerInputLoader.eventsToText(events);

    expect(text, contains('Moodle calendar events:'));
    expect(text, contains('- Assignment 1 (due 2026-09-05)'));
    expect(text, contains('- Quiz (due 2026-09-12)'));
  });

  test('eventsToText returns empty string for no events', () {
    expect(PlannerInputLoader.eventsToText([]), isEmpty);
  });

  test('loadMarkdownText reads file contents', () async {
    final file = File(
      '${Directory.systemTemp.path}/plan_${DateTime.now().millisecondsSinceEpoch}.md',
    );
    await file.writeAsString('# Week 1\n- Read chapter 1');
    try {
      final loader = PlannerInputLoader();
      final text = await loader.loadMarkdownText(file);
      expect(text, contains('Read chapter 1'));
    } finally {
      await file.delete();
    }
  });
}
