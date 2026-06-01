class AppUser {
  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    this.userIdentifier,
    this.departmentId,
    this.departmentName,
    this.phone,
    this.address,
    this.bio,
  });

  final int id;
  final String name;
  final String email;
  final String userType;
  final String? userIdentifier;
  final int? departmentId;
  final String? departmentName;
  final String? phone;
  final String? address;
  final String? bio;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'],
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        userType: json['user_type'] ?? 'student',
        userIdentifier: json['user_identifier'],
        departmentId: json['department_id'],
        departmentName: json['department']?['name'],
        phone: json['phone'],
        address: json['address'],
        bio: json['bio'],
      );
}
