import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendance_routine_app/models/course_model.dart';
import 'package:attendance_routine_app/providers/course_provider.dart';

class AddEditCourseScreen extends StatefulWidget {
  final CourseModel? course; // null = add mode, non-null = edit mode

  const AddEditCourseScreen({super.key, this.course});

  @override
  State<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends State<AddEditCourseScreen> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController codeController;
  bool isSaving = false;

  bool get isEditing => widget.course != null;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.course?.name ?? '');
    codeController = TextEditingController(text: widget.course?.code ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Colors.brown;
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Course' : 'Add Course'),
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
                  // Course Name
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Course Name',
                      prefixIcon: const Icon(Icons.book, color: primaryColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Enter course name' : null,
                  ),
                  const SizedBox(height: 16),

                  // Course Code
                  TextFormField(
                    controller: codeController,
                    decoration: InputDecoration(
                      labelText: 'Course Code',
                      prefixIcon: const Icon(Icons.code, color: primaryColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Enter course code' : null,
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
                      onPressed: isSaving
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;

                              setState(() => isSaving = true);

                              final course = CourseModel(
                                docId: widget.course?.docId,
                                name: nameController.text.trim(),
                                code: codeController.text.trim(),
                                createdAt: widget.course?.createdAt ?? DateTime.now(),
                              );

                              if (isEditing) {
                                await courseProvider.editCourse(widget.course!.docId!, course);
                              } else {
                                await courseProvider.addCourse(course);
                              }

                              if (context.mounted) Navigator.of(context).pop();
                            },
                      child: isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isEditing ? 'Save Changes' : 'Add Course',
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