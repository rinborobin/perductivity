import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../core/database/database.dart';
import '../models/ai_plan.dart';

class AiPlannerClient {
  final String apiKey;
  final String modelName;
  final http.Client? _httpClient;

  AiPlannerClient({
    required this.apiKey,
    this.modelName = 'gemini-2.5-flash',
    this._httpClient,
  });

  Future<List<AiDayPlan>> generatePlan({
    required String scheduleText,
    required DateTime monthStart,
    required DateTime monthEnd,
    List<int>? pdfBytes,
  }) async {
    final model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      httpClient: _httpClient,
      systemInstruction: Content.system(_systemInstruction),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: _schema,
      ),
    );

    final prompt = _buildPrompt(scheduleText, monthStart, monthEnd);
    final content = pdfBytes != null
        ? Content.multi([
            TextPart(prompt),
            DataPart('application/pdf', Uint8List.fromList(pdfBytes)),
          ])
        : Content.text(prompt);

    try {
      final response = await model.generateContent([content]);
      final text = response.text;
      if (text == null || text.trim().isEmpty) {
        throw AiPlannerException('The AI did not return a plan.');
      }
      return parsePlan(text);
    } catch (error) {
      if (error is AiPlannerException) rethrow;
      final message = error.toString().replaceFirst('Exception: ', '');
      throw AiPlannerException('Generation failed: $message');
    }
  }

  List<AiDayPlan> parsePlan(String text) {
    final decoded = jsonDecode(text) as Map<String, dynamic>;
    final days = (decoded['days'] as List?) ?? [];
    return days.map((day) {
      final dateStr = day['date'] as String? ?? '';
      final date = DateTime.tryParse(dateStr) ?? DateTime.now();
      final tasksRaw = (day['tasks'] as List?) ?? [];
      final tasks = tasksRaw.map((task) {
        final priorityStr = (task['priority'] as String? ?? 'medium')
            .toLowerCase();
        final priority = TaskPriority.values.firstWhere(
          (p) => p.name == priorityStr,
          orElse: () => TaskPriority.medium,
        );
        final subtasksRaw = (task['subtasks'] as List?) ?? [];
        return AiPlanTask(
          title: (task['title'] as String? ?? 'Untitled task').trim(),
          description: task['description'] as String?,
          priority: priority,
          subtasks: subtasksRaw
              .whereType<String>()
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList(),
        );
      }).toList();
      return AiDayPlan(date: date, tasks: tasks);
    }).toList();
  }

  String _buildPrompt(
    String scheduleText,
    DateTime monthStart,
    DateTime monthEnd,
  ) {
    final range = '${_format(monthStart)} to ${_format(monthEnd)}';
    return '''
Plan range: $range
Today: ${_format(DateTime.now())}

Source schedule and notes:
$scheduleText

Create a realistic day-by-day plan for the range above. Spread the work across days, don't put everything on one day, and break larger assignments into smaller sequenced steps. Each task should have a sensible priority. Use the local date for each day.
''';
  }

  String _format(DateTime date) =>
      '${date.year}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static const _systemInstruction = '''
You are a personal productivity planner. You receive a monthly schedule (events with due dates) and/or free-form notes, and you produce a structured day-by-day to-do plan.

Rules:
- Output strictly the requested JSON schema. No extra text.
- Group tasks under their planned day using the "date" field (YYYY-MM-DD).
- Provide a full daily list for each day that has work, not just one flat list.
- Break large assignments into multiple smaller tasks across preceding days.
- Each task has: title, optional description, priority ("low"|"medium"|"high"), and a list of subtasks (may be empty).
''';

  static final _schema = Schema(
    SchemaType.object,
    properties: {
      'days': Schema(
        SchemaType.array,
        items: Schema(
          SchemaType.object,
          properties: {
            'date': Schema(SchemaType.string),
            'tasks': Schema(
              SchemaType.array,
              items: Schema(
                SchemaType.object,
                properties: {
                  'title': Schema(SchemaType.string),
                  'description': Schema(SchemaType.string, nullable: true),
                  'priority': Schema(SchemaType.string),
                  'subtasks': Schema(
                    SchemaType.array,
                    items: Schema(SchemaType.string),
                  ),
                },
                requiredProperties: ['title', 'priority', 'subtasks'],
              ),
            ),
          },
          requiredProperties: ['date', 'tasks'],
        ),
      ),
    },
  );
}

class AiPlannerException implements Exception {
  final String message;

  AiPlannerException(this.message);

  @override
  String toString() => message;
}
