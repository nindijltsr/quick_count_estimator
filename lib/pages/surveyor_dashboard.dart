import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quick_count_estimator/pages/login_page.dart'; 

class SurveyorDashboard extends StatelessWidget {
  const SurveyorDashboard({super.key});

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Surveyor"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false, 
                );
              }
            },
          )
        ],
      ),
      body: const Center(
        child: Text(
          "Selamat Datang di Panel Surveyor",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}