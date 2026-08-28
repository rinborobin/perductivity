import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/moodle_models.dart';

class MoodleApiException implements Exception {
  final String message;
  final int? statusCode;

  const MoodleApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class MoodleApiClient {
  final MoodleCredentials credentials;
  final http.Client _httpClient;

  MoodleApiClient(this.credentials, {http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  Future<MoodleSiteInfo> getSiteInfo() async {
    final response = await _request('core_webservice_get_site_info');
    return MoodleSiteInfo.fromJson(response);
  }

  Future<List<MoodleCourse>> getCourses({required int userId}) async {
    final response = await _request(
      'core_enrol_get_users_courses',
      parameters: {'userid': userId},
    );
    if (response is! List) {
      throw const MoodleApiException('Moodle returned an invalid course list.');
    }
    return response
        .whereType<Map<String, dynamic>>()
        .map(MoodleCourse.fromJson)
        .toList();
  }

  Future<List<MoodleAssignment>> getAssignments({
    required List<int> courseIds,
  }) async {
    if (courseIds.isEmpty) return [];

    final response = await _request(
      'mod_assign_get_assignments',
      parameters: {'courseids': courseIds},
    );
    if (response is! Map<String, dynamic>) {
      throw const MoodleApiException(
        'Moodle returned an invalid assignment response.',
      );
    }

    final courses = response['courses'];
    if (courses is! List) return [];

    final assignments = <MoodleAssignment>[];
    for (final course in courses.whereType<Map<String, dynamic>>()) {
      final courseId = _toInt(course['id']);
      final items = course['assignments'];
      if (items is! List) continue;
      assignments.addAll(
        items.whereType<Map<String, dynamic>>().map(
          (item) => MoodleAssignment.fromJson(item, courseId: courseId),
        ),
      );
    }
    return assignments;
  }

  Future<dynamic> _request(
    String function, {
    Map<String, dynamic> parameters = const {},
  }) async {
    final query = <String, String>{
      'wstoken': credentials.token,
      'wsfunction': function,
      'moodlewsrestformat': 'json',
    };
    _flattenParameters(parameters).forEach((key, value) {
      query[key] = value;
    });

    final endpoint = _endpoint();
    final response = await _httpClient
        .get(endpoint.replace(queryParameters: query))
        .timeout(const Duration(seconds: 20));

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw MoodleApiException(
        'Moodle returned an invalid response.',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MoodleApiException(
        'Moodle request failed with status ${response.statusCode}.',
        statusCode: response.statusCode,
      );
    }
    if (decoded is Map<String, dynamic> && decoded['exception'] != null) {
      throw MoodleApiException(
        decoded['message']?.toString() ?? 'Moodle rejected the request.',
      );
    }
    if (decoded is! Map<String, dynamic> && decoded is! List) {
      throw const MoodleApiException('Moodle returned an empty response.');
    }

    return decoded;
  }

  Uri _endpoint() {
    final base = credentials.baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    final uri = Uri.tryParse('$base/webservice/rest/server.php');
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw const MoodleApiException('Enter a valid Moodle site URL.');
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw const MoodleApiException('Moodle URL must use HTTP or HTTPS.');
    }
    return uri;
  }

  Map<String, String> _flattenParameters(Map<String, dynamic> parameters) {
    final flattened = <String, String>{};
    for (final entry in parameters.entries) {
      final value = entry.value;
      if (value is Iterable) {
        var index = 0;
        for (final item in value) {
          flattened['${entry.key}[$index]'] = item.toString();
          index++;
        }
      } else if (value != null) {
        flattened[entry.key] = value.toString();
      }
    }
    return flattened;
  }

  int _toInt(Object? value) => int.tryParse(value?.toString() ?? '') ?? 0;

  void close() => _httpClient.close();
}
