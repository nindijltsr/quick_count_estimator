import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/styles.dart';
import '../auth/login_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 3; // Default ke Manajemen Akun

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // --- SIDEBAR ---
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
                
                // Menu Sidebar
                _buildMenuItem(0, Icons.dashboard, 'Dashboard'),
                _buildMenuItem(1, Icons.folder_open, 'Proyek'),
                _buildMenuItem(2, Icons.storage, 'Master Harga'),
                _buildMenuItem(3, Icons.people, 'Manajemen Akun'),
                _buildMenuItem(4, Icons.settings, 'Pengaturan'),
                
                const Spacer(),
                
                // Tombol Logout
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

          // --- KONTEN KANAN ---
          Expanded(
            child: Container(
              color: AppStyles.backgroundGrey,
              padding: const EdgeInsets.all(20),
              // Jika menu 3 dipilih -> Tampilkan Tabel User
              child: _selectedIndex == 3 
                  ? _buildUserManagementContent() 
                  : Center(child: Text("Halaman index $_selectedIndex belum dibuat")),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Item Sidebar
  Widget _buildMenuItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.white : Colors.white70),
      title: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.white70)),
      tileColor: isSelected ? Colors.white.withOpacity(0.1) : null,
      onTap: () => setState(() => _selectedIndex = index),
    );
  }

  // Widget Konten: Manajemen Akun (Tabel)
  Widget _buildUserManagementContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MANAJEMEN AKUN', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('Kelola Akun Pengguna', style: TextStyle(color: Colors.grey)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Nanti kita buat logika Pop Up Tambah User di sini
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah Pengguna'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Card Tabel
        Expanded(
          child: Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari nama...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                        columns: const [
                          DataColumn(label: Text('No')),
                          DataColumn(label: Text('Nama Lengkap')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Role')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Aksi')),
                        ],
                        rows: [
                          _buildRow('1', 'Nindi Nurrahma', 'nindi@gmail.com', 'Admin', true),
                          _buildRow('2', 'Jeje', 'jeje@gmail.com', 'Surveyor', true),
                          _buildRow('3', 'Budi Santoso', 'budi@gmail.com', 'Surveyor', false),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  DataRow _buildRow(String no, String nama, String email, String role, bool isActive) {
    return DataRow(cells: [
      DataCell(Text(no)),
      DataCell(Text(nama)),
      DataCell(Text(email)),
      DataCell(Text(role)),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? Colors.green[100] : Colors.red[100],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(isActive ? 'Aktif' : 'Non-aktif', 
          style: TextStyle(color: isActive ? Colors.green[800] : Colors.red[800], fontSize: 12)),
      )),
      DataCell(Row(
        children: [
          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () {}),
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {}),
        ],
      )),
    ]);
  }
}