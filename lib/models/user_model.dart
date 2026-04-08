class User {

  final int id;
  final int? lecturerId;
  final String token;
  final String role;
  final String name;

  User({
    required this.id,
    this.lecturerId,
    required this.token,
    required this.role,
    required this.name,
  });

  // factory User.fromJson(Map<String, dynamic> json) {
  //
  //   return User(
  //     id: json['userId'] is int
  //         ? json['userId']
  //         : int.tryParse("${json['userId']}") ?? 0,
  //
  //     lecturerId: json['lecturerId'] == null
  //         ? null
  //         : (json['lecturerId'] is int
  //         ? json['lecturerId']
  //         : int.tryParse("${json['lecturerId']}")),
  //
  //     token: json['token'] ?? "",
  //     role: json['role'] ?? "",
  //     name: json['name'] ?? json['fullName'] ?? "",
  //   );
  // }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['userId'] is int
          ? json['userId']
          : int.tryParse("${json['userId']}") ?? 0,
      lecturerId: json['lecturerId'],
      token: json['token'] ?? "",
      role: json['role'] ?? "",
      name: json['name'] ?? json['fullName'] ?? "",
    );
  }
}