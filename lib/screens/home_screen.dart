import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'employee_list_screen.dart';
import 'department_list_screen.dart';  

class HomeScreen extends StatelessWidget {
  final AppUser user;
  final AuthService _authService = AuthService();

  HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = user.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang Chủ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.person, size: 50),
                title: Text('Xin chào, ${user.username}!'),
                subtitle: Text(isAdmin ? 'Quản trị viên' : 'Nhân viên'),
                trailing: Icon(isAdmin ? Icons.admin_panel_settings : Icons.person),
              ),
            ),
            const SizedBox(height: 30),

            ListTile(
              leading: const Icon(Icons.people, color: Colors.blue, size: 40),
              title: const Text('Quản lý Nhân viên', style: TextStyle(fontSize: 18)),
              subtitle: Text(isAdmin ? 'Toàn quyền quản lý' : 'Chỉ xem danh sách'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EmployeeListScreen(isAdmin: isAdmin),
                  ),
                );
              },
            ),

            const Divider(height: 30),

          
            ListTile(
              leading: const Icon(Icons.business, color: Colors.green, size: 40),
              title: const Text('Danh sách Phòng Ban', style: TextStyle(fontSize: 18)),
              subtitle: const Text('Xem danh sách và số lượng nhân viên theo phòng'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DepartmentListScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}