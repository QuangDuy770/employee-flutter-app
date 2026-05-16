import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/api_service.dart';
import 'employee_form_screen.dart';

class EmployeeListScreen extends StatefulWidget {
  final bool isAdmin;

  const EmployeeListScreen({super.key, required this.isAdmin});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final ApiService _apiService = ApiService();
  List<Employee> _employees = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);
    try {
      final employees = await _apiService.getEmployees();
      setState(() {
        _employees = employees;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() => _errorMessage = 'Lỗi tải dữ liệu: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

 
  void _openAddForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EmployeeFormScreen()),
    );
    if (result == true) _loadEmployees();
  }


  void _openEditForm(Employee employee) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EmployeeFormScreen(employee: employee)),
    );
    if (result == true) {
      _loadEmployees(); 
    }
  }

 
  void _deleteEmployee(Employee employee) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa nhân viên "${employee.fullName}" không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    final success = await _apiService.deleteEmployee(employee.id);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Đã xóa nhân viên'),
          backgroundColor: Colors.green,
        ),
      );
      _loadEmployees();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Xóa thất bại'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Nhân viên'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmployees,
          ),
        ],
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: _openAddForm,
              child: const Icon(Icons.add),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadEmployees,
              child: _employees.isEmpty
                  ? const Center(child: Text('Chưa có nhân viên nào'))
                  : ListView.builder(
                      itemCount: _employees.length,
                      itemBuilder: (context, index) {
                        final emp = _employees[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: emp.status == 1
                                  ? Colors.green
                                  : Colors.grey,
                              child: Text(
                                (emp.employeeCode.isNotEmpty)
                                    ? emp.employeeCode[0].toUpperCase()
                                    : '?',
                              ),
                            ),
                            title: Text(
                              emp.fullName.isNotEmpty
                                  ? emp.fullName
                                  : 'Không có tên',
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mã: ${emp.employeeCode.isNotEmpty ? emp.employeeCode : 'Chưa có'}',
                                ),

                            
                                Text(
                                  'Chức vụ: ${emp.position?.isNotEmpty == true ? emp.position : 'Chưa có'}',
                                ),

                                Text('Phòng: ${emp.departmentName ?? "Phòng ${emp.departmentId}"}'),
                              ],
                            ),
                            trailing: widget.isAdmin
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () => _openEditForm(
                                          emp,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _deleteEmployee(emp),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
