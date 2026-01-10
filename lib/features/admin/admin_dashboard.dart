import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/styles.dart';
import '../auth/login_page.dart';

import 'pages/user_management_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0; 

  final List<Widget> _pages = [
    const Center(child: Text("Halaman Dashboard (Index 0)")),
    const Center(child: Text("Halaman Proyek (Index 1)")),   
    const Center(child: Text("Halaman Master Harga (Index 2)")),
    const UserManagementPage(), 
    const Center(child: Text("Halaman Pengaturan (Index 4)")), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 250,
            color: AppStyles.primaryGreen,
            child: Column(
              children: [

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      const Icon(Icons.apartment, color: Colors.white, size: 30),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('QUICK COUNT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text('Admin Panel', style: TextStyle(color: Colors.white70, fontSize: 10)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const Divider(color: Colors.white24),
                
                _buildMenuItem(0, Icons.dashboard, 'Dashboard'),
                _buildMenuItem(1, Icons.folder_open, 'Proyek'),
                _buildMenuItem(2, Icons.storage, 'Master Harga'),
                _buildMenuItem(3, Icons.people, 'Manajemen Akun'),
                _buildMenuItem(4, Icons.settings, 'Pengaturan'),
                
                const Spacer(),
                
                // Logout Button
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await context.read<AuthService>().logout();
                      if (mounted) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppStyles.primaryGreen,
                    ),
                    child: const Text('LOGOUT'),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              color: AppStyles.backgroundGrey, 
              padding: const EdgeInsets.all(20),
              child: _pages[_selectedIndex], 
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.white : Colors.white70),
      title: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.white70)),
      tileColor: isSelected ? Colors.white.withOpacity(0.1) : null,
      onTap: () => setState(() => _selectedIndex = index),
    );
  }
}