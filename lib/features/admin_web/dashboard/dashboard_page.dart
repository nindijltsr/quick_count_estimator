import 'dart:async'; 
import 'dart:math' show max;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/project_model.dart';
import '../../../shared/models/model_rekap_dan_lainnya.dart';
import '../../../shared/services/project_service.dart';
import '../../../shared/services/layanan_proyek.dart';
import '../../../shared/utils/styles.dart';

class _DataAgregatProyek {
  final int total;
  final int selesai;
  final int sedangBerjalan;
  final int belum;

  const _DataAgregatProyek({
    this.total = 0,
    this.selesai = 0,
    this.sedangBerjalan = 0,
    this.belum = 0,
  });

  int get aktif => total - selesai;
}

class DashboardPage extends StatefulWidget {
  final void Function(int index) onNavigate;

  const DashboardPage({super.key, required this.onNavigate});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final LayananHistori _layananHistori = LayananHistori();
  final Map<String, String> _cacheNamaUser = {};
  static final _formatTanggal = DateFormat('dd/MM/yyyy');


  StreamSubscription<QuerySnapshot>? _proyekSubscription;
  _DataAgregatProyek _agregatProyek = const _DataAgregatProyek();

  @override
  void initState() {
    super.initState();
    _preloadNamaUser();
    _mulaiListenProyek(); 
  }

  void _mulaiListenProyek() {
    _proyekSubscription = FirebaseFirestore.instance
        .collection('projects')
        .snapshots()
        .listen((snap) {
      int selesai = 0, berjalan = 0, belum = 0;
      for (final doc in snap.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        final status = data?['status_perhitungan'] as String? ?? 'belum';
        if (status == 'selesai') selesai++;
        else if (status == 'sedang_berjalan') berjalan++;
        else belum++;
      }
      if (mounted) {
        setState(() {
          _agregatProyek = _DataAgregatProyek(
            total: snap.docs.length,
            selesai: selesai,
            sedangBerjalan: berjalan,
            belum: belum,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _proyekSubscription?.cancel(); 
    super.dispose();
  }

  Future<void> _preloadNamaUser() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('users').get();
      for (final doc in snap.docs) {
        final data = doc.data();
        final nama = (data['name'] as String?)?.trim() ?? '';
        if (nama.isEmpty) continue;
        _cacheNamaUser[doc.id] = nama;
        final uid = (data['uid'] as String?)?.trim() ?? '';
        if (uid.isNotEmpty && uid != doc.id) _cacheNamaUser[uid] = nama;
      }
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Gagal preload nama user: $e');
    }
  }

  String _resolveNamaUser(String id) => _cacheNamaUser[id] ?? 'Pengguna';

  String _formatNamaAksi(String namaAksi) {
    switch (namaAksi) {
      case 'KALKULASI_SELESAI':
        return 'Kalkulasi Estimasi Selesai';
      case 'SIMPAN_MENU_A':
        return 'Simpan Data Persiapan & Pondasi';
      case 'SIMPAN_MENU_B':
        return 'Simpan Data Struktur & Dinding';
      case 'SIMPAN_MENU_C':
        return 'Simpan Data Lantai & Timbunan';
      case 'SIMPAN_MENU_D':
        return 'Simpan Data Pintu & Jendela';
      case 'SIMPAN_MENU_E':
        return 'Simpan Data Atap & Plafon';
      case 'SIMPAN_MENU_F':
        return 'Simpan Data Finishing & Listrik';
      case 'BUAT_PROYEK':
        return 'Membuat Proyek Baru';
      case 'EDIT_PROYEK':
        return 'Memperbarui Data Proyek';
      case 'HAPUS_PROYEK':
        return 'Menghapus Proyek';
      case 'REFRESH_MASTER':
        return 'Refresh Data Master';
      case 'LOGIN':
        return 'Masuk ke Aplikasi';
      case 'LOGOUT':
        return 'Keluar dari Aplikasi';
      default:
        final raw = namaAksi.replaceAll('_', ' ').toLowerCase();
        return '${raw[0].toUpperCase()}${raw.substring(1)}';
    }
  }

  IconData _iconUntukAksi(String namaAksi) {
    if (namaAksi.startsWith('SIMPAN_MENU')) return Icons.save_outlined;
    switch (namaAksi) {
      case 'KALKULASI_SELESAI':
        return Icons.check_circle_outline;
      case 'BUAT_PROYEK':
        return Icons.add_circle_outline;
      case 'EDIT_PROYEK':
        return Icons.edit_outlined;
      case 'HAPUS_PROYEK':
        return Icons.delete_outline;
      case 'REFRESH_MASTER':
        return Icons.sync;
      case 'LOGIN':
        return Icons.login;
      case 'LOGOUT':
        return Icons.logout;
      default:
        return Icons.circle_outlined;
    }
  }

  String _relativeTime(DateTime waktu) {
    final s = DateTime.now().difference(waktu);
    if (s.inSeconds < 60) return 'Baru saja';
    if (s.inMinutes < 60) return '${s.inMinutes} mnt lalu';
    if (s.inHours < 24) return '${s.inHours} jam lalu';
    if (s.inDays < 7) return '${s.inDays} hari lalu';
    return DateFormat('dd MMM yy').format(waktu);
  }

  String _formatTanggalIndonesia(DateTime dt) {
    const hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const bulan = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    final namaHari = hari[dt.weekday - 1];
    final namaBulan = bulan[dt.month];
    return '$namaHari, ${dt.day.toString().padLeft(2, '0')} $namaBulan ${dt.year}';
  }

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

  // Greeting
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

        final jam = now.hour;
        String sapaan;
        if (jam < 11) sapaan = 'Selamat Pagi';
        else if (jam < 15) sapaan = 'Selamat Siang';
        else if (jam < 18) sapaan = 'Selamat Sore';
        else sapaan = 'Selamat Malam';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DASHBOARD',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
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

  // Row atas
  Widget _buildKpiRow() {
    return Row(
      children: [
        /* // Diperbaiki - Stream lama dihapus
        Expanded(
          flex: 3,
          child: _KpiCard(
            label: 'Total Proyek',
            icon: Icons.folder_open,
            stream: FirebaseFirestore.instance.collection('projects').snapshots().map((s) => s.docs.length),
          ),
        ),
        */
        Expanded(
          flex: 3,
          child: _KpiCardStatis(
            label: 'Total Proyek',
            icon: Icons.folder_open,
            nilai: _agregatProyek.total,
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
        /* // Diperbaiki - Stream lama dihapus
        Expanded(
          flex: 4,
          child: _KpiCard(
            label: 'Estimasi Selesai',
            icon: Icons.check_circle_outline,
            aksen: true,
            stream: FirebaseFirestore.instance.collection('projects').where('status_perhitungan', isEqualTo: 'selesai').snapshots().map((s) => s.docs.length),
          ),
        ),
        */
        Expanded(
          flex: 4,
          child: _KpiCardStatis(
            label: 'Estimasi Selesai',
            icon: Icons.check_circle_outline,
            aksen: true,
            nilai: _agregatProyek.selesai,
          ),
        ),
      ],
    );
  }

  // Chart + Aktivitas Terbaru
  Widget _buildAreaTengah(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildPanelGrafik()),
        const SizedBox(width: 20),
        Expanded(flex: 2, child: _buildPanelAktivitasTerbaru(context)),
      ],
    );
  }

  // Panel Grafik
  Widget _buildPanelGrafik() {
    /* //Diperbaiki - StreamBuilder lama dihapus
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('projects').snapshots(),
      builder: (context, snapshot) { ... }
    );
    */

    // Data sekarang langsung dari state tunggal (_agregatProyek)
    final data = [
      _BarData('Selesai', _agregatProyek.selesai, AppStyles.primaryGreen),
      _BarData('Berjalan', _agregatProyek.sedangBerjalan, Colors.orange),
      _BarData('Belum\nDimulai', _agregatProyek.belum, Colors.grey[400]!),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
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
            child: CustomPaint(
              size: const Size(double.infinity, 190),
              painter: _BarChartPainter(data: data),
              child: _buildBarLabels(data),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: data
                .map(
                  (d) => Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: d.warna,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          d.label.replaceAll('\n', ' '),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
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
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
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

  //  Panel Aktivitas Terbaru
  Widget _buildPanelAktivitasTerbaru(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Aktivitas Terbaru',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '4 aktivitas terakhir surveyor',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => widget.onNavigate(5),
                style: TextButton.styleFrom(
                  foregroundColor: AppStyles.primaryGreen,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(60, 30),
                ),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          StreamBuilder<List<LogHistori>>(
            stream: _layananHistori.streamSemuaAktivitas(limit: 4),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              final logs = snapshot.data ?? [];
              if (logs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.history_outlined, size: 36, color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        Text('Belum ada aktivitas terbaru', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                      ],
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.only(top: 4),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: logs.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[100]),
                itemBuilder: (_, i) => _buildBarisAktivitas(logs[i]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBarisAktivitas(LogHistori log) {
    final namaUser = _resolveNamaUser(log.idPengguna);
    final namaAksi = _formatNamaAksi(log.namaAksi);
    final icon = _iconUntukAksi(log.namaAksi);
    final waktu = _relativeTime(log.dibuatPada);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
            child: Icon(icon, size: 14, color: Colors.grey[600]),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$waktu · $namaUser',
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
                const SizedBox(height: 2),
                Text(
                  namaAksi,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tabel Proyek Terbaru
  Widget _buildTabelProyekTerbaru(BuildContext context) {
    final projectService = ProjectService();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Proyek Terbaru', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      Text('5 proyek terakhir masuk', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    ],
                  ),
                  TextButton(
                    onPressed: () => widget.onNavigate(1),
                    child: const Text('Lihat Semua', style: TextStyle(color: AppStyles.primaryGreen, fontSize: 12)),
                  ),
                ],
              ),
            ),
            Container(
              color: const Color(0xFFE3EAE6),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: const Row(
                children: [
                  SizedBox(width: 32, child: Text('No', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87))),
                  Expanded(flex: 3, child: Text('Nama Proyek', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87))),
                  Expanded(flex: 2, child: Text('Klien', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87))),
                  Expanded(flex: 2, child: Text('Surveyor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87))),
                  SizedBox(width: 100, child: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87))),
                  SizedBox(width: 80, child: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87))),
                ],
              ),
            ),
            StreamBuilder<List<ProjectModel>>(
              stream: projectService.getAllProjects(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
                }
                final projects = snapshot.data ?? [];
                if (projects.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: Text('Belum ada proyek.', style: TextStyle(fontSize: 13, color: Colors.grey[500]))),
                  );
                }
                final lima = projects.take(5).toList();
                return Column(
                  children: List.generate(lima.length, (i) {
                    final p = lima[i];
                    return Column(
                      children: [
                        _buildBarisProyek(i + 1, p),
                        if (i < lima.length - 1) Divider(height: 1, thickness: 0.5, color: Colors.grey[200]),
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
          SizedBox(width: 32, child: Text(no.toString(), style: TextStyle(fontSize: 13, color: Colors.grey[500]))),
          Expanded(flex: 3, child: Text(p.projectName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text(p.clientName, style: TextStyle(fontSize: 13, color: Colors.grey[700]), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text(p.surveyorName, style: TextStyle(fontSize: 13, color: Colors.grey[700]), maxLines: 1, overflow: TextOverflow.ellipsis)),
          SizedBox(width: 100, child: Text(_formatTanggal.format(p.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey[600]))),
          SizedBox(
            width: 80,
            child: TextButton(
              onPressed: () => widget.onNavigate(1),
              style: TextButton.styleFrom(foregroundColor: AppStyles.primaryGreen, padding: EdgeInsets.zero, minimumSize: const Size(60, 30)),
              child: const Text('Detail', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

//  Widgets lokal
class _KpiCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Stream<int> stream;
  final bool aksen;

  const _KpiCard({required this.label, required this.icon, required this.stream, this.aksen = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
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
          Icon(icon, size: 32, color: aksen ? AppStyles.primaryGreen.withOpacity(0.5) : Colors.grey[300]),
        ],
      ),
    );
  }
}

// --- TAMBAHAN FIX CLAUDE ---
class _KpiCardStatis extends StatelessWidget {
  final String label;
  final IconData icon;
  final int nilai;
  final bool aksen;

  const _KpiCardStatis({
    required this.label,
    required this.icon,
    required this.nilai,
    this.aksen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                const SizedBox(height: 8),
                Text(
                  nilai.toString(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: aksen ? AppStyles.primaryGreen : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, size: 32, color: aksen ? AppStyles.primaryGreen.withOpacity(0.5) : Colors.grey[300]),
        ],
      ),
    );
  }
}
// ---------------------------

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
    canvas.drawLine(Offset(0, areaBar), Offset(size.width, areaBar), paintBase);

    for (final d in data) {
      final tinggiBar = (d.nilai / nilaiMax) * (areaBar - 10);

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(startX, areaBar - tinggiBar, barWidth, tinggiBar),
        const Radius.circular(4),
      );

      canvas.drawRRect(rect, Paint()..color = d.warna);
      startX += barWidth + gapWidth;
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) => old.data != data;
}