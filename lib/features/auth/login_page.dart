import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../../shared/services/auth_service.dart';
import '../../shared/utils/styles.dart';
import '../admin_web/dashboard/admin_dashboard.dart';
import '../user_android/main/user_main_page.dart';

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

                _isLoading
                    ? const CircularProgressIndicator(color: AppStyles.primaryGreen)
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
                            await _handleGoogleLogin();
                          },
                        ),
                      ),

                const SizedBox(height: 20),

                // ======================
                // FITUR : LOGIN DUMMY
                // ======================
                TextButton(
                  onPressed: () {
                    _showTestLoginDialog(context);
                  },
                  child: Text(
                    "Mode Testing (Login Email)",
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ),
                // ============================================================
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final result = await _authService.loginWithGoogle();
      if (result != null) {
        await _navigateBasedOnRole(result['role']);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateBasedOnRole(String role) async {
    if (role == 'admin') {
      if (kIsWeb) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
          );
        }
      } else {
        await _authService.logout();
        throw "Admin harus login melalui Website (Laptop/PC).";
      }
    } else if (role == 'user') {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserMainPage()),
        );
      }
    } else {
       throw "Role tidak dikenali.";
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.replaceAll("Exception: ", "")),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // ============================
  // FUNGSI : LOGIN DUMMY 
  // ============================
  void _showTestLoginDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool isDialogLoading = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Login Tester (Dummy)"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: "Email Dummy"),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: "Password"),
                    obscureText: true,
                  ),
                  if (isDialogLoading) ...[
                    const SizedBox(height: 15),
                    const CircularProgressIndicator()
                  ]
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: isDialogLoading
                      ? null
                      : () async {
                          if (emailController.text.isEmpty || passwordController.text.isEmpty) return;
                          
                          setDialogState(() => isDialogLoading = true);
                          try {
                            UserCredential userCredential = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim());

                            DocumentSnapshot userDoc = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userCredential.user!.uid)
                                .get();

                            if (userDoc.exists) {
                              String role = userDoc.get('role');
                              Navigator.pop(ctx); // Tutup Dialog
                              await _navigateBasedOnRole(role); // Masuk ke App
                            } else {
                              throw "User tidak ditemukan di database.";
                            }
                          } catch (e) {
                             ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Gagal Login Dummy: $e"), backgroundColor: Colors.red)
                             );
                          } finally {
                             setDialogState(() => isDialogLoading = false);
                          }
                        },
                  child: const Text("Masuk"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}