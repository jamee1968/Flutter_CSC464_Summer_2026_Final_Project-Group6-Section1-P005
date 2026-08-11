import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:attendance_routine_app/models/course_model.dart';
import 'package:attendance_routine_app/utility/firebase_constant.dart';

class CourseProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _currentTeacherId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> addCourse(CourseModel course) async {
    course.teacherId = _currentTeacherId;

    final response = await _firestore
        .collection(FirebaseConstant.coursesCollection)
        .add(course.toJson());
    await response.update({'docId': response.id});
    notifyListeners();
  }

  Future<void> editCourse(String docId, CourseModel course) async {
    course.teacherId ??= _currentTeacherId; // preserve original owner
    await _firestore
        .collection(FirebaseConstant.coursesCollection)
        .doc(docId)
        .update(course.toJson());
    notifyListeners();
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