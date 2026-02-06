import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import '../admin_web/dashboard/admin_dashboard.dart';
import '../user_android/main/user_main_page.dart';
import '../../shared/utils/styles.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const LoginPage();
        }
        
        User user = snapshot.data!;

        return FutureBuilder<QuerySnapshot>( 
          future: FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: user.email) 
              .limit(1)
              .get(),
          builder: (context, querySnapshot) {
            
            if (querySnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppStyles.primaryGreen),
                      SizedBox(height: 10),
                      Text("Memeriksa Hak Akses..."),
                    ],
                  ),
                ),
              );
            }

            if (querySnapshot.hasData && querySnapshot.data!.docs.isNotEmpty) {
              var userDoc = querySnapshot.data!.docs.first; 
              Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
              
              String role = userData['role'] ?? 'user';
              bool isActive = userData['is_active'] ?? true;

              if (!isActive) {
                return _buildErrorScreen(
                  context,
                  "Akun Anda Non-Aktif. Hubungi Admin.",
                );
              }

              if (role == 'admin') {
                if (kIsWeb) {
                  return const AdminDashboard();
                } else {
                  return _buildErrorScreen(
                    context,
                    "Admin tidak dapat mengakses aplikasi mobile. Silakan login via Web.",
                  );
                }
              } else if (role == 'user') {
                return const UserMainPage();
              } else {
                return _buildErrorScreen(context, "Role tidak dikenali.");
              }
            }

            return _buildErrorScreen(context, "Email Anda tidak terdaftar di sistem.");
          },
        );
      },
    );
  }

  Widget _buildErrorScreen(BuildContext context, String message) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text("Keluar Akun"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}