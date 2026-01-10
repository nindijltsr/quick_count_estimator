import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Untuk cek kIsWeb
import '../../services/auth_service.dart';
import '../../utils/styles.dart';

// --- IMPORT DASHBOARD ---
import '../admin/admin_dashboard.dart';
import '../user/user_dashboard.dart'; // <--- Import User Dashboard

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Cek tampilan lebar (Web) atau sempit (Mobile)
    final isWebDisplay = screenWidth > 800;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: isWebDisplay ? 450 : screenWidth * 0.9,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo & Header
                const Icon(
                  Icons.construction,
                  size: 60,
                  color: AppStyles.primaryGreen,
                ),
                const SizedBox(height: 20),
                const Text(
                  'LOGIN SISTEM',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppStyles.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Estimasi Biaya Konstruksi',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 40),

                // Tombol Login
                _isLoading
                    ? const CircularProgressIndicator(
                        color: AppStyles.primaryGreen)
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.login),
                          label: const Text('MASUK DENGAN GOOGLE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppStyles.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            setState(() => _isLoading = true);
                            try {
                              // 1. Panggil Service Login (Validasi Whitelist & Status)
                              final result =
                                  await _authService.loginWithGoogle();

                              if (result != null) {
                                String role = result['role']; // 'admin' atau 'user'

                                // --- LOGIKA PENGATUR LALU LINTAS ---

                                // SKENARIO 1: ADMIN LOGIN
                                if (role == 'admin') {
                                  if (kIsWeb) {
                                    // Admin di Web -> Silakan Masuk
                                    if (mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const AdminDashboard()),
                                      );
                                    }
                                  } else {
                                    // Admin di Android -> TOLAK (Logout Paksa)
                                    await _authService.logout();
                                    throw "Admin harus login melalui Website (Laptop/PC).";
                                  }
                                }
                                // SKENARIO 2: USER (SURVEYOR) LOGIN
                                else if (role == 'user') {
                                  // User (Surveyor) boleh masuk Dashboard User
                                  if (mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const UserDashboard()),
                                    );
                                  }
                                }
                              }
                            } catch (e) {
                              // Tangkap Error (Akun non-aktif, Email salah, Admin di HP, dll)
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e
                                        .toString()
                                        .replaceAll("Exception: ", "")),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          },
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