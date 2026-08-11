import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:attendance_routine_app/models/routine_model.dart';
import 'package:attendance_routine_app/utility/firebase_constant.dart';

class RoutineProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _currentTeacherId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> addRoutine(RoutineModel routine) async {
    routine.teacherId = _currentTeacherId;

    final response = await _firestore
        .collection(FirebaseConstant.routineCollection)
        .add(routine.toJson());
    await response.update({'docId': response.id});
    notifyListeners();
  }

  Future<void> editRoutine(String docId, RoutineModel routine) async {
    routine.teacherId ??= _currentTeacherId;
    await _firestore
        .collection(FirebaseConstant.routineCollection)
        .doc(docId)
        .update(routine.toJson());
    notifyListeners();
  }

  Future<void> deleteRoutine(String docId) async {
    await _firestore
        .collection(FirebaseConstant.routineCollection)
        .doc(docId)
        .delete();
    notifyListeners();
  }

  Stream<List<RoutineModel>> streamRoutine() {
    return _firestore
        .collection(FirebaseConstant.routineCollection)
        .where('teacherId', isEqualTo: _currentTeacherId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final routine = RoutineModel.fromJson(doc.data());
              routine.docId = doc.id;
              return routine;
            }).toList());
  }

  Map<String, List<RoutineModel>> groupByDay(List<RoutineModel> routines) {
    final Map<String, List<RoutineModel>> grouped = {};
    for (final r in routines) {
      final day = r.day ?? 'Unknown';
      grouped.putIfAbsent(day, () => []).add(r);
    }
    return grouped;
  }
}