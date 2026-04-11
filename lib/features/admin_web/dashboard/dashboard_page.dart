import 'dart:math' show max;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/project_model.dart';
import '../../../shared/services/project_service.dart';
import '../../../shared/utils/styles.dart';

class DashboardPage extends StatelessWidget {
  /// Callback untuk switch tab di AdminDashboard
  final void Function(int index) onNavigate;

  const DashboardPage({super.key, required this.onNavigate});

  //formatter
  static final _formatTanggal = DateFormat('dd/MM/yyyy');

  String _formatRelative(DateTime waktu) {
    final s = DateTime.now().difference(waktu);
    if (s.inMinutes < 60) return '${s.inMinutes} mnt lalu';
    if (s.inHours < 24) return '${s.inHours} jam lalu';
    if (s.inDays < 7) return '${s.inDays} hari lalu';
    return _formatTanggal.format(waktu);
  }

  String _formatTanggalIndonesia(DateTime dt) {
    const hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    // weekday: 1=Senin ... 7=Minggu
    final namaHari = hari[dt.weekday - 1];
    final namaBulan = bulan[dt.month];
    return '$namaHari, ${dt.day.toString().padLeft(2, '0')} $namaBulan ${dt.year}';
  }

  // build
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreeting(),
          const SizedBox(height: 28),
          _buildKpiRow(),
          const SizedBox(height: 28),
          _buildAreaTengah(context),
          const SizedBox(height: 28),
          _buildTabelProyekTerbaru(context),
        ],
      ),
    );
  }

  // greeting
  Widget _buildGreeting() {
    final currentUser = FirebaseAuth.instance.currentUser;
    final now = DateTime.now();
    final tanggal = _formatTanggalIndonesia(now);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUser?.email)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        String namaAdmin = 'Admin';
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          namaAdmin = data['name'] ?? 'Admin';
        }

        String sapaan;
        final jam = now.hour;
        if (jam < 11) {
          sapaan = 'Selamat Pagi';
        } else if (jam < 15) {
          sapaan = 'Selamat Siang';
        } else if (jam < 18) {
          sapaan = 'Selamat Sore';
        } else {
          sapaan = 'Selamat Malam';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DASHBOARD',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 4),
            Text(
              '$sapaan, $namaAdmin — $tanggal',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        );
      },
    );
  }

  // card
  Widget _buildKpiRow() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _KpiCard(
            label: 'Total Proyek',
            icon: Icons.folder_open,
            stream: FirebaseFirestore.instance
                .collection('projects')
                .snapshots()
                .map((s) => s.docs.length),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: _KpiCard(
            label: 'User Aktif',
            icon: Icons.people_outline,
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('is_active', isEqualTo: true)
                .snapshots()
                .map((s) => s.docs.length),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 4,
          child: _KpiCard(
            label: 'Estimasi Selesai',
            icon: Icons.check_circle_outline,
            aksen: true,
            stream: FirebaseFirestore.instance
                .collection('projects')
                .where('status_perhitungan', isEqualTo: 'selesai')
                .snapshots()
                .map((s) => s.docs.length),
          ),
        ),
      ],
    );
  }

  Widget _buildAreaTengah(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kiri: Bar Chart native
        Expanded(
          flex: 6,
          child: _buildPanelGrafik(),
        ),
        const SizedBox(width: 20),
        // Kanan: Quick Actions
        Expanded(
          flex: 4,
          child: _buildPanelShortcut(context),
        ),
      ],
    );
  }

  // panel grafik
  Widget _buildPanelGrafik() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('projects').snapshots(),
      builder: (context, snapshot) {
        // Data distribusi status proyek
        int selesai = 0;
        int berjalan = 0;
        int belum = 0;

        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final status =
                (doc.data() as Map<String, dynamic>)['status_perhitungan']
                    as String? ??
                    'belum';
            if (status == 'selesai') {
              selesai++;
            } else if (status == 'sedang_berjalan') {
              berjalan++;
            } else {
              belum++;
            }
          }
        }

        final data = [
          _BarData('Selesai', selesai, AppStyles.primaryGreen),
          _BarData('Berjalan', berjalan, Colors.orange),
          _BarData('Belum\nDimulai', belum, Colors.grey[400]!),
        ];

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Distribusi Status Proyek',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                'Berdasarkan status kalkulasi saat ini',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 190,
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : CustomPaint(
                        size: const Size(double.infinity, 190),
                        painter: _BarChartPainter(data: data),
                        child: _buildBarLabels(data),
                      ),
              ),
              const SizedBox(height: 16),
              // Legenda
              Row(
                children: data
                    .map((d) => Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Row(
                            children: [
                              Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                      color: d.warna,
                                      borderRadius: BorderRadius.circular(2))),
                              const SizedBox(width: 5),
                              Text(d.label.replaceAll('\n', ' '),
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[600])),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBarLabels(List<_BarData> data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((d) {
        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                d.nilai.toString(),
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                d.label.replaceAll('\n', ' '),
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
            ],
          ),
        );
      }).toList(),
    );
  }

  // panel quick act
  Widget _buildPanelShortcut(BuildContext context) {
    final shortcuts = [
      _Shortcut(Icons.storage_outlined, 'Master Harga',
          'Update harga material & upah', 2),
      _Shortcut(Icons.people_outline, 'Kelola Akun',
          'Daftarkan surveyor baru', 3),
      _Shortcut(Icons.folder_open_outlined, 'Daftar Proyek',
          'Monitor semua estimasi', 1),
      _Shortcut(Icons.history_outlined, 'Riwayat Aktivitas',
          'Audit log surveyor', 4),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aksi Cepat',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            'Navigasi ke fitur utama',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: shortcuts
                .map((s) => _buildShortcutTile(context, s))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutTile(BuildContext context, _Shortcut s) {
    return InkWell(
      onTap: () => onNavigate(s.tabIndex),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(s.icon, size: 20, color: AppStyles.primaryGreen),
            const SizedBox(height: 6),
            Text(s.label,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
            Text(s.sublabel,
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  // tabel 5 proyek terbaru
  Widget _buildTabelProyekTerbaru(BuildContext context) {
    final projectService = ProjectService();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header tabel
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Proyek Terbaru',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      Text('5 proyek terakhir masuk',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[500])),
                    ],
                  ),
                  TextButton(
                    onPressed: () => onNavigate(1),
                    child: const Text('Lihat Semua',
                        style: TextStyle(
                            color: AppStyles.primaryGreen, fontSize: 12)),
                  ),
                ],
              ),
            ),

            // Header kolom
            Container(
              color: const Color(0xFFE3EAE6),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: const Row(
                children: [
                  SizedBox(
                      width: 32,
                      child: Text('No',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black87))),
                  Expanded(
                      flex: 3,
                      child: Text('Nama Proyek',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black87))),
                  Expanded(
                      flex: 2,
                      child: Text('Klien',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black87))),
                  Expanded(
                      flex: 2,
                      child: Text('Surveyor',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black87))),
                  SizedBox(
                      width: 100,
                      child: Text('Tanggal',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black87))),
                  SizedBox(
                      width: 80,
                      child: Text('Aksi',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black87))),
                ],
              ),
            ),

            // Baris data
            StreamBuilder<List<ProjectModel>>(
              stream: projectService.getAllProjects(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final projects = snapshot.data ?? [];
                if (projects.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text('Belum ada proyek.',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey[500])),
                    ),
                  );
                }

                // Ambil 5 terbaru (sudah descending dari getAllProjects)
                final lima = projects.take(5).toList();

                return Column(
                  children: List.generate(lima.length, (i) {
                    final p = lima[i];
                    return Column(
                      children: [
                        _buildBarisProyek(i + 1, p),
                        if (i < lima.length - 1)
                          Divider(
                              height: 1,
                              thickness: 0.5,
                              color: Colors.grey[200]),
                      ],
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarisProyek(int no, ProjectModel p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(no.toString(),
                style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          ),
          Expanded(
            flex: 3,
            child: Text(p.projectName,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 2,
            child: Text(p.clientName,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 2,
            child: Text(p.surveyorName,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          SizedBox(
            width: 100,
            child: Text(
              _formatTanggal.format(p.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          SizedBox(
            width: 80,
            child: TextButton(
              onPressed: () => onNavigate(1),
              style: TextButton.styleFrom(
                foregroundColor: AppStyles.primaryGreen,
                padding: EdgeInsets.zero,
                minimumSize: const Size(60, 30),
              ),
              child: const Text('Detail', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

// card widget
class _KpiCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Stream<int> stream;
  final bool aksen;

  const _KpiCard({
    required this.label,
    required this.icon,
    required this.stream,
    this.aksen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                StreamBuilder<int>(
                  stream: stream,
                  builder: (context, snapshot) {
                    final nilai = snapshot.data ?? 0;
                    return Text(
                      nilai.toString(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: aksen ? AppStyles.primaryGreen : Colors.black87,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Icon(
            icon,
            size: 32,
            color: aksen ? AppStyles.primaryGreen.withOpacity(0.5) : Colors.grey[300],
          ),
        ],
      ),
    );
  }
}

// warna bar chart

class _BarData {
  final String label;
  final int nilai;
  final Color warna;
  const _BarData(this.label, this.nilai, this.warna);
}

class _BarChartPainter extends CustomPainter {
  final List<_BarData> data;

  const _BarChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final totalMax = data.map((d) => d.nilai).fold(0, max);
    final nilaiMax = totalMax < 1 ? 1 : totalMax;

    final barWidth = size.width / (data.length * 2.5);
    final gapWidth = barWidth * 1.5;
    final totalWidth = data.length * (barWidth + gapWidth) - gapWidth;
    double startX = (size.width - totalWidth) / 2;

    final areaBar = size.height - 50;

    final paintBase = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 1;
    canvas.drawLine(
        Offset(0, areaBar), Offset(size.width, areaBar), paintBase);

    for (final d in data) {
      final tinggiBar = (d.nilai / nilaiMax) * (areaBar - 10);

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          startX,
          areaBar - tinggiBar,
          barWidth,
          tinggiBar,
        ),
        const Radius.circular(4),
      );

      canvas.drawRRect(rect, Paint()..color = d.warna);

      startX += barWidth + gapWidth;
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) => old.data != data;
}

// mode lokal

class _Shortcut {
  final IconData icon;
  final String label;
  final String sublabel;
  final int tabIndex;
  const _Shortcut(this.icon, this.label, this.sublabel, this.tabIndex);
}