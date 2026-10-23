import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../domain/assignment.dart';
import '../models/assignment_model.dart';
import '../models/course_model.dart';
import '../widgets/error_view.dart';

class AssignmentFormScreen extends StatefulWidget {
  const AssignmentFormScreen({super.key});

  @override
  State<AssignmentFormScreen> createState() => _AssignmentFormScreenState();
}

class _AssignmentFormScreenState extends State<AssignmentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _deadlineController = TextEditingController();

  int? _courseId;
  String? _priority;
  String _status = 'New';

  DateTime? _deadline;

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _deadlineController.dispose();

    super.dispose();
  }

  Future<void> _selectDeadline() async {
    final now = DateTime.now();

    final firstAllowedDate = DateTime(now.year, now.month, now.day + 1);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: firstAllowedDate,
      firstDate: firstAllowedDate,
      lastDate: DateTime(now.year + 3, now.month, now.day),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _deadline = selectedDate;

      _deadlineController.text =
          '${selectedDate.day.toString().padLeft(2, '0')}.'
          '${selectedDate.month.toString().padLeft(2, '0')}.'
          '${selectedDate.year}';
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final draft = Assignment(
      id: 0,
      courseId: _courseId!,
      title: _titleController.text.trim(),
      deadline: _deadlineController.text,
      status: _status,
      priority: _priority!,
    );

    final error = await context.read<AssignmentModel>().add(draft);

    if (!mounted) {
      return;
    }

    if (error != null) {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Assignment "${draft.title}" created successfully.'),
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final courseModel = context.watch<CourseModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('New assignment')),
      body: _buildBody(context, theme, colorScheme, courseModel),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    CourseModel courseModel,
  ) {
    if (courseModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (courseModel.error != null) {
      return ErrorView(
        message: courseModel.error!,
        onRetry: () {
          context.read<CourseModel>().load();
        },
      );
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Assignment details',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Fill in the information below.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 24),

          TextFormField(
            controller: _titleController,
            enabled: !_isSaving,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'Assignment title',
              prefixIcon: Icon(Icons.assignment_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Title is required';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<int>(
            initialValue: _courseId,
            decoration: const InputDecoration(
              labelText: 'Course',
              prefixIcon: Icon(Icons.menu_book_outlined),
            ),
            items: courseModel.courses
                .map(
                  (course) => DropdownMenuItem<int>(
                    value: course.id,
                    child: Text(course.name),
                  ),
                )
                .toList(),
            onChanged: _isSaving
                ? null
                : (value) {
                    setState(() {
                      _courseId = value;
                    });
                  },
            validator: (value) {
              if (value == null) {
                return 'Course is required';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _deadlineController,
            readOnly: true,
            enabled: !_isSaving,
            onTap: _isSaving ? null : _selectDeadline,
            decoration: const InputDecoration(
              labelText: 'Deadline',
              hintText: 'Select deadline',
              prefixIcon: Icon(Icons.calendar_today_outlined),
              suffixIcon: Icon(Icons.arrow_drop_down),
            ),
            validator: (value) {
              if (_deadline == null) {
                return 'Deadline is required';
              }

              final now = DateTime.now();

              final today = DateTime(now.year, now.month, now.day);

              if (!_deadline!.isAfter(today)) {
                return 'Deadline must be in the future';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _priority,
            decoration: const InputDecoration(
              labelText: 'Priority',
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            items: const [
              DropdownMenuItem(value: 'Low', child: Text('Low')),
              DropdownMenuItem(value: 'Medium', child: Text('Medium')),
              DropdownMenuItem(value: 'High', child: Text('High')),
            ],
            onChanged: _isSaving
                ? null
                : (value) {
                    setState(() {
                      _priority = value;
                    });
                  },
            validator: (value) {
              if (value == null) {
                return 'Priority is required';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(
              labelText: 'Status',
              prefixIcon: Icon(Icons.task_alt_outlined),
            ),
            items: const [
              DropdownMenuItem(value: 'New', child: Text('New')),
              DropdownMenuItem(
                value: 'In progress',
                child: Text('In progress'),
              ),
              DropdownMenuItem(value: 'Completed', child: Text('Completed')),
            ],
            onChanged: _isSaving
                ? null
                : (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _status = value;
                    });
                  },
          ),

          const SizedBox(height: 28),

          FilledButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_isSaving ? 'Saving...' : 'Save assignment'),
          ),

          const SizedBox(height: 10),

          OutlinedButton(
            onPressed: _isSaving
                ? null
                : () {
                    context.pop();
                  },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
