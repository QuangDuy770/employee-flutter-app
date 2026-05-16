class Employee {
  final int id;
  final String employeeCode;
  final String fullName;
  final int departmentId;
  final String? departmentName;
  final String? position;
  final String? email;
  final String? phone;
  final double? salary;
  final int status;
  final String? hireDate;

  Employee({
    required this.id,
    required this.employeeCode,
    required this.fullName,
    required this.departmentId,
    this.departmentName,
    this.position,
    this.email,
    this.phone,
    this.hireDate,
    this.salary,
    this.status = 1,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? 0,
      employeeCode: json['employee_code']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      departmentId: json['department_id'] ?? 1,
      departmentName: json['department_name']?.toString(),
      position: json['position']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      salary: json['salary'] != null
          ? double.tryParse(json['salary'].toString())
          : null,
      hireDate: json['hire_date'],
      status: json['status'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_code': employeeCode,
      'full_name': fullName,
      'department_id': departmentId,
      'position': position,
      'email': email,
      'phone': phone,
      'hire_date': hireDate,
      'salary': salary,
      'status': status,
    };
  }
}