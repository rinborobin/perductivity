import 'package:equatable/equatable.dart';

class MoodleCalendarEvent extends Equatable {
  final String uid;
  final String summary;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? location;

  const MoodleCalendarEvent({
    required this.uid,
    required this.summary,
    this.description,
    this.startDate,
    this.endDate,
    this.location,
  });

  @override
  List<Object?> get props => [
    uid,
    summary,
    description,
    startDate,
    endDate,
    location,
  ];
}
