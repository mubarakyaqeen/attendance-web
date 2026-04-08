class AttendanceHistoryModel {
  final String courseCode;
  final String courseTitle;
  final String status;
  final String markedAt;

  AttendanceHistoryModel({
    required this.courseCode,
    required this.courseTitle,
    required this.status,
    required this.markedAt,
  });

  factory AttendanceHistoryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryModel(
      courseCode: json["courseCode"],
      courseTitle: json["courseTitle"],
      status: json["status"],
      markedAt: json["markedAt"],
    );
  }
}