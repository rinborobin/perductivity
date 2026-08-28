import 'package:flutter_test/flutter_test.dart';
import 'package:perductivity/features/planner/data/datasource/ai_planner_client.dart';

void main() {
  final client = AiPlannerClient(apiKey: 'test', modelName: 'gemini-2.5-flash');

  test('parses a day-by-day plan with subtasks', () {
    const json = '''
    {
      "days": [
        {
          "date": "2026-09-01",
          "tasks": [
            {
              "title": "Read chapter 1",
              "description": "Intro reading",
              "priority": "medium",
              "subtasks": ["Skim sections", "Take notes"]
            }
          ]
        },
        {
          "date": "2026-09-03",
          "tasks": [
            {
              "title": "Draft outline",
              "priority": "high",
              "subtasks": []
            }
          ]
        }
      ]
    }
    ''';

    final plan = client.parsePlan(json);

    expect(plan, hasLength(2));
    expect(plan[0].date, DateTime(2026, 9, 1));
    expect(plan[0].tasks, hasLength(1));
    expect(plan[0].tasks.first.title, 'Read chapter 1');
    expect(plan[0].tasks.first.subtasks, ['Skim sections', 'Take notes']);
    expect(plan[1].date, DateTime(2026, 9, 3));
    expect(plan[1].tasks.first.priority.name, 'high');
  });

  test('defaults missing priority to medium and tolerates absent fields', () {
    const json = '''
    {
      "days": [
        {
          "date": "2026-09-02",
          "tasks": [{"title": "Vague task"}]
        }
      ]
    }
    ''';

    final plan = client.parsePlan(json);

    expect(plan.single.tasks.single.priority.name, 'medium');
    expect(plan.single.tasks.single.subtasks, isEmpty);
  });
}
