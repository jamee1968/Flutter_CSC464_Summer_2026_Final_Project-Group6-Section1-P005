import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:attendance_routine_app/models/attendance_model.dart';
import 'package:attendance_routine_app/utility/firebase_constant.dart';

class AttendanceProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _attendanceRef(String courseId) {
    return _firestore
        .collection(FirebaseConstant.coursesCollection)
        .doc(courseId)
        .collection(FirebaseConstant.attendanceSubcollection);
  }

  Future<AttendanceModel?> getAttendanceForDate(String courseId, DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final startOfDay = normalizedDate;
    final endOfDay = normalizedDate.add(const Duration(days: 1));

    final snapshot = await _attendanceRef(courseId)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThan: endOfDay)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    final record = AttendanceModel.fromJson(doc.data() as Map<String, dynamic>);
    record.docId = doc.id;
    return record;
  }

  Future<void> saveAttendance(String courseId, AttendanceModel attendance) async {
    final normalizedDate = DateTime(
      attendance.date!.year,
      attendance.date!.month,
      attendance.date!.day,
    );
    attendance.date = normalizedDate;

    final startOfDay = normalizedDate;
    final endOfDay = normalizedDate.add(const Duration(days: 1));

    final existing = await _attendanceRef(courseId)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThan: endOfDay)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      final docId = existing.docs.first.id;
      await _attendanceRef(courseId).doc(docId).update(attendance.toJson());
    } else {
      final response = await _attendanceRef(courseId).add(attendance.toJson());
      await response.update({'docId': response.id});
    }

    notifyListeners();
  }

  Stream<List<AttendanceModel>> streamAttendanceHistory(String courseId) {
    return _attendanceRef(courseId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final attendance =
                  AttendanceModel.fromJson(doc.data() as Map<String, dynamic>);
              attendance.docId = doc.id;
              return attendance;
            }).toList());
  }

  Map<String, dynamic> computeSummary(
      String studentId, List<AttendanceModel> allAttendance) {
    final totalClasses = allAttendance.length;
    final attended = allAttendance
        .where((a) => a.records?[studentId] == 'Present')
        .length;
    final percentage =
        totalClasses == 0 ? 0.0 : (attended / totalClasses) * 100;

    return {
      'totalClasses': totalClasses,
      'attended': attended,
      'percentage': percentage,
    };
  }
}