import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employee.dart';
import '../models/department.dart';

class ApiService {
  static const String baseUrl = 'https://yii2-flutter-employee.onrender.com';

  
  Future<List<Employee>> getEmployees() async {
    final response = await http.get(Uri.parse('$baseUrl/api/employee'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Employee.fromJson(json)).toList();
    } else {
      throw Exception('Lỗi tải danh sách: ${response.statusCode}');
    }
  }

  // Thêm mới nhân viên
  Future<bool> createEmployee(Employee employee) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/employee'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'employee_code': employee.employeeCode,
          'full_name': employee.fullName,
          'department_id': employee.departmentId,
          'position': employee.position,
          'email': employee.email,
          'hire_date': employee.hireDate,
          'phone': employee.phone,
          'salary': employee.salary,
          'status': employee.status,
        }),
      );

      print('Create Status Code: ${response.statusCode}');
      print('Create Response Body: ${response.body}');

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Create Exception: $e');
      return false;
    }
  }

  // Cập nhật nhân viên
  Future<bool> updateEmployee(Employee employee) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/employee/${employee.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'employee_code': employee.employeeCode,
          'full_name': employee.fullName,
          'department_id': employee.departmentId,
          'position': employee.position,
          'email': employee.email,
          'phone': employee.phone,
          'hire_date': employee.hireDate,
          'salary': employee.salary,
          'status': employee.status,
        }),
      );

      print('Update Status Code: ${response.statusCode}');
      print('Update Response Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Update Exception: $e');
      return false;
    }
  }

  // Xóa nhân viên
  Future<bool> deleteEmployee(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/employee/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Delete Status Code: ${response.statusCode}');
      print('Delete Response: ${response.body}');

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Delete Exception: $e');
      return false;
    }
  }

  Future<List<Department>> getDepartments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/department'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Department.fromJson(json)).toList();
      } else {
        print('❌ Lỗi API Department: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Get Departments Exception: $e');
      return [];
    }
  }
}
