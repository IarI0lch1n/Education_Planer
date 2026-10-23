class Assignment {
  final int id;
  final int courseId;
  final String title;
  final String deadline;
  final String status;
  final String priority;

  const Assignment({
    required this.id,
    required this.courseId,
    required this.title,
    required this.deadline,
    required this.status,
    required this.priority,
  });

  Assignment copyWith({
    int? id,
    int? courseId,
    String? title,
    String? deadline,
    String? status,
    String? priority,
  }) {
    return Assignment(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      priority: priority ?? this.priority,
    );
  }
}
