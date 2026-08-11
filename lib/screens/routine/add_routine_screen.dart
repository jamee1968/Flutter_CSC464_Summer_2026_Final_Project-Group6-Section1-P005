import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendance_routine_app/models/course_model.dart';
import 'package:attendance_routine_app/models/routine_model.dart';
import 'package:attendance_routine_app/providers/course_provider.dart';
import 'package:attendance_routine_app/providers/routine_provider.dart';

class AddRoutineScreen extends StatefulWidget {
  final RoutineModel? routine; // null = Add, non-null = Edit

  const AddRoutineScreen({super.key, this.routine});

  @override
  State<AddRoutineScreen> createState() => _AddRoutineScreenState();
}

class _AddRoutineScreenState extends State<AddRoutineScreen> {
  final formKey = GlobalKey<FormState>();

  String? selectedCourseId;
  String? selectedDay;
  TimeOfDay? selectedTime;

  bool get isEditing => widget.routine != null;

  static const List<String> days = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ];

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      selectedCourseId = widget.routine?.courseId;
      selectedDay = widget.routine?.day;
      selectedTime = _parseTimeString(widget.routine?.time);
    }
  }

  TimeOfDay? _parseTimeString(String? timeStr) {
    if (timeStr == null || !timeStr.contains(':')) return null;
    try {
      final parts = timeStr.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      if (parts.length > 1) {
        final period = parts[1].toUpperCase();
        if (period == 'PM' && hour < 12) hour += 12;
        if (period == 'AM' && hour == 12) hour = 0;
      }
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Colors.brown;
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final routineProvider = Provider.of<RoutineProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Routine' : 'Add Routine'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<CourseModel>>(
          stream: courseProvider.streamCourses(),
          builder: (context, snapshot) {
            final courses = snapshot.data ?? [];

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      // Course Dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Select Course',
                          prefixIcon: const Icon(Icons.book, color: primaryColor),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        value: selectedCourseId,
                        items: courses
                            .map((c) => DropdownMenuItem(
                                  value: c.docId,
                                  child: Text('${c.name ?? ''} (${c.code ?? ''})'),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => selectedCourseId = value),
                        validator: (value) => value == null ? 'Please select a course' : null,
                      ),
                      const SizedBox(height: 16),

                      // Day Dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Select Day',
                          prefixIcon: const Icon(Icons.calendar_today, color: primaryColor),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        value: selectedDay,
                        items: days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                        onChanged: (value) => setState(() => selectedDay = value),
                        validator: (value) => value == null ? 'Please select a day' : null,
                      ),
                      const SizedBox(height: 16),

                      // Time Picker Field
                      FormField<TimeOfDay>(
                        validator: (_) => selectedTime == null ? 'Please pick a time' : null,
                        builder: (state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () async {
                                  await _pickTime();
                                  state.didChange(selectedTime);
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Select Class Time',
                                    prefixIcon: const Icon(Icons.access_time, color: primaryColor),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    errorText: state.errorText,
                                  ),
                                  child: Text(
                                    selectedTime != null
                                        ? selectedTime!.format(context)
                                        : 'Tap to select time',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: selectedTime != null ? Colors.black87 : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;

                            final newRoutine = RoutineModel(
                              docId: widget.routine?.docId,
                              courseId: selectedCourseId,
                              day: selectedDay,
                              time: selectedTime!.format(context),
                            );

                            if (isEditing) {
                              await routineProvider.editRoutine(widget.routine!.docId!, newRoutine);
                            } else {
                              await routineProvider.addRoutine(newRoutine);
                            }

                            if (context.mounted) Navigator.of(context).pop();
                          },
                          child: Text(
                            isEditing ? 'Save Changes' : 'Save Routine Slot',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}