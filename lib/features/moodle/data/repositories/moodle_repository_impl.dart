import '../../domain/repositories/moodle_repository.dart';
import '../datasource/moodle_api_client.dart';
import '../models/moodle_models.dart';

class MoodleRepositoryImpl implements MoodleRepository {
  final MoodleApiClient _client;

  MoodleRepositoryImpl(this._client);

  @override
  Future<MoodleSiteInfo> getSiteInfo() => _client.getSiteInfo();

  @override
  Future<List<MoodleCourse>> getCourses({required int userId}) {
    return _client.getCourses(userId: userId);
  }

  @override
  Future<List<MoodleAssignment>> getAssignments({
    required List<int> courseIds,
  }) {
    return _client.getAssignments(courseIds: courseIds);
  }
}
