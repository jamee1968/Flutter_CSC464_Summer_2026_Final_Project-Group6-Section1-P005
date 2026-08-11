import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendance_routine_app/models/attendance_model.dart';
import 'package:attendance_routine_app/models/course_model.dart';
import 'package:attendance_routine_app/models/student_model.dart';
import 'package:attendance_routine_app/providers/attendance_provider.dart';
import 'package:attendance_routine_app/providers/student_provider.dart';

class MarkAttendanceScreen extends StatefulWidget {
  final CourseModel course;

  const MarkAttendanceScreen({super.key, required this.course});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  DateTime selectedDate = DateTime.now();
  final Map<String, String> attendanceStatus = {};
  bool isEditingExisting = false;
  bool isLoadingExisting = false;

  late AttendanceProvider attendanceProvider;
  late Stream<List<StudentModel>> studentsStream;

  @override
  void initState() {
    super.initState();
    attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    studentsStream = Provider.of<StudentProvider>(context, listen: false)
        .streamStudents(widget.course.docId!);
    _loadExistingForDate();
  }

  Future<void> _loadExistingForDate() async {
    setState(() => isLoadingExisting = true);

    final existing =
        await attendanceProvider.getAttendanceForDate(widget.course.docId!, selectedDate);

    setState(() {
      attendanceStatus.clear();
      if (existing != null) {
        isEditingExisting = true;
        attendanceStatus.addAll(existing.records ?? {});
      } else {
        isEditingExisting = false;
      }
      isLoadingExisting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.course.code} - Mark Attendance'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: widget.course.createdAt ?? DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                      await _loadExistingForDate();
                    }
                  },
                  child: const Text('Change Date'),
                ),
              ],
            ),
          ),
          if (isEditingExisting)
            Container(
              width: double.infinity,
              color: Colors.orange.shade100,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: const Text(
                'Attendance already recorded - Updating attendance.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          Expanded(
            child: isLoadingExisting
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<List<StudentModel>>(
                    stream: studentsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final students = snapshot.data ?? [];
                      if (students.isEmpty) {
                        return const Center(child: Text('No students enrolled in this course.'));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          final docId = student.docId!;
                          attendanceStatus.putIfAbsent(docId, () => 'Absent');
                          final isPresent = attendanceStatus[docId] == 'Present';

                          return Card(
                            child: ListTile(
                              title: Text(student.name ?? ''),
                              subtitle: Text('ID: ${student.studentId ?? ''}'),
                              trailing: Switch(
                                value: isPresent,
                                activeColor: Colors.green,
                                onChanged: (value) {
                                  setState(() {
                                    attendanceStatus[docId] = value ? 'Present' : 'Absent';
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown, foregroundColor: Colors.white),
                onPressed: () async {
                  final attendance = AttendanceModel(
                    date: selectedDate,
                    records: attendanceStatus,
                  );
                  await attendanceProvider.saveAttendance(widget.course.docId!, attendance);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEditingExisting
                          ? 'Attendance updated!'
                          : 'Attendance saved!')),
                    );
                    Navigator.of(context).pop();
                  }
                },
                child: Text(isEditingExisting ? 'Update Attendance' : 'Save Attendance'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}