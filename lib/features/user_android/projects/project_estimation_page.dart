import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../shared/services/estimasi_provider.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<EstimasiProvider>().inisialisasiProyek(
        idProyek: widget.projectId,
        idPengguna: FirebaseAuth.instance.currentUser?.uid ?? '',
      );
    });
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 28),
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
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
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
            Text(widget.projectName,
                style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            Text('Klien : ${widget.clientName}',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // ── MENU INPUT (A–F) ──────────────────────────

            _buildTaskCard(
              context: context,
              title: 'Pekerjaan Persiapan, Tanah & Fondasi',
              subtitle: 'Input dimensi lahan dan galian',
              icon: Icons.landscape,
              iconColor: Colors.brown,
              bgColor: Colors.brown[50]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (context) => PersiapanTanahFondasiPage(
                  projectId: widget.projectId,
                  projectName: widget.projectName,
                  clientName: widget.clientName,
                ),
              )),
            ),

            _buildTaskCard(
              context: context,
              title: 'Pekerjaan Struktur dan Dinding',
              subtitle: 'Input volume beton dan bata',
              icon: Icons.foundation,
              iconColor: Colors.blueGrey,
              bgColor: Colors.blueGrey[50]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (context) => StrukturDanDindingPage(
                  projectId: widget.projectId,
                  projectName: widget.projectName,
                  clientName: widget.clientName,
                ),
              )),
            ),

            _buildTaskCard(
              context: context,
              title: 'Pekerjaan Lantai dan Timbunan',
              subtitle: 'Input luasan lantai dan urugan',
              icon: Icons.grid_on,
              iconColor: Colors.teal,
              bgColor: Colors.teal[50]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (context) => LantaiDanTimbunanPage(
                  projectId: widget.projectId,
                  projectName: widget.projectName,
                  clientName: widget.clientName,
                ),
              )),
            ),

            _buildTaskCard(
              context: context,
              title: 'Pekerjaan Pintu, Jendela & Pengunci',
              subtitle: 'Input jumlah kusen dan daun pintu',
              icon: Icons.door_front_door,
              iconColor: Colors.orange,
              bgColor: Colors.orange[50]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (context) => PintuJendelaPengunciPage(
                  projectId: widget.projectId,
                  projectName: widget.projectName,
                  clientName: widget.clientName,
                ),
              )),
            ),

            _buildTaskCard(
              context: context,
              title: 'Pekerjaan Atap dan Plafon',
              subtitle: 'Input luasan rangka dan penutup atap',
              icon: Icons.roofing,
              iconColor: Colors.red,
              bgColor: Colors.red[50]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (context) => AtapDanPlafonPage(
                  projectId: widget.projectId,
                  projectName: widget.projectName,
                  clientName: widget.clientName,
                ),
              )),
            ),

            _buildTaskCard(
              context: context,
              title: 'Pekerjaan Finishing',
              subtitle: 'Pengecatan dan titik instalasi listrik',
              icon: Icons.format_paint,
              iconColor: Colors.purple,
              bgColor: Colors.purple[50]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (context) => FinishingPage(
                  projectId: widget.projectId,
                  projectName: widget.projectName,
                  clientName: widget.clientName,
                ),
              )),
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
                  iconColor: provider.jumlahMenuTerisi > 0 ? Colors.indigo : Colors.grey,
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

  Widget _buildTaskCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
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
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
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
        label: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}