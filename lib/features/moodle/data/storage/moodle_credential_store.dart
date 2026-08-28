import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/moodle_models.dart';

class MoodleCredentialStore {
  static const _baseUrlKey = 'moodle_base_url';
  static const _tokenKey = 'moodle_token';
  static const _icalUrlKey = 'moodle_ical_url';

  final FlutterSecureStorage _storage;

  MoodleCredentialStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<MoodleCredentials?> read() async {
    final baseUrl = await _storage.read(key: _baseUrlKey);
    final token = await _storage.read(key: _tokenKey);
    if (baseUrl == null || token == null || baseUrl.isEmpty || token.isEmpty) {
      return null;
    }
    return MoodleCredentials(baseUrl: baseUrl, token: token);
  }

  Future<void> save(MoodleCredentials credentials) async {
    await _storage.write(key: _baseUrlKey, value: credentials.baseUrl);
    await _storage.write(key: _tokenKey, value: credentials.token);
  }

  Future<void> clear() async {
    await _storage.delete(key: _baseUrlKey);
    await _storage.delete(key: _tokenKey);
  }

  Future<String?> readIcalUrl() async {
    final value = await _storage.read(key: _icalUrlKey);
    return value?.isNotEmpty == true ? value : null;
  }

  Future<void> saveIcalUrl(String url) async {
    await _storage.write(key: _icalUrlKey, value: url);
  }

  Future<void> clearIcalUrl() async {
    await _storage.delete(key: _icalUrlKey);
  }
}
