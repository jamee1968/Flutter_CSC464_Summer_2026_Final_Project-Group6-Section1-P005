import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  String? docId;
  DateTime? date;
  Map<String, String>? records; // { studentId: "Present" | "Absent" }

  AttendanceModel({this.docId, this.date, this.records});

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      date: (json['date'] is Timestamp)
          ? (json['date'] as Timestamp).toDate()
          : DateTime.tryParse(json['date'] as String? ?? ''),
      records: (json['records'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value.toString())) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date, // Firestore accepts DateTime directly, stores as Timestamp
      'records': records,
    };
  }
}