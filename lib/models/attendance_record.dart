class AttendanceRecord {

  final String studentName;
  final String status;

  AttendanceRecord({
    required this.studentName,
    required this.status,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      studentName: json["studentName"] ?? "",
      status: json["status"] ?? "",
    );
  }

}