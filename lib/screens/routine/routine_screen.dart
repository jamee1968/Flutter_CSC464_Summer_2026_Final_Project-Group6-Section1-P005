import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendance_routine_app/models/course_model.dart';
import 'package:attendance_routine_app/models/routine_model.dart';
import 'package:attendance_routine_app/providers/course_provider.dart';
import 'package:attendance_routine_app/providers/routine_provider.dart';
import 'package:attendance_routine_app/screens/routine/add_routine_screen.dart';

class RoutineScreen extends StatelessWidget {
  const RoutineScreen({super.key});

  static const List<String> dayOrder = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ];

  @override
  Widget build(BuildContext context) {
    const primaryColor = Colors.brown;
    final routineProvider = Provider.of<RoutineProvider>(context, listen: false);
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Weekly Routine'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<CourseModel>>(
        stream: courseProvider.streamCourses(),
        builder: (context, courseSnapshot) {
          final courseNameById = {
            for (final c in courseSnapshot.data ?? <CourseModel>[])
              if (c.docId != null) c.docId!: '${c.name ?? 'Unknown'} (${c.code ?? ''})'
          };

          return StreamBuilder<List<RoutineModel>>(
            stream: routineProvider.streamRoutine(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: primaryColor));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No routine entries yet.'));
              }

              final grouped = routineProvider.groupByDay(snapshot.data!);
              final days = dayOrder.where((d) => grouped.containsKey(d)).toList();

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index];
                  final entries = grouped[day]!;

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            day,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: primaryColor,
                            ),
                          ),
                          const Divider(),
                          ...entries.map((r) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.access_time, color: primaryColor),
                                title: Text(
                                  r.time ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  courseNameById[r.courseId] ?? 'Unknown course',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                trailing: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => AddRoutineScreen(routine: r),
                                        ),
                                      );
                                    } else if (value == 'delete') {
                                      if (r.docId != null) {
                                        await routineProvider.deleteRoutine(r.docId!);
                                      }
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, color: primaryColor, size: 20),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                          SizedBox(width: 8),
                                          Text('Delete', style: TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddRoutineScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}