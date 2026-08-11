import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendance_routine_app/models/attendance_model.dart';
import 'package:attendance_routine_app/models/course_model.dart';
import 'package:attendance_routine_app/providers/attendance_provider.dart';
import 'package:attendance_routine_app/models/student_model.dart';
import 'package:attendance_routine_app/providers/student_provider.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  final CourseModel course;

  const AttendanceHistoryScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('${course.code} - Attendance History'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<AttendanceModel>>(
        stream: attendanceProvider.streamAttendanceHistory(course.docId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No attendance records yet.'));
          }

          final records = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final presentCount =
                  record.records?.values.where((v) => v == 'Present').length ?? 0;
              final totalCount = record.records?.length ?? 0;

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.event_available, color: Colors.brown),
                  title: Text(
                    record.date != null
                        ? '${record.date!.day}/${record.date!.month}/${record.date!.year}'
                        : 'Unknown date',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('$presentCount / $totalCount present'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Attendance Details'),
                        content: SizedBox(
                        width: double.maxFinite,
                          child: StreamBuilder<List<StudentModel>>(
                            stream: studentProvider.streamStudents(course.docId!),
                            builder: (context, studentSnapshot) {
                              if (studentSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              final students = studentSnapshot.data ?? [];
                              final studentMap = {for (var s in students) s.docId: s};
                              final entries = record.records?.entries.toList() ?? [];

                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: entries.length,
                                itemBuilder: (context, i) {
                                  final entry = entries[i];
                                  final student = studentMap[entry.key];

                                  return ListTile(
                                    title: Text(student?.name ?? 'Unknown Student'),
                                    subtitle: student?.studentId != null ? Text('ID: ${student!.studentId}') : null,
                                    trailing: Text(
                                      entry.value,
                                      style: TextStyle(
                                        color: entry.value == 'Present' ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}