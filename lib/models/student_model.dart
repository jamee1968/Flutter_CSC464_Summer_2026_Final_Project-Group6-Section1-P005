import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  String? docId;
  String? name;
  String? studentId;
  DateTime? createdAt;

  StudentModel({this.docId, this.name, this.studentId, this.createdAt});

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      name: json['name'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      createdAt: (json['createdAt'] is Timestamp)
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'studentId': studentId,
      'createdAt': createdAt ?? DateTime.now(),
    };
  }
}