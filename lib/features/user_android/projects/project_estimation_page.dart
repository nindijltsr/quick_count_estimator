import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../../shared/services/estimasi_provider.dart';
import '../../../shared/services/koefisien_provider.dart';
import '../../../shared/services/layanan_notifikasi.dart';

import 'forms/persiapan_tanah_pondasi.dart';
import 'forms/struktur_dan_dinding.dart';
import 'forms/lantai_dan_timbunan.dart';
import 'forms/pintu_jendela_pengunci.dart';
import 'forms/atap_dan_plafon.dart';
import 'forms/finishing.dart';
import 'forms/prediksi_pekerja.dart';
import 'forms/hasil_akhir.dart';
import 'forms/cek_bahan.dart';

class ProjectEstimationPage extends StatefulWidget {
  final String projectId;
  final String projectName;
  final String clientName;

  const ProjectEstimationPage({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.clientName,
  });

  @override
  State<ProjectEstimationPage> createState() => _ProjectEstimationPageState();
}

class _ProjectEstimationPageState extends State<ProjectEstimationPage> {
  // NOTIFIKASI & BANNER
  final LayananNotifikasi _layananNotif = LayananNotifikasi();
  DateTime? _lastMasterUpdate;
  bool _adaBannerPeringatan = false;
  StreamSubscription<DateTime?>? _bannerSubscription;

  static final _formatTanggal = DateFormat('dd MMM yyyy, HH:mm');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final koefisienProvider = context.read<KoefisienProvider>();
      final estimasiProvider = context.read<EstimasiProvider>();

      // Double Protection: Inject koefisien master (akan ditimpa snapshot jika proyek lama)
      estimasiProvider.setKoefisienAktif(koefisienProvider.aktif);

      await estimasiProvider.inisialisasiProyek(
        idProyek: widget.projectId,
        idPengguna: FirebaseAuth.instance.currentUser?.uid ?? '',
        namaProyek: widget.projectName,
      );

      // Cek banner sekali saat init, lalu listen stream untuk reaktivitas
      await _cekStatusBanner(estimasiProvider);
      _mulaiListenBanner();
    });
  }

  Future<void> _cekStatusBanner(EstimasiProvider provider) async {
    final lastUpdate = await _layananNotif.ambilLastMasterUpdate();
    if (!mounted) return;

    setState(() {
      _lastMasterUpdate = lastUpdate;
      final snapshot = provider.tanggalSnapshotDiambil;
      // Munculkan banner JIKA master lebih baru dari snapshot
      _adaBannerPeringatan =
          lastUpdate != null &&
          (snapshot == null || lastUpdate.isAfter(snapshot));
    });
  }

  /// Listen stream perubahan master — banner muncul reaktif tanpa harus back/forward.
  void _mulaiListenBanner() {
    _bannerSubscription = _layananNotif.streamLastMasterUpdate().listen((
      lastMaster,
    ) {
      if (!mounted) return;
      final provider = context.read<EstimasiProvider>();
      final snapshot = provider.tanggalSnapshotDiambil;
      final adaBanner =
          lastMaster != null &&
          (snapshot == null || lastMaster.isAfter(snapshot));
      if (adaBanner != _adaBannerPeringatan ||
          (lastMaster != null && lastMaster != _lastMasterUpdate)) {
        setState(() {
          _lastMasterUpdate = lastMaster;
          _adaBannerPeringatan = adaBanner;
        });
      }
    });
  }

  @override
  void dispose() {
    _bannerSubscription?.cancel();
    super.dispose();
  }

  Future<void> _jalankanRefresh() async {
    // Tampilkan pop-up dialog konfirmasi anti-kepeleset
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Refresh Data'),
        content: const Text(
          'Apakah Anda yakin memperbarui data?\n\n'
          'Data RAB lama akan tertimpa dengan harga dan koefisien terbaru dari master. '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Ya, Refresh',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (konfirmasi != true || !mounted) return;

    final estimasiProvider = context.read<EstimasiProvider>();
    // BENAR — tanpa argumen
    await estimasiProvider.refreshDariMaster();

    if (!mounted) return;

    // Hilangkan banner setelah sukses
    setState(() => _adaBannerPeringatan = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data berhasil diperbarui ke versi master terbaru.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDevelopmentMessage(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text("Fitur '$featureName' akan segera hadir.")),
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ],
        ),
        backgroundColor: Colors.orange[800],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigasiDenganValidasi({
    required BuildContext context,
    required Widget targetPage,
    required String namaFitur,
  }) async {
    final provider = context.read<EstimasiProvider>();

    if (provider.dataKosong) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[700],
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text('Data Kosong', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: Text(
            'Anda belum mengisi satu pun menu input (A-F).\n\n'
            'Silakan isi minimal satu menu untuk melihat $namaFitur.',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
      return;
    }

    await provider.kalkulasiParsial();

    if (provider.adaDataParsial) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '⚠️ ${provider.statusMenuText}\nHasil estimasi mungkin tidak lengkap.',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange[700],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetPage),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.projectName,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Klien : ${widget.clientName}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // ── BANNER PERINGATAN REFRESH ────────────────────────
            if (_adaBannerPeringatan) _buildBannerRefresh(),

            // ── MENU INPUT (A–F) ──────────────────────────
            // ── MENU INPUT (A–F) ──────────────────────────
            Consumer<EstimasiProvider>(
              builder: (_, provider, __) {
                return Column(
                  children: [
                    _buildTaskCard(
                      context: context,
                      title: 'Pekerjaan Persiapan, Tanah & Fondasi',
                      subtitle: 'Input dimensi lahan dan galian',
                      icon: Icons.landscape,
                      iconColor: Colors.brown,
                      bgColor: Colors.brown[50]!,
                      sudahDiisi: provider.menuASudahDisimpan, // ← tambahan
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PersiapanTanahFondasiPage(
                            projectId: widget.projectId,
                            projectName: widget.projectName,
                            clientName: widget.clientName,
                          ),
                        ),
                      ),
                    ),

                    _buildTaskCard(
                      context: context,
                      title: 'Pekerjaan Struktur dan Dinding',
                      subtitle: 'Input volume beton dan bata',
                      icon: Icons.foundation,
                      iconColor: Colors.blueGrey,
                      bgColor: Colors.blueGrey[50]!,
                      sudahDiisi: provider.menuBSudahDisimpan, // ← tambahan
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StrukturDanDindingPage(
                            projectId: widget.projectId,
                            projectName: widget.projectName,
                            clientName: widget.clientName,
                          ),
                        ),
                      ),
                    ),

                    _buildTaskCard(
                      context: context,
                      title: 'Pekerjaan Lantai dan Timbunan',
                      subtitle: 'Input luasan lantai dan urugan',
                      icon: Icons.grid_on,
                      iconColor: Colors.teal,
                      bgColor: Colors.teal[50]!,
                      sudahDiisi: provider.menuCSudahDisimpan, // ← tambahan
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LantaiDanTimbunanPage(
                            projectId: widget.projectId,
                            projectName: widget.projectName,
                            clientName: widget.clientName,
                          ),
                        ),
                      ),
                    ),

                    _buildTaskCard(
                      context: context,
                      title: 'Pekerjaan Pintu, Jendela & Pengunci',
                      subtitle: 'Input jumlah kusen dan daun pintu',
                      icon: Icons.door_front_door,
                      iconColor: Colors.orange,
                      bgColor: Colors.orange[50]!,
                      sudahDiisi: provider.menuDSudahDisimpan, // ← tambahan
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PintuJendelaPengunciPage(
                            projectId: widget.projectId,
                            projectName: widget.projectName,
                            clientName: widget.clientName,
                          ),
                        ),
                      ),
                    ),

                    _buildTaskCard(
                      context: context,
                      title: 'Pekerjaan Atap dan Plafon',
                      subtitle: 'Input luasan rangka dan penutup atap',
                      icon: Icons.roofing,
                      iconColor: Colors.red,
                      bgColor: Colors.red[50]!,
                      sudahDiisi: provider.menuESudahDisimpan, // ← tambahan
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AtapDanPlafonPage(
                            projectId: widget.projectId,
                            projectName: widget.projectName,
                            clientName: widget.clientName,
                          ),
                        ),
                      ),
                    ),

                    _buildTaskCard(
                      context: context,
                      title: 'Pekerjaan Finishing',
                      subtitle: 'Pengecatan dan titik instalasi listrik',
                      icon: Icons.format_paint,
                      iconColor: Colors.purple,
                      bgColor: Colors.purple[50]!,
                      sudahDiisi: provider.menuFSudahDisimpan, // ← tambahan
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FinishingPage(
                            projectId: widget.projectId,
                            projectName: widget.projectName,
                            clientName: widget.clientName,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const Divider(height: 30, thickness: 1),

            // ── MENU OUTPUT ───────────────────────────────

            // Prediksi Pekerja (Menu G) — aktif setelah Menu F selesai
            Consumer<EstimasiProvider>(
              builder: (_, provider, __) {
                return _buildTaskCard(
                  context: context,
                  title: 'Prediksi Pekerja',
                  subtitle: provider.dataLengkap
                      ? 'Lihat estimasi OH dan biaya upah'
                      : provider.adaDataParsial
                      ? 'Data parsial (${provider.jumlahMenuTerisi}/6 menu)'
                      : 'Isi minimal 1 menu untuk melihat estimasi',
                  icon: Icons.engineering,
                  iconColor: provider.jumlahMenuTerisi > 0
                      ? Colors.indigo
                      : Colors.grey,
                  bgColor: provider.jumlahMenuTerisi > 0
                      ? Colors.indigo[50]!
                      : Colors.grey[100]!,
                  onTap: () => _navigasiDenganValidasi(
                    context: context,
                    targetPage: PrediksiPekerjaPage(
                      projectId: widget.projectId,
                      projectName: widget.projectName,
                      clientName: widget.clientName,
                    ),
                    namaFitur: 'Prediksi Pekerja',
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // Tombol Cek Bahan
            _buildActionButton(
              context: context,
              label: 'Cek Bahan',
              icon: Icons.inventory_2,
              color: const Color(0xFFF0B86E),
              onPressed: () => _navigasiDenganValidasi(
                context: context,
                targetPage: CekBahanPage(
                  projectId: widget.projectId,
                  projectName: widget.projectName,
                  clientName: widget.clientName,
                ),
                namaFitur: 'Cek Bahan',
              ),
            ),
            const SizedBox(height: 12),

            // Tombol Lihat Hasil Analisa — sambung ke HasilAkhirPage
            Consumer<EstimasiProvider>(
              builder: (_, provider, __) {
                return _buildActionButton(
                  context: context,
                  label: 'Lihat Hasil Analisa',
                  icon: Icons.analytics_outlined,
                  color: provider.jumlahMenuTerisi > 0
                      ? const Color(0xFF8B78E6)
                      : Colors.grey[400]!,
                  onPressed: () => _navigasiDenganValidasi(
                    context: context,
                    targetPage: HasilAkhirPage(
                      projectId: widget.projectId,
                      projectName: widget.projectName,
                      clientName: widget.clientName,
                    ),
                    namaFitur: 'Hasil Analisa',
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildActionButton(
              context: context,
              label: 'Kembali Ke Daftar Proyek',
              icon: Icons.arrow_back,
              color: Colors.grey[400]!,
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // WIDGET BANNER KUNING REFRESH DATA
  Widget _buildBannerRefresh() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        border: Border.all(color: Colors.amber.shade400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.amber[800],
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Master data telah diperbarui',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.amber[900],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _lastMasterUpdate != null
                ? 'Harga/koefisien master diperbarui pada ${_formatTanggal.format(_lastMasterUpdate!)}. '
                      'RAB proyek ini masih menggunakan data lama.'
                : 'Harga atau koefisien master telah diperbarui. RAB proyek ini menggunakan data lama.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.amber[800],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _jalankanRefresh,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh Data ke Versi Terbaru'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.amber[900],
                side: BorderSide(color: Colors.amber.shade600),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
    bool sudahDiisi = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: sudahDiisi
            ? const Icon(Icons.check_circle, color: Colors.green, size: 22)
            : const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
