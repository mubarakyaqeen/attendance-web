class DashboardModel {

  final int students;
  final int lecturers;
  final int courses;
  final int sessions;

  DashboardModel({
    required this.students,
    required this.lecturers,
    required this.courses,
    required this.sessions,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {

    return DashboardModel(
      students: json['students'],
      lecturers: json['lecturers'],
      courses: json['courses'],
      sessions: json['sessions'],
    );

  }
}