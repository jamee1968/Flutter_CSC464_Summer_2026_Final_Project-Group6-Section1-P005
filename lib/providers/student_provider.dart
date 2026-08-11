import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:attendance_routine_app/models/student_model.dart';
import 'package:attendance_routine_app/utility/firebase_constant.dart';

class StudentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _studentsRef(String courseId) {
    return _firestore
        .collection(FirebaseConstant.coursesCollection)
        .doc(courseId)
        .collection(FirebaseConstant.studentsSubcollection);
  }

  // Returns null on success, or an error message string if the ID is a duplicate.
  Future<String?> addStudent(String courseId, StudentModel student) async {
    final duplicateCheck = await _studentsRef(courseId)
        .where('studentId', isEqualTo: student.studentId)
        .limit(1)
        .get();

    if (duplicateCheck.docs.isNotEmpty) {
      return 'A student with this ID already exists in this course.';
    }

    final response = await _studentsRef(courseId).add(student.toJson());
    await response.update({'docId': response.id});
    notifyListeners();
    return null;
  }

  // Returns null on success, or an error message string if the new ID conflicts with a different student.
  Future<String?> editStudent(String courseId, String docId, StudentModel student) async {
    final duplicateCheck = await _studentsRef(courseId)
        .where('studentId', isEqualTo: student.studentId)
        .get();

    final conflictsWithOther = duplicateCheck.docs.any((doc) => doc.id != docId);

    if (conflictsWithOther) {
      return 'A student with this ID already exists in this course.';
    }

    await _studentsRef(courseId).doc(docId).update(student.toJson());
    notifyListeners();
    return null;
  }

  Future<void> removeStudent(String courseId, String docId) async {
    await _studentsRef(courseId).doc(docId).delete();
    notifyListeners();
  }

  Stream<List<StudentModel>> streamStudents(String courseId) {
    return _studentsRef(courseId)
        .orderBy('studentId', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final student =
                  StudentModel.fromJson(doc.data() as Map<String, dynamic>);
              student.docId = doc.id;
              return student;
            }).toList());
  }
}