import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  String? docId;
  String? name;
  String? code;
  DateTime? createdAt;
  String? teacherId;

  CourseModel({this.docId, this.name, this.code, this.createdAt, this.teacherId});

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      createdAt: (json['createdAt'] is Timestamp)
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      teacherId: json['teacherId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'createdAt': createdAt ?? DateTime.now(),
      'teacherId': teacherId,
    };
  }
}