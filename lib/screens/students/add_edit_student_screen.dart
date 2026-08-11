import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:attendance_routine_app/models/course_model.dart';
import 'package:attendance_routine_app/models/student_model.dart';
import 'package:attendance_routine_app/providers/student_provider.dart';

class AddEditStudentScreen extends StatefulWidget {
  final CourseModel course;
  final StudentModel? student;

  const AddEditStudentScreen({super.key, required this.course, this.student});

  @override
  State<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends State<AddEditStudentScreen> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController studentIdController;

  bool isSaving = false;

  bool get isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.student?.name ?? '');
    studentIdController = TextEditingController(text: widget.student?.studentId ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    studentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Colors.brown;
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Student' : 'Add Student'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  // Student Name Field
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Student Name',
                      prefixIcon: const Icon(Icons.person, color: primaryColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Enter student name' : null,
                  ),
                  const SizedBox(height: 16),

                  // Student ID Field (7 Digits)
                  TextFormField(
                    controller: studentIdController,
                    decoration: InputDecoration(
                      labelText: 'Student ID (7 digits)',
                      prefixIcon: const Icon(Icons.badge, color: primaryColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(7),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter student ID';
                      }
                      if (value.trim().length != 7) {
                        return 'Student ID must be exactly 7 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Full Width Submit Button
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
                      onPressed: isSaving
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;

                              setState(() => isSaving = true);

                              final student = StudentModel(
                                name: nameController.text.trim(),
                                studentId: studentIdController.text.trim(),
                                createdAt: widget.student?.createdAt,
                              );

                              String? error;
                              if (isEditing) {
                                error = await studentProvider.editStudent(
                                    widget.course.docId!, widget.student!.docId!, student);
                              } else {
                                error = await studentProvider.addStudent(
                                    widget.course.docId!, student);
                              }

                              setState(() => isSaving = false);

                              if (error != null) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(content: Text(error)));
                                }
                                return;
                              }

                              if (context.mounted) Navigator.of(context).pop();
                            },
                      child: isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isEditing ? 'Save Changes' : 'Add Student',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}