class StudentDashboardModel {

  final String fullName;
  final String matricNumber;

  final int? sessionId;
  final String? courseCode;
  final String? courseTitle;
  final String? lecturerName;
  final int? courseId;
  final bool alreadyMarked;

  final int radius;

  final List<String> courses;

  final String? startedAt;
  final int durationMinutes;

  StudentDashboardModel({
    required this.fullName,
    required this.matricNumber,
    required this.sessionId,
    required this.courseCode,
    required this.courseTitle,
    required this.lecturerName,
    required this.radius,
    required this.courses,
    this.courseId,
    required this.alreadyMarked,
    this.startedAt,
    required this.durationMinutes,
  });

  factory StudentDashboardModel.fromJson(Map<String, dynamic> json) {
    return StudentDashboardModel(
      fullName: json["fullName"],
      matricNumber: json["matricNumber"],

      sessionId: json["sessionId"] != null ? json["sessionId"] as int : null,
      courseCode: json["courseCode"],
      courseId: json["courseId"] != null ? json["courseId"] as int : null,
      courseTitle: json["courseTitle"],
      lecturerName: json["lecturerName"],

      radius: json["radius"] ?? 0,

      courses: List<String>.from(json["courses"] ?? []),

      alreadyMarked: json["alreadyMarked"] ?? false,

      startedAt: json["startedAt"],
      durationMinutes: json["durationMinutes"] ?? 0,
    );
  }


  // factory StudentDashboardModel.fromJson(Map<String, dynamic> json) {
  //
  //   return StudentDashboardModel(
  //
  //     fullName: json["fullName"],
  //     matricNumber: json["matricNumber"],
  //
  //     sessionId: json["sessionId"],
  //     courseCode: json["courseCode"],
  //     courseId: json['courseId'],
  //     courseTitle: json["courseTitle"],
  //     lecturerName: json["lecturerName"],
  //
  //     radius: json["radius"] ?? 0,
  //
  //     courses: List<String>.from(json["courses"] ?? []),
  //
  //     alreadyMarked: json["alreadyMarked"] ?? false,
  //   );
  // }
}