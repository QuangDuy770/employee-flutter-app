class Department {
  final int id;
  final String name;
  final String? description;
  final int status;

  Department({
    required this.id,
    required this.name,
    this.description,
    required this.status,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      status: json['status'] ?? 1,
    );
  }
}