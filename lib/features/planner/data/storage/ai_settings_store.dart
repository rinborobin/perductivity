import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AiSettingsStore {
  static const _apiKey = 'ai_api_key';
  static const _modelKey = 'ai_model';

  static const defaultModel = 'gemini-2.5-flash';

  final FlutterSecureStorage _storage;

  AiSettingsStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<String?> readApiKey() async {
    final value = await _storage.read(key: _apiKey);
    return value?.isNotEmpty == true ? value : null;
  }

  Future<void> saveApiKey(String apiKey) async {
    await _storage.write(key: _apiKey, value: apiKey.trim());
  }

  Future<String> readModel() async {
    final value = await _storage.read(key: _modelKey);
    return value?.isNotEmpty == true ? value! : defaultModel;
  }

  Future<void> saveModel(String model) async {
    await _storage.write(key: _modelKey, value: model.trim());
  }

  Future<void> clear() async {
    await _storage.delete(key: _apiKey);
    await _storage.delete(key: _modelKey);
  }
}
