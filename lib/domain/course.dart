class Course {
  final int id;
  final String name;
  final String teacher;
  final String room;
  final String weekday;
  final String startTime;

  const Course({
    required this.id,
    required this.name,
    required this.teacher,
    required this.room,
    required this.weekday,
    required this.startTime,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int,
      name: json['name'] as String,
      teacher: json['teacher'] as String,
      room: json['room'] as String,
      weekday: json['weekday'] as String,
      startTime: json['startTime'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'teacher': teacher,
      'room': room,
      'weekday': weekday,
      'startTime': startTime,
    };
  }
}
