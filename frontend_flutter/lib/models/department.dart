class Department {
  Department({required this.id, required this.name});

  final int id;
  final String name;

  factory Department.fromJson(Map<String, dynamic> json) => Department(
        id: json['id'],
        name: json['name'] ?? '',
      );
}
