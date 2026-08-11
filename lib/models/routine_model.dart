class RoutineModel {
  String? docId;
  String? courseId;
  String? day;   // Sunday, Monday...
  String? time;  // 10:00 AM

  RoutineModel({this.docId, this.courseId, this.day, this.time});

  factory RoutineModel.fromJson(Map<String, dynamic> json) {
    return RoutineModel(
      courseId: json['courseId'] as String? ?? '',
      day: json['day'] as String? ?? '',
      time: json['time'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'day': day,
      'time': time,
    };
  }
}