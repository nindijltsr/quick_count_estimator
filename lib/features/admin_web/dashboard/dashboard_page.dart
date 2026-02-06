import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text("Halaman Dashboard Utama", style: TextStyle(fontSize: 24, color: Colors.grey)),
        ],
      ),
    );
  }
}