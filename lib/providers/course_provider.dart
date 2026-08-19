import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:attendance_routine_app/models/course_model.dart';
import 'package:attendance_routine_app/utility/firebase_constant.dart';

class CourseProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _currentTeacherId => FirebaseAuth.instance.currentUser?.uid;
  CollectionReference get _coursesRef =>
      _firestore.collection(FirebaseConstant.coursesCollection);

  Future<String?> addCourse(CourseModel course) async {
    final duplicateCheck = await _coursesRef
        .where('teacherId', isEqualTo: _currentTeacherId)
        .where('code', isEqualTo: course.code)
        .limit(1)
        .get();

    if (duplicateCheck.docs.isNotEmpty) {
      return 'A course with this code already exists.';
    }

    course.teacherId = _currentTeacherId;

    final response = await _coursesRef.add(course.toJson());
    await response.update({'docId': response.id});
    notifyListeners();
    return null;
  }

  Future<String?> editCourse(String docId, CourseModel course) async {
    final duplicateCheck = await _coursesRef
        .where('teacherId', isEqualTo: _currentTeacherId)
        .where('code', isEqualTo: course.code)
        .get();

    final conflictsWithOther = duplicateCheck.docs.any((doc) => doc.id != docId);

    if (conflictsWithOther) {
      return 'A course with this code already exists.';
    }

    course.teacherId ??= _currentTeacherId;
    await _coursesRef.doc(docId).update(course.toJson());
    notifyListeners();
    return null;
  }

  Future<void> deleteCourse(String docId) async {
    await _firestore
        .collection(FirebaseConstant.coursesCollection)
        .doc(docId)
        .delete();
    notifyListeners();
  }

  Stream<List<CourseModel>> streamCourses() {
    return _firestore
        .collection(FirebaseConstant.coursesCollection)
        .where('teacherId', isEqualTo: _currentTeacherId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final course = CourseModel.fromJson(doc.data());
              course.docId = doc.id;
              return course;
            }).toList());
  }
}