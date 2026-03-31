import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../project_estimation_page.dart';
import '../../../../shared/services/estimasi_provider.dart';
import '../../../../shared/utils/styles.dart';

class HasilAkhirPage extends StatelessWidget {
  final String projectId;
  final String projectName;
  final String clientName;

  const HasilAkhirPage({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.clientName,
  });

  static final _formatRp = NumberFormat.currency(
      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  static final _formatOh = NumberFormat('#,##0.00', 'id_ID');

  static const int _stdPekerja = 3;
  static const int _stdTukang = 2;
  static const int _stdMandor = 1;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EstimasiProvider>();
    final rekap = provider.rekapMaterial;
    final hasilG = provider.hasilMenuG;
    final a = provider.hasilMenuA;
    final b = provider.hasilMenuB;
    final c = provider.hasilMenuC;
    final d = provider.hasilMenuD;
    final e = provider.hasilMenuE;
    final f = provider.hasilMenuF;

    if (rekap == null || hasilG == null) return _buildBelumAda(context);

    // Grand total ditarik langsung dari engine yang sudah matang
    final grandTotal = rekap.totalBiayaMaterial + hasilG.totalBiayaUpah;

    // Durasi pekerja
    final totalOh = hasilG.totalOhPekerja + hasilG.totalOhTukang + hasilG.totalOhMandor;
    final totalTimStandar = _stdPekerja + _stdTukang + _stdMandor;
    final estimasiHari = (totalOh / totalTimStandar).ceil();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hasil Estimasi',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            Text(
              projectName,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildInfoProyek(projectName, clientName),
            ),
            const SizedBox(height: 16),

            if (a != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildKartu(
                  judul: 'Pekerjaan Persiapan, Tanah dan Pondasi',
                  warna: Colors.brown,
                  items: [
                    _Item('Pembersihan Lapangan & Bouwplank', 0),
                    _Item('Galian Tanah Menerus dan Tapak', 0),
                    _Item('Urugan Pasir Pondasi', rekap.biayaPasirPondasi),
                    _Item('Aanstamping (Batu Kali)', rekap.biayaAanstamping),
                    _Item('Pasangan Batu Kali 1:4', rekap.biayaBatuKali),
                    _Item('Beton Pondasi Tapak K-175', rekap.biayaBetonTapak),
                    _Item('Urugan Tanah Kembali', 0),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            if (b != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildKartu(
                  judul: 'Pekerjaan Struktur dan Dinding',
                  warna: Colors.orange,
                  items: [
                    _Item('Sloof + Kolom Praktis + Ring Balok', rekap.biayaBesi),
                    _Item('Pasangan Dinding Bata 1:4', rekap.biayaDinding),
                    _Item('Plesteran dan Acian', rekap.biayaSemenPlester),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            if (c != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildKartu(
                  judul: 'Pekerjaan Lantai dan Timbunan',
                  warna: Colors.green,
                  items: [
                    _Item('Timbunan Tanah Bawah Lantai', rekap.biayaTanahTimbun),
                    _Item('Urugan Pasir + Cor Lantai Kerja', 0),
                    _Item('Pasangan Keramik 40×40', rekap.biayaKeramik),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            if (d != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildKartu(
                  judul: 'Pekerjaan Pintu, Jendela dan Pengunci',
                  warna: Colors.blue,
                  items: [
                    _Item('Kusen Pintu + Ventilasi + Jendela', rekap.biayaKusen),
                    _Item('Daun Pintu Panel', rekap.biayaDaunPintu),
                    _Item('Daun Jendela', rekap.biayaDaunJendela),
                    _Item('Kaca Jendela 5mm', rekap.biayaKaca),
                    _Item('Kunci Pintu', rekap.biayaKunci),
                    _Item('Engsel Pintu + Jendela', rekap.biayaEngsel),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            if (e != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildKartu(
                  judul: 'Pekerjaan Atap dan Plafon',
                  warna: Colors.teal,
                  items: [
                    _Item('Rangka Plafon Hollow', rekap.biayaRangkaPlafon),
                    _Item('Papan Gypsum 9mm', rekap.biayaGypsum),
                    _Item('List Plafon', rekap.biayaListPlafon),
                    _Item('Rangka Kuda-kuda + Genteng Galvalum + Nok', rekap.biayaAtap),
                    _Item('Papan Listplank', rekap.biayaListplank),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            if (f != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildKartu(
                  judul: 'Pekerjaan Finishing Cat dan Listrik',
                  warna: Colors.purple,
                  items: [
                    _Item('Pengecatan Tembok dan Plafon', rekap.biayaCatTembok),
                    _Item('Pengecatan Kayu', rekap.biayaCatKayu),
                    _Item('Lampu + Saklar + Stop Kontak', rekap.biayaListrik),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            _buildUpahTenagaKerjaSection(hasilG),
            _buildDivider(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _buildCardRingkasan(
                totalMaterial: rekap.totalBiayaMaterial,
                totalUpah: hasilG.totalBiayaUpah,
                grandTotal: grandTotal,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectEstimationPage(
                          projectId: projectId,
                          projectName: projectName,
                          clientName: clientName,
                        ),
                      ),
                      (route) => route.isFirst,
                    );
                  },
                  icon: const Icon(Icons.home_outlined, color: Colors.white),
                  label: const Text(
                    'Kembali ke Menu Estimasi',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER DI BAWAH INI SAMA PERSIS SEPERTI SEBELUMNYA ---

  Widget _buildUpahTenagaKerjaSection(dynamic hasilG) {
    final upahPekerjaPerOh = hasilG.totalOhPekerja > 0 
        ? hasilG.biayaUpahPekerja / hasilG.totalOhPekerja : 0;
    final upahTukangPerOh = hasilG.totalOhTukang > 0 
        ? hasilG.biayaUpahTukang / hasilG.totalOhTukang : 0;
    final upahMandorPerOh = hasilG.totalOhMandor > 0 
        ? hasilG.biayaUpahMandor / hasilG.totalOhMandor : 0;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'UPAH TENAGA KERJA',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildUpahRingkas('Pekerja', hasilG.totalOhPekerja, upahPekerjaPerOh, hasilG.biayaUpahPekerja),
          const SizedBox(height: 10),
          _buildUpahRingkas('Tukang', hasilG.totalOhTukang, upahTukangPerOh, hasilG.biayaUpahTukang),
          const SizedBox(height: 10),
          _buildUpahRingkas('Mandor', hasilG.totalOhMandor, upahMandorPerOh, hasilG.biayaUpahMandor),
          const Divider(height: 20, thickness: 0.5, color: Colors.grey),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Biaya Upah',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              Text(
                _formatRp.format(hasilG.totalBiayaUpah),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpahRingkas(String jenis, double totalOh, double upahPerOh, double totalBiaya) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$jenis (${_formatOh.format(totalOh)} OH)',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
              const SizedBox(height: 2),
              Text(
                '× ${_formatRp.format(upahPerOh)}/OH',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            _formatRp.format(totalBiaya),
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildDataRow(String label, String value, {TextStyle? valueStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        Text(value, style: valueStyle ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 8, color: Colors.grey[50]);
  }

  Widget _buildBelumAda(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Hasil Estimasi', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calculate_outlined, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text('Data belum tersedia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
              const SizedBox(height: 8),
              Text('Selesaikan semua menu (A–F) dan tekan\n"Simpan Data Akhir & Hitung" di Finishing.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Kembali', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoProyek(String nama, String klien) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.business, color: AppStyles.primaryGreen, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                Text('Klien: $klien', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKartu({required String judul, required MaterialColor warna, required List<_Item> items}) {
    final totalBiaya = items.fold(0.0, (sum, i) => sum + i.biaya);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: warna[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: warna[100]!)),
            ),
            child: Row(
              children: [
                Icon(Icons.build_circle_outlined, color: warna, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(judul, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: warna[900]))),
              ],
            ),
          ),
          ...items.map((item) => _buildBarisItem(item)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: warna[50],
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              border: Border(top: BorderSide(color: warna[100]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Estimasi Biaya Material', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: warna[700])),
                Text(
                  totalBiaya > 0 ? _formatRp.format(totalBiaya) : 'Tercakup dalam biaya lain',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: warna[800]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarisItem(_Item item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[100]!))),
      child: Row(
        children: [
          Icon(Icons.chevron_right, size: 14, color: Colors.grey[400]),
          const SizedBox(width: 4),
          Expanded(child: Text(item.nama, style: const TextStyle(fontSize: 13, color: Colors.black87))),
          const SizedBox(width: 8),
          Text(
            item.biaya > 0 ? _formatRp.format(item.biaya) : '-',
            style: TextStyle(
              fontSize: 12,
              color: item.biaya > 0 ? AppStyles.primaryGreen : Colors.grey[400],
              fontWeight: item.biaya > 0 ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardRingkasan({required double totalMaterial, required double totalUpah, required double grandTotal}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildBarisRingkasan('Total Biaya Material', totalMaterial),
          const Divider(height: 1),
          _buildBarisRingkasan('Total Biaya Upah Tenaga Kerja', totalUpah),
          const Divider(height: 1, thickness: 2, color: Colors.black12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppStyles.primaryGreen,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('GRAND TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white, letterSpacing: 0.5)),
                Text(_formatRp.format(grandTotal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarisRingkasan(String label, double nilai) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          Text(_formatRp.format(nilai), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Item {
  final String nama;
  final double biaya;
  _Item(this.nama, this.biaya);
}