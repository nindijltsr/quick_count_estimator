import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'shared/services/auth_service.dart';
import 'shared/services/estimasi_provider.dart';
import 'shared/services/koefisien_provider.dart';  

// IMPORT FILE SPLASH SCREEN YANG BARU DIBUAT
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: 100 * 1024 * 1024,
    );
  } else {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // Inisialisasi koefisien 1x sebelum runApp.
  final koefisienProvider = KoefisienProvider();
  await koefisienProvider.inisialisasi(idAdmin: 'system');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: koefisienProvider),
        ChangeNotifierProvider(create: (_) => EstimasiProvider()),
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Count Estimator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // UBAH BAGIAN HOME INI:
      home: const SplashScreen(), 
    );
  }
}