import 'package:http/http.dart' as http;
import '../models/moodle_calendar_event.dart';
import 'moodle_ical_parser.dart';

class MoodleIcalClient {
  final http.Client _httpClient;
  final MoodleIcalParser _parser;

  MoodleIcalClient({http.Client? httpClient, MoodleIcalParser? parser})
    : _httpClient = httpClient ?? http.Client(),
      _parser = parser ?? const MoodleIcalParser();

  Future<List<MoodleCalendarEvent>> fetchEvents(String url) async {
    final response = await _httpClient.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw MoodleIcalException(
        'Could not fetch Moodle calendar (${response.statusCode}).',
      );
    }
    return _parser.parse(response.body);
  }

  void close() {
    _httpClient.close();
  }
}

class MoodleIcalException implements Exception {
  final String message;

  MoodleIcalException(this.message);

  @override
  String toString() => message;
}
