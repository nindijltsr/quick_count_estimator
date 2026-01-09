import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Perhatikan import path ini menyesuaikan struktur baru:
import '../../services/auth_service.dart';
import '../../utils/styles.dart';
import '../admin/admin_dashboard.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: isWeb ? 450 : screenWidth * 0.9,
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
                // Logo Icon
                const Icon(
                  Icons.construction, 
                  size: 60, 
                  color: AppStyles.primaryGreen
                ),
                const SizedBox(height: 20),
                
                // Judul
                const Text(
                  'LOGIN ADMIN',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppStyles.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sistem Estimasi Perhitungan Cepat Biaya Proyek',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 40),

                // Tombol Google
                _isLoading
                    ? const CircularProgressIndicator(color: AppStyles.primaryGreen)
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            setState(() => _isLoading = true);
                            try {
                              final auth = Provider.of<AuthService>(context, listen: false);
                              final user = await auth.loginWithGoogle();
                              
                              if (user != null && mounted) {
                                // Arahkan ke Admin Dashboard
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AdminDashboard()),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Gagal: $e')),
                              );
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          },
                          icon: const Icon(Icons.login), 
                          label: const Text('MASUK DENGAN GOOGLE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppStyles.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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