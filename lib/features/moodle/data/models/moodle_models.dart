class MoodleCredentials {
  final String baseUrl;
  final String token;

  const MoodleCredentials({required this.baseUrl, required this.token});
}

class MoodleSiteInfo {
  final int userId;
  final String fullName;
  final String siteName;
  final String version;

  const MoodleSiteInfo({
    required this.userId,
    required this.fullName,
    required this.siteName,
    required this.version,
  });

  factory MoodleSiteInfo.fromJson(Map<String, dynamic> json) {
    return MoodleSiteInfo(
      userId: _asInt(json['userid']),
      fullName: _asString(json['fullname']),
      siteName: _asString(json['sitename']),
      version: _asString(json['release']),
    );
  }
}

class MoodleCourse {
  final int id;
  final String fullName;
  final String shortName;
  final String summary;

  const MoodleCourse({
    required this.id,
    required this.fullName,
    required this.shortName,
    required this.summary,
  });

  factory MoodleCourse.fromJson(Map<String, dynamic> json) {
    return MoodleCourse(
      id: _asInt(json['id']),
      fullName: _asString(json['fullname']),
      shortName: _asString(json['shortname']),
      summary: _asString(json['summary']),
    );
  }
}

class MoodleAssignment {
  final int id;
  final int courseId;
  final String name;
  final String description;
  final DateTime? dueDate;

  const MoodleAssignment({
    required this.id,
    required this.courseId,
    required this.name,
    required this.description,
    required this.dueDate,
  });

  factory MoodleAssignment.fromJson(
    Map<String, dynamic> json, {
    required int courseId,
  }) {
    final dueTimestamp = _asInt(json['duedate']);
    return MoodleAssignment(
      id: _asInt(json['id']),
      courseId: courseId,
      name: _asString(json['name']),
      description: _asString(json['intro']),
      dueDate: dueTimestamp > 0
          ? DateTime.fromMillisecondsSinceEpoch(dueTimestamp * 1000)
          : null,
    );
  }
}

String _asString(Object? value) => value?.toString() ?? '';

int _asInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
