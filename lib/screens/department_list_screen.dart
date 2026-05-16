import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/department.dart';

class DepartmentListScreen extends StatelessWidget {
  const DepartmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách Phòng Ban')),
      body: FutureBuilder<List<Department>>(
        future: ApiService().getDepartments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final departments = snapshot.data ?? [];

          if (departments.isEmpty) {
            return const Center(child: Text('Chưa có phòng ban nào'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: departments.length,
            itemBuilder: (context, index) {
              final dept = departments[index];
              final isActive = dept.status == 1;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isActive ? Colors.green : Colors.grey[700],
                    child: Text(
                      dept.id.toString(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    dept.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.black : Colors.grey[700],
                    ),
                  ),
                  subtitle: Text(
                    dept.description ?? 'Không có mô tả',
                    style: TextStyle(color: isActive ? Colors.black87 : Colors.grey),
                  ),
                  trailing: Icon(
                    Icons.circle,
                    color: isActive ? Colors.green : Colors.grey,
                    size: 18,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${dept.name} - ${isActive ? "Đang hoạt động" : "Ngừng hoạt động"}'),
                        backgroundColor: isActive ? Colors.green : Colors.grey,
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}