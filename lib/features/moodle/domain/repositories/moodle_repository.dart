import '../../data/models/moodle_models.dart';

abstract class MoodleRepository {
  Future<MoodleSiteInfo> getSiteInfo();
  Future<List<MoodleCourse>> getCourses({required int userId});
  Future<List<MoodleAssignment>> getAssignments({required List<int> courseIds});
}
