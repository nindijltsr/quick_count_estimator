import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../../shared/utils/styles.dart';
import '../../../shared/services/auth_service.dart';
import '../../auth/login_page.dart';

import '../dashboard/user_dashboard.dart';
import '../projects/project_page.dart';
import '../profile/profile_page.dart';

class UserMainPage extends StatefulWidget {
  const UserMainPage({super.key});

  @override
  State<UserMainPage> createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  int _selectedIndex = 0;
  StreamSubscription<QuerySnapshot>? _userSubscription; 

  @override
  void initState() {
    super.initState();
    _monitorUserStatus(); 
  }

  // Fitur check is_active real time
  void _monitorUserStatus() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.email == null) return;

    _userSubscription = FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: currentUser.email)
        .snapshots()
        .listen((snapshot) async {
      
      if (snapshot.docs.isNotEmpty) {
        final userData = snapshot.docs.first.data();
        final isActive = userData['is_active'] ?? true;

        // jika akun nonaktif
        if (!isActive) {
          _userSubscription?.cancel();
          await context.read<AuthService>().logout();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Akun Anda telah dinonaktifkan oleh Admin."),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
              ),
            );

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pindahkan List pages ke dalam build agar bisa menerima fungsi _onItemTapped
    final List<Widget> pages = [
      UserDashboard(onNavigate: _onItemTapped), // ✅ Melempar remot kontrol ke Dashboard
      const ProjectPage(),   
      const ProfilePage(),   
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: pages[_selectedIndex],
      
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.construction),
            label: 'Proyek',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppStyles.primaryGreen,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }
}