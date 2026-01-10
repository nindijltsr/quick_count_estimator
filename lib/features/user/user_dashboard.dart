import 'package:flutter/material.dart';
import '../../services/auth_service.dart'; // Pastikan path ini benar (naik 2 folder ke services)
import '../auth/login_page.dart'; // Sesuaikan path ini ke lokasi login_page.dart kamu

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard User"),
        backgroundColor: Colors.orange, // Pembeda warna dengan Admin (Hijau)
        actions: [
          // Tombol Logout (Penting buat testing)
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // 1. Logout dari Firebase & Google
              await _authService.logout();
              
              // 2. Kembali ke Halaman Login
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false, // Hapus semua riwayat halaman belakang
                );
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.engineering, 
              size: 100, 
              color: Colors.orange,
            ),
            SizedBox(height: 20),
            Text(
              "Halo, Surveyor!",
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Selamat datang di Dashboard User.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}