import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendance_routine_app/models/course_model.dart';
import 'package:attendance_routine_app/models/routine_model.dart';
import 'package:attendance_routine_app/providers/routine_provider.dart';
import '../students/student_list_screen.dart';
import '../attendance/mark_attendance_screen.dart';
import '../attendance/attendance_history_screen.dart';
import '../attendance/attendance_summary_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  final CourseModel course;

  const CourseDetailScreen({super.key, required this.course});

  static const List<String> dayOrder = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  void _showCourseScheduleBottomSheet(BuildContext context, CourseModel course) {
    final routineProvider = Provider.of<RoutineProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: Colors.brown, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${course.code ?? ''} Schedule',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Filtered Routine Stream for this specific course
              StreamBuilder<List<RoutineModel>>(
                stream: routineProvider.streamRoutine(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final allSchedules = snapshot.data ?? [];
                  final schedules = allSchedules
                      .where((item) => item.courseId == course.docId)
                      .toList()
                    ..sort((a, b) => dayOrder
                        .indexOf(a.day ?? '')
                        .compareTo(dayOrder.indexOf(b.day ?? '')));

                  if (schedules.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Text(
                          'No routine scheduled for this course yet.',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      final item = schedules[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_filled, color: Colors.brown, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              '${item.day} - ${item.time}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${course.code ?? ''} - ${course.name ?? ''}'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Course Schedule',
            onPressed: () {
              _showCourseScheduleBottomSheet(context, course);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HubTile(
            icon: Icons.people,
            title: 'Students',
            subtitle: 'View and manage enrolled students',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => StudentListScreen(course: course),
              ),
            ),
          ),
          _HubTile(
            icon: Icons.checklist,
            title: 'Mark Attendance',
            subtitle: 'Take attendance for a chosen date',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MarkAttendanceScreen(course: course),
              ),
            ),
          ),
          _HubTile(
            icon: Icons.history,
            title: 'Attendance History',
            subtitle: 'View past attendance records',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AttendanceHistoryScreen(course: course),
              ),
            ),
          ),
          _HubTile(
            icon: Icons.percent,
            title: 'Attendance Summary',
            subtitle: 'Total classes and attendance % per student',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AttendanceSummaryScreen(course: course),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HubTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.brown,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}