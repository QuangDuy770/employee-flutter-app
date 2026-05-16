import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../models/department.dart';
import '../services/api_service.dart';

class EmployeeFormScreen extends StatefulWidget {
  final Employee? employee;

  const EmployeeFormScreen({super.key, this.employee});

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _positionController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _salaryController;
  late TextEditingController _hireDateController;

  int _departmentId = 1;
  int _status = 1;
  bool _isLoading = false;

  List<Department> _departments = [];
  bool _isDepartmentsLoading = true;

  bool get _isEditing => widget.employee != null;

  @override
  void initState() {
    super.initState();
    final emp = widget.employee;

    _codeController = TextEditingController(text: emp?.employeeCode ?? '');
    _nameController = TextEditingController(text: emp?.fullName ?? '');
    _positionController = TextEditingController(text: emp?.position ?? '');
    _emailController = TextEditingController(text: emp?.email ?? '');
    _phoneController = TextEditingController(text: emp?.phone ?? '');
    _salaryController = TextEditingController(
      text: emp?.salary?.toString() ?? '',
    );
    _hireDateController = TextEditingController(text: '');

    _departmentId = emp?.departmentId ?? 1;
    _status = emp?.status ?? 1;

    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    try {
      final depts = await _apiService.getDepartments();

      final activeDepts = depts.where((dept) => dept.status == 1).toList();

      setState(() {
        _departments = activeDepts;
        _isDepartmentsLoading = false;

        if (_departments.isNotEmpty) {
          bool exists = _departments.any((d) => d.id == _departmentId);

          if (!exists) {
            _departmentId = _departments.first.id;
          }
        }
      });
    } catch (e) {
      print('Lỗi tải danh sách phòng ban: $e');
      setState(() => _isDepartmentsLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final code = _codeController.text.trim();
    final name = _nameController.text.trim();
    final position = _positionController.text.trim();

    print('=== DỮ LIỆU TRƯỚC KHI GỬI ===');
    print('Is Editing: $_isEditing');
    print('ID: ${widget.employee?.id ?? 0}');
    print('Code: "$code"');
    print('Full Name: "$name"');
    print('Department: $_departmentId');
    print('Status: $_status');

    if (code.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mã NV và Họ tên không được để trống!'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    final employee = Employee(
      id: widget.employee?.id ?? 0,
      employeeCode: code,
      fullName: name,
      departmentId: _departmentId,
      position: position.isEmpty ? null : position,
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      hireDate: _hireDateController.text.trim(),
      salary: double.tryParse(_salaryController.text.trim()),
      status: _status,
    );

    try {
      bool success;

      if (_isEditing) {
        success = await _apiService.updateEmployee(employee);
      } else {
        success = await _apiService.createEmployee(employee);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? '✅ Cập nhật nhân viên thành công!'
                  : '✅ Thêm nhân viên thành công!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Thao tác thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Lỗi: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa Nhân viên' : 'Thêm Nhân viên mới'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Mã nhân viên *',
                  ),
                  validator: (value) => value!.trim().isEmpty
                      ? 'Vui lòng nhập mã nhân viên'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Họ và tên *'),
                  validator: (value) =>
                      value!.trim().isEmpty ? 'Vui lòng nhập họ tên' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _positionController,
                  decoration: const InputDecoration(labelText: 'Chức vụ'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value.trim())) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Số điện thoại'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _salaryController,
                  decoration: const InputDecoration(labelText: 'Lương'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _hireDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Ngày vào làm *',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng chọn ngày vào làm';
                    }
                    return null;
                  },
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDate != null) {
                      String formattedDate =
                          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";

                      _hireDateController.text = formattedDate;
                    }
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<int>(
                  value: _departments.any((d) => d.id == _departmentId)
                      ? _departmentId
                      : (_departments.isNotEmpty
                            ? _departments.first.id
                            : null),
                  decoration: const InputDecoration(labelText: 'Phòng ban *'),
                  items: _departments.map((dept) {
                    return DropdownMenuItem(
                      value: dept.id,
                      child: Text(dept.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _departmentId = value);
                    }
                  },
                  validator: (value) =>
                      value == null ? 'Vui lòng chọn phòng ban' : null,
                  isExpanded: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Trạng thái'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Đang làm việc')),
                    DropdownMenuItem(value: 0, child: Text('Đã nghỉ')),
                  ],
                  onChanged: (value) => setState(() => _status = value!),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isEditing ? 'CẬP NHẬT' : 'THÊM NHÂN VIÊN',
                            style: const TextStyle(fontSize: 18),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
