class Course {
  final int id;
  final String code;
  final String name;
  final String? level;
  final String? semester;

  Course({
    required this.id,
    required this.code,
    required this.name,
    this.level,
    this.semester,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      level: json['level'],
      semester: json['semester'],
    );
  }
}