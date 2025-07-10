class User {
  final String firstName;
  final String lastName;
  final String email;
  final String grNo;
  final String enrollmentNo;
  final String phoneNo;
  final int semester;
  final String stream;

  User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.grNo,
    required this.enrollmentNo,
    required this.phoneNo,
    required this.semester,
    required this.stream,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      grNo: json['gr_no'] ?? '',
      enrollmentNo: json['enrollment_no'] ?? '',
      phoneNo: json['phone_no'] ?? '',
      semester: json['semester'] ?? 0,
      stream: json['stream'] ?? '',
    );
  }
}
