import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendance_routine_app/models/attendance_model.dart';
import 'package:attendance_routine_app/models/course_model.dart';
import 'package:attendance_routine_app/models/student_model.dart';
import 'package:attendance_routine_app/providers/attendance_provider.dart';
import 'package:attendance_routine_app/providers/student_provider.dart';

class AttendanceSummaryScreen extends StatelessWidget {
  final CourseModel course;

  const AttendanceSummaryScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('${course.code} - Attendance Summary'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<AttendanceModel>>(
        stream: attendanceProvider.streamAttendanceHistory(course.docId!),
        builder: (context, attendanceSnapshot) {
          final allAttendance = attendanceSnapshot.data ?? [];

          return StreamBuilder<List<StudentModel>>(
            stream: studentProvider.streamStudents(course.docId!),
            builder: (context, studentSnapshot) {
              if (studentSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final students = studentSnapshot.data ?? [];
              if (students.isEmpty) {
                return const Center(child: Text('No students enrolled yet.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  final summary =
                      attendanceProvider.computeSummary(student.docId!, allAttendance);

                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(student.name ?? ''),
                      subtitle: Text(
                          'Attended: ${summary['attended']} / ${summary['totalClasses']} classes'),
                      trailing: Text(
                        '${(summary['percentage'] as double).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: (summary['percentage'] as double) >= 75
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}