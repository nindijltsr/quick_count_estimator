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
                    ? Column(
                        children: [
                          const CircularProgressIndicator(
                            color: AppStyles.primaryGreen,
                          ),
                          if (!kIsWeb) ...[
                            const SizedBox(height: 10),
                            Text(
                              "Memverifikasi Akun...",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: Icon(
                            kIsWeb ? Icons.language : Icons.smartphone,
                          ),
                          label: const Text('MASUK DENGAN GOOGLE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppStyles.primaryGreen,
                            foregroundColor: Colors.white,
                            elevation: kIsWeb ? 5 : 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                kIsWeb ? 8 : 12,
                              ),
                            ),
                          ),
                          onPressed: _handleGoogleLogin,
                        ),
                      ),

                //login testing
                // const SizedBox(height: 20),
                // TextButton(
                //   onPressed: () {
                //     _showTestLoginDialog(context);
                //   },
                //   child: Text(
                //     // "Mode Testing (Login Email)",
                //     " ",
                //     style: TextStyle(color: Colors.grey[400], fontSize: 12),
                //   ),
                // ),
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
        throw "Akses Ditolak: Admin hanya dapat login melalui Website (Laptop/PC).";
      }
    } else if (role == 'user') {
      if (!kIsWeb) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const UserMainPage()),
          );
        }
      } else {
        await _authService.logout();
        throw "Akses Ditolak: Pengguna biasa (User) hanya dapat login melalui Aplikasi Mobile.";
      }
    } else {
      await _authService.logout();
      throw "Role tidak dikenali oleh sistem.";
    }
  }

  void _showError(String message) {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible:
            false, // User WAJIB klik tombol, gak bisa klik luar screen
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Row(
              children: [
                Icon(Icons.gpp_bad, color: Colors.red, size: 30),
                SizedBox(width: 10),
                Text(
                  "Akses Ditolak",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red, // <-- Pakai parameter color yang resmi
                  ),
                ),
              ],
            ),
            content: Text(
              message.replaceAll("Exception: ", ""),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // Menutup dialog secara sadar
                },
                child: const Text("OK, SAYA PAHAM"),
              ),
            ],
          );
        },
      );
    }
  }

  // login testing
  // void _showTestLoginDialog(BuildContext context) {
  //   final emailController = TextEditingController();
  //   final passwordController = TextEditingController();
  //   bool isDialogLoading = false;

  //   showDialog(
  //     context: context,
  //     builder: (ctx) {
  //       return StatefulBuilder(
  //         builder: (context, setDialogState) {
  //           return AlertDialog(
  //             title: const Text("Login Testing"),
  //             content: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 TextField(
  //                   controller: emailController,
  //                   decoration: const InputDecoration(labelText: "Email"),
  //                 ),
  //                 TextField(
  //                   controller: passwordController,
  //                   decoration: const InputDecoration(labelText: "Password"),
  //                   obscureText: true,
  //                 ),
  //                 if (isDialogLoading) ...[
  //                   const SizedBox(height: 15),
  //                   const CircularProgressIndicator(),
  //                 ],
  //               ],
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.pop(ctx),
  //                 child: const Text("Batal"),
  //               ),
  //               ElevatedButton(
  //                 onPressed: isDialogLoading
  //                     ? null
  //                     : () async {
  //                         if (emailController.text.isEmpty ||
  //                             passwordController.text.isEmpty)
  //                           return;

  //                         setDialogState(() => isDialogLoading = true);
  //                         try {
  //                           UserCredential userCredential = await FirebaseAuth
  //                               .instance
  //                               .signInWithEmailAndPassword(
  //                                 email: emailController.text.trim(),
  //                                 password: passwordController.text.trim(),
  //                               );

  //                           final QuerySnapshot result = await FirebaseFirestore
  //                               .instance
  //                               .collection('users')
  //                               .where(
  //                                 'email',
  //                                 isEqualTo: userCredential.user!.email,
  //                               )
  //                               .limit(1)
  //                               .get();

  //                           if (result.docs.isNotEmpty) {
  //                             final userData =
  //                                 result.docs.first.data()
  //                                     as Map<String, dynamic>;

  //                             await FirebaseFirestore.instance
  //                                 .collection('users')
  //                                 .doc(result.docs.first.id)
  //                                 .update({'uid': userCredential.user!.uid});

  //                             String role = userData['role'] ?? 'user';

  //                             if (ctx.mounted) {
  //                               Navigator.pop(ctx);
  //                               await _navigateBasedOnRole(role);
  //                             }
  //                           } else {
  //                             throw "Email terdaftar di Auth, tapi Data Profil tidak ditemukan di Database.";
  //                           }
  //                         } catch (e) {
  //                           if (ctx.mounted) {
  //                             ScaffoldMessenger.of(context).showSnackBar(
  //                               SnackBar(
  //                                 content: Text("Gagal Login: $e"),
  //                                 backgroundColor: Colors.red,
  //                               ),
  //                             );
  //                           }
  //                         } finally {
  //                           setDialogState(() => isDialogLoading = false);
  //                         }
  //                       },
  //                 child: const Text("Masuk"),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
}
