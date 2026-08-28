import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/widgets/app_action_button.dart';
import '../../../../shared/widgets/app_surface.dart';
import '../../data/datasource/moodle_api_client.dart';
import '../../data/datasource/moodle_ical_client.dart';
import '../../data/models/moodle_models.dart';
import '../../data/repositories/moodle_repository_impl.dart';
import '../../domain/repositories/moodle_ical_repository.dart';
import '../providers/moodle_providers.dart';

class MoodleSettingsScreen extends ConsumerStatefulWidget {
  const MoodleSettingsScreen({super.key});

  @override
  ConsumerState<MoodleSettingsScreen> createState() =>
      _MoodleSettingsScreenState();
}

class _MoodleSettingsScreenState extends ConsumerState<MoodleSettingsScreen> {
  static const _defaultMoodleUrl = 'https://elearning.cadt.edu.kh';

  late final TextEditingController _urlController;
  late final TextEditingController _tokenController;
  late final TextEditingController _icalUrlController;
  MoodleSiteInfo? _siteInfo;
  List<MoodleCourse> _courses = [];
  List<MoodleAssignment> _assignments = [];
  bool _loading = true;
  bool _connecting = false;
  bool _importing = false;
  String? _error;
  MoodleCalendarImportResult? _importResult;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: _defaultMoodleUrl);
    _tokenController = TextEditingController();
    _icalUrlController = TextEditingController();
    _icalUrlController.addListener(() => setState(() {}));
    _loadSavedCredentials();
    _loadSavedIcalUrl();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _tokenController.dispose();
    _icalUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moodle')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            'Connect your learning space',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Preview courses and assignments from Moodle without changing your local tasks.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSurface(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.school_outlined,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'You need a Moodle web-service token. Perductivity stores it securely on this device and never displays it after entry.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connection details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _urlController,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Moodle site URL',
                    hintText: 'https://moodle.example.edu',
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _tokenController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Web-service token',
                    hintText: 'Paste your Moodle token',
                    prefixIcon: Icon(Icons.key_outlined),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_hasSavedCredentials)
                      AppActionButton(
                        primary: false,
                        label: 'Disconnect',
                        onPressed: _disconnect,
                      ),
                    if (_hasSavedCredentials)
                      const SizedBox(width: AppSpacing.sm),
                    AppActionButton(
                      label: _connecting ? 'Connecting...' : 'Test connection',
                      icon: _connecting ? null : Icons.sync,
                      onPressed: _connecting ? null : _connect,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calendar import',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Paste your Moodle iCal export URL to import events as tasks in the app calendar.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _icalUrlController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Moodle iCal URL',
                    hintText:
                        'https://moodle.example.edu/calendar/export_execute.php?...',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_icalUrlController.text.isNotEmpty)
                      AppActionButton(
                        primary: false,
                        label: 'Clear URL',
                        onPressed: _clearIcalUrl,
                      ),
                    if (_icalUrlController.text.isNotEmpty)
                      const SizedBox(width: AppSpacing.sm),
                    AppActionButton(
                      label: _importing ? 'Importing...' : 'Import calendar',
                      icon: _importing ? null : Icons.download_outlined,
                      onPressed: _importing ? null : _importCalendar,
                    ),
                  ],
                ),
                if (_importResult != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Imported ${_importResult!.imported} events '
                    '(${_importResult!.created} new, ${_importResult!.updated} updated).',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_loading) ...[
            const SizedBox(height: AppSpacing.lg),
            const Center(child: CircularProgressIndicator()),
          ],
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppSurface(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_siteInfo != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildConnectionSummary(context),
            const SizedBox(height: AppSpacing.lg),
            _buildCourses(context),
            const SizedBox(height: AppSpacing.lg),
            _buildAssignments(context),
          ],
        ],
      ),
    );
  }

  bool get _hasSavedCredentials => _tokenController.text.isNotEmpty;

  Future<void> _loadSavedCredentials() async {
    final credentials = await ref.read(moodleCredentialStoreProvider).read();
    if (!mounted) return;
    if (credentials != null) {
      _urlController.text = credentials.baseUrl;
      _tokenController.text = credentials.token;
    }
    setState(() => _loading = false);
  }

  Future<void> _connect() async {
    final baseUrl = _urlController.text.trim();
    final token = _tokenController.text.trim();
    if (baseUrl.isEmpty || token.isEmpty) {
      setState(
        () => _error = 'Enter both the Moodle URL and web-service token.',
      );
      return;
    }

    setState(() {
      _connecting = true;
      _error = null;
    });

    final credentials = MoodleCredentials(baseUrl: baseUrl, token: token);
    final client = MoodleApiClient(credentials);
    try {
      final repository = MoodleRepositoryImpl(client);
      final siteInfo = await repository.getSiteInfo();
      final courses = await repository.getCourses(userId: siteInfo.userId);
      final assignments = await repository.getAssignments(
        courseIds: courses.map((course) => course.id).toList(),
      );
      await ref.read(moodleCredentialStoreProvider).save(credentials);
      if (!mounted) return;
      setState(() {
        _siteInfo = siteInfo;
        _courses = courses;
        _assignments = assignments;
        _connecting = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is MoodleApiException
            ? error.message
            : 'Could not connect to Moodle. Check the URL and token.';
        _connecting = false;
      });
    } finally {
      client.close();
    }
  }

  Future<void> _disconnect() async {
    await ref.read(moodleCredentialStoreProvider).clear();
    if (!mounted) return;
    setState(() {
      _siteInfo = null;
      _courses = [];
      _assignments = [];
      _tokenController.clear();
      _error = null;
    });
  }

  Future<void> _loadSavedIcalUrl() async {
    final url = await ref.read(moodleCredentialStoreProvider).readIcalUrl();
    if (!mounted) return;
    if (url != null) {
      _icalUrlController.text = url;
    }
  }

  Future<void> _importCalendar() async {
    final url = _icalUrlController.text.trim();
    if (url.isEmpty) {
      setState(() => _error = 'Enter the Moodle iCal export URL.');
      return;
    }

    setState(() {
      _importing = true;
      _error = null;
      _importResult = null;
    });

    try {
      final repository = ref.read(moodleIcalRepositoryProvider);
      final result = await repository.importCalendar(url);
      await ref.read(moodleCredentialStoreProvider).saveIcalUrl(url);
      if (!mounted) return;
      setState(() {
        _importResult = result;
        _importing = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is MoodleIcalException
            ? error.message
            : 'Could not import the Moodle calendar. Check the URL.';
        _importing = false;
      });
    }
  }

  Future<void> _clearIcalUrl() async {
    await ref.read(moodleCredentialStoreProvider).clearIcalUrl();
    if (!mounted) return;
    setState(() {
      _icalUrlController.clear();
      _importResult = null;
      _error = null;
    });
  }

  Widget _buildConnectionSummary(BuildContext context) {
    return AppSurface(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.check,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _siteInfo!.siteName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_siteInfo!.fullName}  |  Moodle ${_siteInfo!.version}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourses(BuildContext context) {
    return _buildCollection(
      context,
      title: 'Courses',
      count: _courses.length,
      emptyMessage: 'No enrolled courses were returned.',
      children: _courses
          .map(
            (course) => _MoodleRow(
              icon: Icons.menu_book_outlined,
              title: course.fullName,
              subtitle: course.shortName,
            ),
          )
          .toList(),
    );
  }

  Widget _buildAssignments(BuildContext context) {
    return _buildCollection(
      context,
      title: 'Assignments preview',
      count: _assignments.length,
      emptyMessage: 'No assignments were returned by Moodle.',
      children: _assignments
          .map(
            (assignment) => _MoodleRow(
              icon: Icons.assignment_outlined,
              title: assignment.name,
              subtitle: assignment.dueDate == null
                  ? 'No due date'
                  : 'Due ${assignment.dueDate!.day}/${assignment.dueDate!.month}/${assignment.dueDate!.year}',
            ),
          )
          .toList(),
    );
  }

  Widget _buildCollection(
    BuildContext context, {
    required String title,
    required int count,
    required String emptyMessage,
    required List<Widget> children,
  }) {
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                count.toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (children.isEmpty)
            Text(
              emptyMessage,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          else
            ...children,
        ],
      ),
    );
  }
}

class _MoodleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MoodleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
