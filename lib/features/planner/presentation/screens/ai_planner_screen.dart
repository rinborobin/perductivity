import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/widgets/app_action_button.dart';
import '../../../../shared/widgets/app_surface.dart';
import '../../../../features/tasks/domain/entities/task_entity.dart';
import '../../../../features/tasks/presentation/providers/task_list_provider.dart';
import '../../../../features/tasks/presentation/providers/task_providers.dart';
import '../../../moodle/presentation/providers/moodle_providers.dart';
import '../../../moodle/data/datasource/moodle_ical_client.dart';
import '../../data/datasource/ai_planner_client.dart';
import '../../data/datasource/planner_input_loader.dart';
import '../../data/models/ai_plan.dart';
import '../../data/storage/ai_settings_store.dart';
import '../providers/ai_planner_providers.dart';

class AiPlannerScreen extends ConsumerStatefulWidget {
  const AiPlannerScreen({super.key});

  @override
  ConsumerState<AiPlannerScreen> createState() => _AiPlannerScreenState();
}

class _AiPlannerScreenState extends ConsumerState<AiPlannerScreen> {
  final _apiKeyController = TextEditingController();
  final _modelController = TextEditingController();
  final _planController = TextEditingController();
  final _icalController = TextEditingController();
  bool _includeEvents = true;
  bool _savingSettings = false;
  bool _generating = false;
  bool _importing = false;
  bool _attaching = false;
  String? _error;
  String? _success;
  String? _pdfName;
  Uint8List? _pdfBytes;
  String? _mdText;
  String? _mdName;
  List<AiDayPlan> _plan = [];
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadSavedIcalUrl();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _modelController.dispose();
    _planController.dispose();
    _icalController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final store = ref.read(aiSettingsStoreProvider);
    final apiKey = await store.readApiKey();
    final model = await store.readModel();
    if (!mounted) return;
    _apiKeyController.text = apiKey ?? '';
    _modelController.text = model;
  }

  Future<void> _loadSavedIcalUrl() async {
    final url = await ref.read(moodleCredentialStoreProvider).readIcalUrl();
    if (!mounted) return;
    if (url != null) {
      _icalController.text = url;
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _savingSettings = true);
    final store = ref.read(aiSettingsStoreProvider);
    await store.saveApiKey(_apiKeyController.text);
    await store.saveModel(
      _modelController.text.isNotEmpty
          ? _modelController.text
          : AiSettingsStore.defaultModel,
    );
    if (!mounted) return;
    setState(() => _savingSettings = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('AI settings saved')));
  }

  String _eventsToText(List<TaskEntity> events) {
    final now = DateTime.now();
    final monthTasks = events
        .where(
          (t) =>
              t.dueDate != null &&
              t.dueDate!.year == now.year &&
              t.dueDate!.month == now.month,
        )
        .toList();
    if (monthTasks.isEmpty) return '';
    final buffer = StringBuffer();
    buffer.writeln('Imported events/tasks this month:');
    for (final task in monthTasks) {
      final due = DateFormat('yyyy-MM-dd').format(task.dueDate!);
      buffer.writeln('- ${task.title} (due $due)');
    }
    return buffer.toString().trim();
  }

  String _truncate(String text, {int maxChars = 200000}) {
    if (text.length <= maxChars) return text;
    return '${text.substring(0, maxChars)}\n\n[truncated]';
  }

  Future<void> _generate() async {
    final buffer = StringBuffer();

    try {
      if (_includeEvents) {
        final events = await ref.read(taskRepositoryProvider).getAllTasks();
        final eventsText = _eventsToText(events);
        if (eventsText.isNotEmpty) buffer.writeln(eventsText);
      }

      final icalUrl = _icalController.text.trim();
      if (icalUrl.isNotEmpty) {
        final icalText = await PlannerInputLoader().loadMoodleIcalEvents(
          icalUrl,
        );
        if (icalText.isNotEmpty) buffer.writeln(icalText);
      }

      if (_pdfBytes != null && _pdfBytes!.isNotEmpty) {
        buffer.writeln('Syllabus (PDF): see the attached PDF file.');
      }

      if (_mdText != null && _mdText!.isNotEmpty) {
        buffer.writeln('Notes (Markdown):');
        buffer.writeln(_truncate(_mdText!));
      }

      final pasted = _planController.text.trim();
      if (pasted.isNotEmpty) {
        buffer.writeln('Extra notes:');
        buffer.writeln(pasted);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is MoodleIcalException
            ? 'Moodle calendar link: ${error.message}'
            : 'Could not read the inputs.';
        _generating = false;
      });
      return;
    }

    final scheduleText = buffer.toString().trim();
    if (scheduleText.isEmpty) {
      setState(
        () => _error =
            'Add a pasted plan, a Moodle link, or attach a file first.',
      );
      return;
    }

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    setState(() {
      _generating = true;
      _error = null;
      _success = null;
      _plan = [];
      _selected.clear();
    });

    try {
      final repository = ref.read(aiPlannerRepositoryProvider);
      final plan = await repository.generatePlan(
        scheduleText: scheduleText,
        monthStart: monthStart,
        monthEnd: monthEnd,
        pdfBytes: _pdfBytes,
      );
      if (!mounted) return;
      if (plan.isEmpty) {
        setState(() {
          _error = 'The AI did not return a plan. Try adding more detail.';
          _generating = false;
        });
        return;
      }
      setState(() {
        _plan = plan;
        for (var d = 0; d < plan.length; d++) {
          for (var t = 0; t < plan[d].tasks.length; t++) {
            _selected.add('$d:$t');
          }
        }
        _generating = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is AiPlannerException
            ? error.message
            : 'Could not generate a plan. Check your API key and connection.';
        _generating = false;
      });
    }
  }

  Future<void> _attachPdf() async {
    setState(() => _attaching = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null) {
        final bytes = await PlannerInputLoader().loadPdfBytes(
          File(result.files.single.path!),
        );
        if (!mounted) return;
        setState(() {
          _pdfBytes = bytes;
          _pdfName = result.files.single.name;
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Could not read the PDF file.');
    } finally {
      if (mounted) setState(() => _attaching = false);
    }
  }

  Future<void> _attachMarkdown() async {
    setState(() => _attaching = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['md', 'markdown', 'txt'],
      );
      if (result != null && result.files.single.path != null) {
        final text = await PlannerInputLoader().loadMarkdownText(
          File(result.files.single.path!),
        );
        if (!mounted) return;
        setState(() {
          _mdText = text;
          _mdName = result.files.single.name;
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Could not read the Markdown file.');
    } finally {
      if (mounted) setState(() => _attaching = false);
    }
  }

  Future<void> _confirmSelected() async {
    final selectedDays = <AiDayPlan>[];
    for (var d = 0; d < _plan.length; d++) {
      final tasks = <AiPlanTask>[];
      for (var t = 0; t < _plan[d].tasks.length; t++) {
        if (_selected.contains('$d:$t')) {
          tasks.add(_plan[d].tasks[t]);
        }
      }
      if (tasks.isNotEmpty) {
        selectedDays.add(AiDayPlan(date: _plan[d].date, tasks: tasks));
      }
    }

    if (selectedDays.isEmpty) {
      setState(() => _error = 'Select at least one task to add.');
      return;
    }

    setState(() {
      _importing = true;
      _error = null;
    });

    try {
      final repository = ref.read(aiPlannerRepositoryProvider);
      final count = await repository.importDayPlans(selectedDays);
      await ref.read(taskListProvider.notifier).loadTasks();
      if (!mounted) return;
      setState(() {
        _importing = false;
        _success = 'Added $count tasks to your calendar.';
        _plan = [];
        _selected.clear();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is AiPlannerException
            ? error.message
            : 'Could not save the selected tasks.';
        _importing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Planner')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _buildSettingsCard(context),
          const SizedBox(height: AppSpacing.lg),
          _buildInputCard(context),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppSurface(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
          if (_success != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppSurface(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                _success!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
          if (_generating) ...[
            const SizedBox(height: AppSpacing.lg),
            const Center(child: CircularProgressIndicator()),
          ],
          if (_plan.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildPlanPreview(context),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI settings',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Uses Google Gemini. Your key is stored securely on this device.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _apiKeyController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Gemini API key',
              hintText: 'Paste your API key',
              prefixIcon: Icon(Icons.key_outlined),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _modelController,
            decoration: const InputDecoration(
              labelText: 'Model',
              hintText: 'gemini-2.5-flash',
              prefixIcon: Icon(Icons.smart_toy_outlined),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: AppActionButton(
              label: _savingSettings ? 'Saving...' : 'Save settings',
              onPressed: _savingSettings ? null : _saveSettings,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard(BuildContext context) {
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plan input',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Include imported events this month'),
            value: _includeEvents,
            onChanged: (value) =>
                setState(() => _includeEvents = value ?? true),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _icalController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Moodle calendar link (iCal URL)',
              hintText: 'https://moodle.../calendar/export_execute.php?...',
              prefixIcon: Icon(Icons.link),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppActionButton(
                label: _attaching ? 'Reading...' : 'Attach syllabus (PDF)',
                icon: Icons.picture_as_pdf_outlined,
                onPressed: _attaching ? null : _attachPdf,
              ),
              AppActionButton(
                label: _attaching ? 'Reading...' : 'Attach Markdown',
                icon: Icons.description_outlined,
                onPressed: _attaching ? null : _attachMarkdown,
              ),
            ],
          ),
          if (_pdfName != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                'PDF attached: $_pdfName (${(_pdfBytes?.length ?? 0)} bytes) — sent to the model',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                ),
              ),
            ),
          if (_mdName != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                'Markdown attached: $_mdName (${_mdText?.length ?? 0} chars)',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _planController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Extra notes or context',
              hintText: 'e.g. I study best in the morning, keep weekends light',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: AppActionButton(
              label: _generating ? 'Generating...' : 'Generate plan',
              icon: _generating ? null : Icons.auto_awesome,
              onPressed: _generating ? null : _generate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanPreview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Generated daily plan',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (_selected.length == _plan.length) {
                    _selected.clear();
                  } else {
                    _selected.clear();
                    for (var d = 0; d < _plan.length; d++) {
                      for (var t = 0; t < _plan[d].tasks.length; t++) {
                        _selected.add('$d:$t');
                      }
                    }
                  }
                });
              },
              child: Text(
                _selected.length == _countTasks() ? 'Clear all' : 'Select all',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ..._plan.asMap().entries.map((entry) {
          final dayIndex = entry.key;
          final day = entry.value;
          return _DaySection(
            date: day.date,
            tasks: day.tasks,
            dayIndex: dayIndex,
            selected: _selected,
            onToggle: (taskIndex, value) {
              setState(() {
                final key = '$dayIndex:$taskIndex';
                if (value) {
                  _selected.add(key);
                } else {
                  _selected.remove(key);
                }
              });
            },
          );
        }),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.centerRight,
          child: AppActionButton(
            label: _importing ? 'Adding...' : 'Confirm selected',
            icon: _importing ? null : Icons.check,
            onPressed: _importing ? null : _confirmSelected,
          ),
        ),
      ],
    );
  }

  int _countTasks() {
    var total = 0;
    for (final day in _plan) {
      total += day.tasks.length;
    }
    return total;
  }
}

class _DaySection extends StatelessWidget {
  final DateTime date;
  final List<AiPlanTask> tasks;
  final int dayIndex;
  final Set<String> selected;
  final void Function(int taskIndex, bool value) onToggle;

  const _DaySection({
    required this.date,
    required this.tasks,
    required this.dayIndex,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEE, MMM d').format(date),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...tasks.asMap().entries.map((taskEntry) {
            final taskIndex = taskEntry.key;
            final task = taskEntry.value;
            final isSelected = selected.contains('$dayIndex:$taskIndex');
            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: isSelected,
              onChanged: (value) => onToggle(taskIndex, value ?? false),
              title: Text(task.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.description != null && task.description!.isNotEmpty)
                    Text(
                      task.description!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (task.subtasks.isNotEmpty)
                    ...task.subtasks.map(
                      (sub) => Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.md),
                        child: Text(
                          '• $sub',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
