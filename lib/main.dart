import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Pastikan ini tidak merah nanti setelah langkah no 3

void main() async {
  // 1. Wajib ada jika pakai Firebase di main()
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Inisialisasi Firebase dengan opsi dari firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Count Estimator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // Nanti ganti 'home' ini ke Halaman Login kamu kalau sudah dibuat
      home: const Scaffold(
        body: Center(
          child: Text('Aplikasi Quick Count Siap!'),
        ),
      ),
    );
  }
}