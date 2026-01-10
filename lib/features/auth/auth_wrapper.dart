import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart'; // Sesuaikan path
import '../admin/admin_dashboard.dart'; // Sesuaikan path

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder ini adalah "CCTV" yang memantau status login
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Sedang mengecek (Loading)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Ada Data User (Berarti Sedang Login)
        if (snapshot.hasData) {
          return const AdminDashboard(); // Langsung ke Dashboard
        }

        // 3. Tidak Ada Data (Belum Login / Habis Logout)
        return const LoginPage(); // Lempar ke Login
      },
    );
  }
}