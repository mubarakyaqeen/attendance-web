class StudentProfileModel {

  final String fullName;
  final String matricNumber;
  final String email;
  final String department;
  final String level;

  final int present;
  final int late;
  final int absent;

  final String? profileImageUrl;

  StudentProfileModel({
    required this.fullName,
    required this.matricNumber,
    required this.email,
    required this.department,
    required this.level,
    required this.present,
    required this.late,
    required this.absent,
    this.profileImageUrl,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileModel(
      fullName: json["fullName"],
      matricNumber: json["matricNumber"],
      email: json["email"],
      department: json["department"],
      level: json["level"],

      present: json["present"] ?? 0,
      late: json["late"] ?? 0,
      absent: json["absent"] ?? 0,

      profileImageUrl: json["profileImageUrl"],
    );
  }
}