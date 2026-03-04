import 'package:flutter/material.dart';

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

  // notif saat menu pekerjaan di klik
  void _showDevelopmentMessage(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Fitur '$featureName' akan segera hadir."),
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
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
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
            // list card pekerjaan a-f
            _buildTaskCard(context, "Pekerjaan Persiapan, Tanah & Fondasi", "Input dimensi lahan dan galian", Icons.landscape, Colors.brown, Colors.brown[50]!),
            _buildTaskCard(context, "Pekerjaan Struktur dan Dinding", "Input volume beton dan bata", Icons.foundation, Colors.blueGrey, Colors.blueGrey[50]!),
            _buildTaskCard(context, "Pekerjaan Lantai dan Timbunan", "Input luasan lantai dan urugan", Icons.grid_on, Colors.teal, Colors.teal[50]!),
            _buildTaskCard(context, "Pekerjaan Pintu, Jendela & Pengunci", "Input jumlah kusen dan daun pintu", Icons.door_front_door, Colors.orange, Colors.orange[50]!),
            _buildTaskCard(context, "Pekerjaan Atap dan Plafon", "Input luasan rangka dan penutup atap", Icons.roofing, Colors.red, Colors.red[50]!),
            _buildTaskCard(context, "Pekerjaan Finishing", "Pengecatan dan titik instalasi listrik", Icons.format_paint, Colors.purple, Colors.purple[50]!),
            
            const Divider(height: 30, thickness: 1),
            
            // card prediksi upah pekerja
            _buildTaskCard(context, "Prediksi Pekerja", "Analisa durasi dan upah tukang", Icons.engineering, Colors.indigo, Colors.indigo[50]!),

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
              onPressed: () => _showDevelopmentMessage(context, "Lihat Hasil Analisa"),
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
  Widget _buildTaskCard(BuildContext context, String title, String subtitle, IconData icon, Color iconColor, Color bgColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!), // Saya haluskan sedikit bordernya jadi 200 biar lebih nyatu dengan warna pastel
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
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
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey), 
        onTap: () => _showDevelopmentMessage(context, "Form $title"),
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
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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