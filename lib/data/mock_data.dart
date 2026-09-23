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
}

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
}

const mockCourses = [
  Course(
    id: 1,
    name: 'Course 1',
    teacher: 'Teacher 1',
    room: 'room 1',
    weekday: 'Monday',
    startTime: '08:00',
  ),
  Course(
    id: 2,
    name: 'Course 2',
    teacher: 'Teacher 2',
    room: 'room 2',
    weekday: 'Monday',
    startTime: '11:30',
  ),
  Course(
    id: 3,
    name: 'Course 3',
    teacher: 'Teacher 3',
    room: 'room 3',
    weekday: 'Tuesday',
    startTime: '09:45',
  ),
  Course(
    id: 4,
    name: 'Course 4',
    teacher: 'Teacher 4',
    room: 'room 4',
    weekday: 'Tuesday',
    startTime: '13:15',
  ),
  Course(
    id: 5,
    name: 'Course 5',
    teacher: 'Teacher 5',
    room: 'room 5',
    weekday: 'Wednesday',
    startTime: '08:00',
  ),
  Course(
    id: 6,
    name: 'Course 6',
    teacher: 'Teacher 6',
    room: 'room 6',
    weekday: 'Wednesday',
    startTime: '11:30',
  ),
  Course(
    id: 7,
    name: 'Course 7',
    teacher: 'Teacher 7',
    room: 'room 7',
    weekday: 'Thursday',
    startTime: '09:45',
  ),
  Course(
    id: 8,
    name: 'Course 8',
    teacher: 'Teacher 8',
    room: 'room 8',
    weekday: 'Friday',
    startTime: '13:15',
  ),
];

const mockAssignments = [
  Assignment(
    id: 1,
    courseId: 1,
    title: 'Assignment 1',
    deadline: '28.09.2026',
    status: 'In progress',
    priority: 'High',
  ),
  Assignment(
    id: 2,
    courseId: 2,
    title: 'Assignment 2',
    deadline: '30.09.2026',
    status: 'New',
    priority: 'Medium',
  ),
  Assignment(
    id: 3,
    courseId: 3,
    title: 'Assignment 3',
    deadline: '02.10.2026',
    status: 'New',
    priority: 'High',
  ),
  Assignment(
    id: 4,
    courseId: 4,
    title: 'Assignment 4',
    deadline: '04.10.2026',
    status: 'Completed',
    priority: 'Medium',
  ),
  Assignment(
    id: 5,
    courseId: 5,
    title: 'Assignment 5',
    deadline: '06.10.2026',
    status: 'In progress',
    priority: 'Low',
  ),
  Assignment(
    id: 6,
    courseId: 6,
    title: 'Assignment 6',
    deadline: '08.10.2026',
    status: 'New',
    priority: 'Medium',
  ),
  Assignment(
    id: 7,
    courseId: 7,
    title: 'Assignment 7',
    deadline: '10.10.2026',
    status: 'New',
    priority: 'High',
  ),
  Assignment(
    id: 8,
    courseId: 8,
    title: 'Assignment 8',
    deadline: '12.10.2026',
    status: 'New',
    priority: 'Medium',
  ),
];