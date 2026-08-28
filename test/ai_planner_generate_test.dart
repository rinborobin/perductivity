import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:perductivity/features/planner/data/datasource/ai_planner_client.dart';

String _geminiResponse(String innerJson) => jsonEncode({
  'candidates': [
    {
      'content': {
        'parts': [
          {'text': innerJson},
        ],
      },
    },
  ],
});

void main() {
  test('generatePlan parses a real Gemini-style JSON response', () async {
    final planJson = jsonEncode({
      'days': [
        {
          'date': '2026-09-01',
          'tasks': [
            {
              'title': 'Read chapter 1',
              'description': 'Intro',
              'priority': 'medium',
              'subtasks': ['Skim', 'Note'],
            },
          ],
        },
      ],
    });

    final client = AiPlannerClient(
      apiKey: 'test-key',
      modelName: 'gemini-2.5-flash',
      httpClient: MockClient((request) async {
        expect(
          request.url.path,
          contains('/models/gemini-2.5-flash:generateContent'),
        );
        expect(request.headers['x-goog-api-key'], 'test-key');
        return http.Response(_geminiResponse(planJson), 200);
      }),
    );

    final plan = await client.generatePlan(
      scheduleText:
          'Imported events this month:\n- Assignment (due 2026-09-05)',
      monthStart: DateTime(2026, 9, 1),
      monthEnd: DateTime(2026, 9, 30),
    );

    expect(plan, hasLength(1));
    expect(plan.first.date, DateTime(2026, 9, 1));
    expect(plan.first.tasks.first.title, 'Read chapter 1');
    expect(plan.first.tasks.first.subtasks, ['Skim', 'Note']);
  });

  test('generatePlan throws when the API returns an error status', () async {
    final client = AiPlannerClient(
      apiKey: 'test-key',
      httpClient: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'error': {'message': 'bad key'},
          }),
          400,
        ),
      ),
    );

    expect(
      () => client.generatePlan(
        scheduleText: 'notes',
        monthStart: DateTime(2026, 9, 1),
        monthEnd: DateTime(2026, 9, 30),
      ),
      throwsA(isA<AiPlannerException>()),
    );
  });
}
