import 'package:flutter/material.dart';
import '../../../shared/utils/styles.dart';

// Import Halaman Anak
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

  // Daftar Halaman yang akan ditampilkan
  final List<Widget> _pages = [
    const UserDashboard(), // Index 0
    const ProjectPage(),   // Index 1
    const ProfilePage(),   // Index 2
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // Body berubah sesuai index yang dipilih
      body: _pages[_selectedIndex],
      
      // Navigasi tetap diam di bawah
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