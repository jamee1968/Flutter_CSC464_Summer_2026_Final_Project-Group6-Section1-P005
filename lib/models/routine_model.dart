class RoutineModel {
  String? docId;
  String? courseId;
  String? day;
  String? time;
  String? teacherId;

  RoutineModel({this.docId, this.courseId, this.day, this.time, this.teacherId});

  factory RoutineModel.fromJson(Map<String, dynamic> json) {
    return RoutineModel(
      courseId: json['courseId'] as String? ?? '',
      day: json['day'] as String? ?? '',
      time: json['time'] as String? ?? '',
      teacherId: json['teacherId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'day': day,
      'time': time,
      'teacherId': teacherId,
    };
  }
}