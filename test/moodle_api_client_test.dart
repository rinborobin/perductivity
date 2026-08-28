import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:perductivity/features/moodle/data/datasource/moodle_api_client.dart';
import 'package:perductivity/features/moodle/data/models/moodle_models.dart';

void main() {
  test('loads site information from the Moodle REST endpoint', () async {
    final client = MoodleApiClient(
      const MoodleCredentials(
        baseUrl: 'https://moodle.example.edu/',
        token: 'test-token',
      ),
      httpClient: MockClient((request) async {
        expect(request.url.path, '/webservice/rest/server.php');
        expect(
          request.url.queryParameters['wsfunction'],
          'core_webservice_get_site_info',
        );
        expect(request.url.queryParameters['wstoken'], 'test-token');
        return http.Response(
          jsonEncode({
            'userid': 42,
            'fullname': 'Robin Lee',
            'sitename': 'Example Moodle',
            'release': '5.0',
          }),
          200,
        );
      }),
    );

    final result = await client.getSiteInfo();
    client.close();

    expect(result.userId, 42);
    expect(result.siteName, 'Example Moodle');
  });

  test('parses assignments and Unix timestamps', () async {
    final client = MoodleApiClient(
      const MoodleCredentials(
        baseUrl: 'https://moodle.example.edu',
        token: 'test-token',
      ),
      httpClient: MockClient((request) async {
        return http.Response(
          jsonEncode({
            'courses': [
              {
                'id': 7,
                'assignments': [
                  {
                    'id': 9,
                    'name': 'Flutter project',
                    'intro': '<p>Build the app</p>',
                    'duedate': 1798329600,
                  },
                ],
              },
            ],
          }),
          200,
        );
      }),
    );

    final result = await client.getAssignments(courseIds: [7]);
    client.close();

    expect(result, hasLength(1));
    expect(result.single.courseId, 7);
    expect(result.single.name, 'Flutter project');
    expect(result.single.dueDate, isNotNull);
  });
}
