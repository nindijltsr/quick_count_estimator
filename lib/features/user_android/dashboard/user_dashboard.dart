import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/utils/styles.dart';

class UserDashboard extends StatelessWidget {
  final Function(int) onNavigate;

  const UserDashboard({super.key, required this.onNavigate});

  void _showInstructionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lightbulb_outline, color: AppStyles.primaryGreen),
            SizedBox(width: 10),
            Text("Cara Menggunakan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBulletPoint("Buka menu Proyek di bawah."),
            _buildBulletPoint("Klik tombol + untuk buat proyek baru."),
            _buildBulletPoint("Input data pekerjaan klien."),
            _buildBulletPoint("Sistem akan hitung estimasi otomatis."),
            _buildBulletPoint("Hasil hitung akan muncul di daftar."),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Paham", style: TextStyle(color: AppStyles.primaryGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text("Memuat..."));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // HEADER HIJAU (Sudah dibuat lebih fit/ramping)
            // =========================
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10, // ✅ Dikurangi agar tidak terlalu ke bawah
                bottom: 15, // ✅ Dikurangi agar tidak terlalu lebar ke bawah
                left: 20, 
                right: 10
              ),
              decoration: const BoxDecoration(
                color: AppStyles.primaryGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                )
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "QUICK COUNT ESTIMATOR",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 1.0,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline, color: Colors.white),
                    onPressed: () => _showInstructionDialog(context),
                    tooltip: 'Bantuan',
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0), // Padding utama body
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =========================
                  // SAPAAN PENGGUNA
                  // =========================
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('email', isEqualTo: currentUser.email)
                        .limit(1)
                        .snapshots(),
                    builder: (context, userSnapshot) {
                      String name = 'Surveyor';
                      if (userSnapshot.hasData && userSnapshot.data!.docs.isNotEmpty) {
                        final userData = userSnapshot.data!.docs.first.data() as Map<String, dynamic>;
                        name = userData['name'] ?? 'Surveyor';
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Halo, $name! 👋",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Siap menghitung estimasi hari ini?",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 25),

                  // =========================
                  // CARD TOTAL PROYEK & AKSI
                  // =========================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.assignment, color: AppStyles.primaryGreen, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Total Estimasi Disimpan", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('projects')
                                        .where('user_id', isEqualTo: currentUser.uid)
                                        .snapshots(),
                                    builder: (context, projSnapshot) {
                                      int count = 0;
                                      if (projSnapshot.hasData) count = projSnapshot.data!.docs.length;
                                      return Text(
                                        "$count Dokumen",
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => onNavigate(1),
                            icon: const Icon(Icons.add),
                            label: const Text("Mulai Estimasi Baru"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppStyles.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25), // Sedikit dikurangi agar lebih hemat tempat

                  // =========================
                  // RECENT PROJECTS (Maksimal 2 Estimasi Terakhir)
                  // =========================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Estimasi Terakhir",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => onNavigate(1),
                        child: const Text("Lihat Semua", style: TextStyle(color: AppStyles.primaryGreen)),
                      ),
                    ],
                  ),

                  // List Proyek Terakhir (Limit 2)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('projects')
                        .where('user_id', isEqualTo: currentUser.uid)
                        .orderBy('updated_at', descending: true)
                        .limit(2) // ✅ DIUBAH MENJADI 2
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text("Belum ada riwayat estimasi.", style: TextStyle(color: Colors.grey[400])),
                          ),
                        );
                      }

                      return Column(
                        children: snapshot.data!.docs.map((doc) {
                          var data = doc.data() as Map<String, dynamic>;
                          return _buildMiniProjectCard(
                            data['project_name'] ?? 'Tanpa Nama',
                            data['client_name'] ?? '-',
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Desain Mini Card
  Widget _buildMiniProjectCard(String title, String client) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.folder_outlined, color: AppStyles.primaryGreen),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text("Klien: $client", style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () => onNavigate(1),
      ),
    );
  }
}