import 'package:flutter/material.dart';

class CustomLoading {
  // Warna Utama Aplikasi Anda
  static const Color primaryColor = Color(0xFF064E3B);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  // 1. Splash Screen (Awal Buka Aplikasi)
  static Widget splashScreen() {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo_app.png',
                  width: 140,
                  height: 140,
                  errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.architecture, size: 140, color: primaryColor), // Fallback jika logo gagal load
                ),
                const SizedBox(height: 20),
                const Text(
                  "QUICK COUNT ESTIMATOR",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Loading Halaman Estimasi (Pindah dari Beranda ke Kalkulasi)
  static Widget pageLoading() {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: primaryColor),
            const SizedBox(height: 16),
            const Text(
              "Memuat data estimasi...",
              style: TextStyle(
                color: primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Loading Area Kosong (Untuk Daftar Proyek)
  static Widget centerLoading() {
    return const Center(
      child: CircularProgressIndicator(color: primaryColor),
    );
  }

  // 4. Fungsi Pop-up Loading Transparan (Cetak PDF / Proses Simpan Berat)
  static void showLoadingDialog(BuildContext context, {String message = "Sedang menyiapkan dokumen..."}) {
    showDialog(
      context: context,
      barrierDismissible: false, // Tidak bisa ditutup dengan tap di luar
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: primaryColor),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 5. Fungsi Menutup Pop-up Loading
  static void hideLoadingDialog(BuildContext context) {
    // Menggunakan rootNavigator agar pop-up di layar paling atas yang tertutup
    Navigator.of(context, rootNavigator: true).pop();
  }
}

// ==========================================
// 6. Custom Widget untuk Button Spinner
// ==========================================
class CustomLoadingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isLoading;

  const CustomLoadingButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: CustomLoading.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      // Tombol disable jika sedang loading
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
          : Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}