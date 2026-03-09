import 'package:flutter/material.dart';
import 'forms/persiapan_tanah_pondasi.dart'; 
import 'forms/struktur_dan_dinding.dart';
import 'forms/lantai_dan_timbunan.dart';
import 'forms/pintu_jendela_pengunci.dart';
import 'forms/atap_dan_plafon.dart';
import 'forms/finishing.dart';

class ProjectEstimationPage extends StatelessWidget {
  final String projectId;
  final String projectName;
  final String clientName;

  const ProjectEstimationPage({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.clientName,
  });

  // notif saat menu yang belum dikerjakan di klik
  void _showDevelopmentMessage(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text("Fitur '$featureName' akan segera hadir.")),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
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
              projectName,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              "Klien : $clientName",
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 1. Pekerjaan Persiapan, Tanah & Fondasi
            _buildTaskCard(
              context: context,
              title: "Pekerjaan Persiapan, Tanah & Fondasi",
              subtitle: "Input dimensi lahan dan galian",
              icon: Icons.landscape,
              iconColor: Colors.brown,
              bgColor: Colors.brown[50]!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersiapanTanahFondasiPage( 
                      projectId: projectId,
                      projectName: projectName,
                      clientName: clientName,
                    ),
                  ),
                );
              },
            ),
            
            // 2. Pekerjaan Struktur dan Dinding
            _buildTaskCard(
              context: context,
              title: "Pekerjaan Struktur dan Dinding",
              subtitle: "Input volume beton dan bata",
              icon: Icons.foundation,
              iconColor: Colors.blueGrey,
              bgColor: Colors.blueGrey[50]!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StrukturDanDindingPage(
                      projectId: projectId,
                      projectName: projectName,
                      clientName: clientName,
                    ),
                  ), 
                );
              },
            ),
            
            // 3. Pekerjaan Lantai dan Timbunan
            _buildTaskCard(
              context: context,
              title: "Pekerjaan Lantai dan Timbunan",
              subtitle: "Input luasan lantai dan urugan",
              icon: Icons.grid_on,
              iconColor: Colors.teal,
              bgColor: Colors.teal[50]!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LantaiDanTimbunanPage(
                      projectId: projectId,
                      projectName: projectName,
                      clientName: clientName,
                    ),
                  ),
                );
              },
            ),
            
            // 4. Pekerjaan Pintu, Jendela & Pengunci
            _buildTaskCard(
              context: context,
              title: "Pekerjaan Pintu, Jendela & Pengunci",
              subtitle: "Input jumlah kusen dan daun pintu",
              icon: Icons.door_front_door,
              iconColor: Colors.orange,
              bgColor: Colors.orange[50]!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PintuJendelaPengunciPage(
                      projectId: projectId,
                      projectName: projectName,
                      clientName: clientName,
                    ),
                  ),
                );
              },
            ),
            
            // 5. Pekerjaan Atap dan Plafon
            _buildTaskCard(
              context: context,
              title: "Pekerjaan Atap dan Plafon",
              subtitle: "Input luasan rangka dan penutup atap",
              icon: Icons.roofing,
              iconColor: Colors.red,
              bgColor: Colors.red[50]!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AtapDanPlafonPage(
                      projectId: projectId,
                      projectName: projectName,
                      clientName: clientName,
                    ),
                  ),
                );
              },
            ),
            
            // 6. Pekerjaan Finishing
            _buildTaskCard(
              context: context,
              title: "Pekerjaan Finishing",
              subtitle: "Pengecatan dan titik instalasi listrik",
              icon: Icons.format_paint,
              iconColor: Colors.purple,
              bgColor: Colors.purple[50]!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FinishingPage(
                      projectId: projectId,
                      projectName: projectName,
                      clientName: clientName,
                    ),
                  ),
                );
              },
            ),

            const Divider(height: 30, thickness: 1),

            // card prediksi upah pekerja
            _buildTaskCard(
              context: context,
              title: "Prediksi Pekerja",
              subtitle: "Analisa durasi dan upah tukang",
              icon: Icons.engineering,
              iconColor: Colors.indigo,
              bgColor: Colors.indigo[50]!,
              onTap: () => _showDevelopmentMessage(context, "Prediksi Pekerja"),
            ),

            const SizedBox(height: 30),

            // tombol aksi bawahnya menu
            _buildActionButton(
              context: context,
              label: "Cek Bahan",
              icon: Icons.inventory_2,
              color: const Color(0xFFF0B86E),
              onPressed: () => _showDevelopmentMessage(context, "Cek Bahan"),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context: context,
              label: "Lihat Hasil Analisa",
              icon: Icons.analytics_outlined,
              color: const Color(0xFF8B78E6),
              onPressed: () =>
                  _showDevelopmentMessage(context, "Lihat Hasil Analisa"),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context: context,
              label: "Kembali Ke Daftar Proyek",
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

  // ui card pekerjaan
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
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // ui btn bawah
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