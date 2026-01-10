import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// --- BAGIAN IMPORT FILE KAMU ---
// Pastikan path/alamat filenya sesuai dengan folder kamu
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'utils/styles.dart'; // Import styles kalau ada, atau bisa dihapus jika tidak dipakai di sini
import 'features/auth/auth_wrapper.dart'; // <--- PENTING: Panggil Satpam/Wrapper di sini

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // 1. DAFTARKAN PROVIDER (Wajib agar tidak error saat Login)
      providers: [
        // Menggunakan Provider untuk AuthService
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      
      child: MaterialApp(
        title: 'Quick Count Estimator',
        debugShowCheckedModeBanner: false, // Menghilangkan banner debug miring

        // 2. TEMA APLIKASI (Hijau)
        theme: ThemeData(
          // Mengatur warna utama jadi Hijau
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
          // Opsional: Jika kamu punya file AppStyles, bisa atur detail lain di sini
        ),

        // 3. HOME / HALAMAN UTAMA
        // Di sini kuncinya: Jangan langsung ke LoginPage, tapi ke AuthWrapper.
        // AuthWrapper akan mengecek: "Sudah login? -> Dashboard. Belum? -> Login Page"
        home: const AuthWrapper(), 
      ),
    );
  }
}