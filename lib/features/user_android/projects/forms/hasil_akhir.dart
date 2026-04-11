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

  static final _formatRp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  static final _formatOh = NumberFormat('#,##0.00', 'id_ID');

  static const int _stdPekerja = 3;
  static const int _stdTukang = 2;
  static const int _stdMandor = 1;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EstimasiProvider>();
    final rekap = provider.rekapMaterial;
    final hasilG = provider.hasilMenuG;

    if (rekap == null || hasilG == null) return _buildBelumAda(context);

    final grandTotal = rekap.totalBiayaMaterial + hasilG.totalBiayaUpah;
    final totalOh = hasilG.totalOhPekerja + hasilG.totalOhTukang + hasilG.totalOhMandor;
    final estimasiHari = (totalOh / (_stdPekerja + _stdTukang + _stdMandor)).ceil();

    // data menu untuk guard tampilan per seksi
    final a = provider.hasilMenuA;
    final b = provider.hasilMenuB;
    final c = provider.hasilMenuC;
    final d = provider.hasilMenuD;
    final e = provider.hasilMenuE;
    final f = provider.hasilMenuF;

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
            const Text('Hasil Estimasi',
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 17)),
            Text(projectName, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Header Grand Total
          _buildGrandTotalHeader(grandTotal, rekap.totalBiayaMaterial, hasilG.totalBiayaUpah),

          // Scroll Konten
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDivider(),

                  // Estimasi Durasi
                  _buildSectionHeader('ESTIMASI DURASI'),
                  _buildDurasiContent(totalOh, estimasiHari),
                  _buildDivider(),

                  // Rincian Biaya Material
                  _buildSectionHeader('RINCIAN BIAYA MATERIAL'),
                  if (a != null)
                    _buildGrupMaterial('Persiapan, Tanah & Pondasi', [
                      _Item('Urugan Pasir Pondasi', rekap.biayaPasirPondasi),
                      _Item('Aanstamping (Batu Kali)', rekap.biayaAanstamping),
                      _Item('Pasangan Batu Kali 1:4', rekap.biayaBatuKali),
                      _Item('Beton Pondasi Tapak K-175', rekap.biayaBetonTapak),
                    ]),
                  if (b != null)
                    _buildGrupMaterial('Struktur & Dinding', [
                      _Item('Sloof + Kolom + Ring Balok (Besi)', rekap.biayaBesi),
                      _Item('Pasangan Dinding Bata 1:4', rekap.biayaDinding),
                      _Item('Plesteran dan Acian', rekap.biayaSemenPlester),
                    ]),
                  if (c != null)
                    _buildGrupMaterial('Lantai & Timbunan', [
                      _Item('Timbunan Tanah Bawah Lantai', rekap.biayaTanahTimbun),
                      _Item('Pasangan Keramik 40×40', rekap.biayaKeramik),
                    ]),
                  if (d != null)
                    _buildGrupMaterial('Pintu, Jendela & Pengunci', [
                      _Item('Kusen Pintu + Ventilasi + Jendela', rekap.biayaKusen),
                      _Item('Daun Pintu Panel', rekap.biayaDaunPintu),
                      _Item('Daun Jendela', rekap.biayaDaunJendela),
                      _Item('Kaca Jendela 5mm', rekap.biayaKaca),
                      _Item('Kunci Pintu', rekap.biayaKunci),
                      _Item('Engsel Pintu + Jendela', rekap.biayaEngsel),
                    ]),
                  if (e != null)
                    _buildGrupMaterial('Atap & Plafon', [
                      _Item('Rangka Plafon Hollow', rekap.biayaRangkaPlafon),
                      _Item('Papan Gypsum 9mm', rekap.biayaGypsum),
                      _Item('List Plafon', rekap.biayaListPlafon),
                      _Item('Rangka + Genteng Galvalum + Nok', rekap.biayaAtap),
                      _Item('Papan Listplank', rekap.biayaListplank),
                    ]),
                  if (f != null)
                    _buildGrupMaterial('Finishing & Listrik', [
                      _Item('Pengecatan Tembok dan Plafon', rekap.biayaCatTembok),
                      _Item('Pengecatan Kayu', rekap.biayaCatKayu),
                      _Item('Lampu + Saklar + Stop Kontak', rekap.biayaListrik),
                    ]),

                  // total material
                  _buildTotalSeksi('Total Biaya Material', rekap.totalBiayaMaterial),
                  _buildDivider(),

                  // Rincian biaya upah
                  _buildSectionHeader('RINCIAN BIAYA UPAH'),
                  _buildUpahContent(hasilG),
                  _buildTotalSeksi('Total Biaya Upah', hasilG.totalBiayaUpah),
                  _buildDivider(),

                  // Back btn
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProjectEstimationPage(
                              projectId: projectId,
                              projectName: projectName,
                              clientName: clientName,
                            ),
                          ),
                          (route) => route.isFirst,
                        ),
                        icon: const Icon(Icons.home_outlined, color: Colors.white),
                        label: const Text('Kembali ke Menu Estimasi',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.primaryGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Header Grand Total
  Widget _buildGrandTotalHeader(double grandTotal, double totalMaterial, double totalUpah) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('GRAND TOTAL ESTIMASI',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[500], letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(_formatRp.format(grandTotal),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppStyles.primaryGreen)),
          const SizedBox(height: 10),
          // ringkasan 2 komponen
          Row(
            children: [
              Expanded(child: _buildKomponen('Material', totalMaterial, Colors.blue[700]!)),
              const SizedBox(width: 12),
              Expanded(child: _buildKomponen('Upah', totalUpah, Colors.orange[700]!)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKomponen(String label, double nilai, Color warna) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          const SizedBox(height: 2),
          Text(_formatRp.format(nilai),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: warna)),
        ],
      ),
    );
  }

  // Estimasi Durasi
  Widget _buildDurasiContent(double totalOh, int estimasiHari) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          _buildBaris('Total Beban Kerja', '${_formatOh.format(totalOh)} OH'),
          const SizedBox(height: 8),
          _buildBaris('Standar Tim', '$_stdPekerja Pekerja + $_stdTukang Tukang + $_stdMandor Mandor'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(6)),
            child: Text(
              '${_formatOh.format(totalOh)} OH ÷ ${_stdPekerja + _stdTukang + _stdMandor} Orang = $estimasiHari Hari Kerja',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // Rincian Material
  Widget _buildGrupMaterial(String judul, List<_Item> items) {
    final itemAda = items.where((i) => i.biaya > 0).toList();
    if (itemAda.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Text(judul,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[500])),
        ),
        Container(
          color: Colors.white,
          child: Column(
            children: itemAda
                .map((item) => _buildBarisItem(item))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBarisItem(_Item item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          Icon(Icons.chevron_right, size: 14, color: Colors.grey[400]),
          const SizedBox(width: 4),
          Expanded(child: Text(item.nama, style: const TextStyle(fontSize: 13, color: Colors.black87))),
          const SizedBox(width: 8),
          Text(
            _formatRp.format(item.biaya),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  // Rincian Upah
  Widget _buildUpahContent(dynamic hasilG) {
    final upahPekerja = hasilG.totalOhPekerja > 0 ? hasilG.biayaUpahPekerja / hasilG.totalOhPekerja : 0.0;
    final upahTukang = hasilG.totalOhTukang > 0 ? hasilG.biayaUpahTukang / hasilG.totalOhTukang : 0.0;
    final upahMandor = hasilG.totalOhMandor > 0 ? hasilG.biayaUpahMandor / hasilG.totalOhMandor : 0.0;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildBarisUpah('Pekerja', hasilG.totalOhPekerja, upahPekerja, hasilG.biayaUpahPekerja),
          Divider(height: 1, color: Colors.grey[100]),
          _buildBarisUpah('Tukang', hasilG.totalOhTukang, upahTukang, hasilG.biayaUpahTukang),
          Divider(height: 1, color: Colors.grey[100]),
          _buildBarisUpah('Mandor', hasilG.totalOhMandor, upahMandor, hasilG.biayaUpahMandor),
        ],
      ),
    );
  }

  Widget _buildBarisUpah(String jenis, double oh, double tarifPerOh, double totalBiaya) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(jenis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                const SizedBox(height: 2),
                Text(
                  '${_formatOh.format(oh)} OH × ${_formatRp.format(tarifPerOh)}/OH',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(_formatRp.format(totalBiaya),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  // Helper
  Widget _buildSectionHeader(String judul) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Text(judul,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54, letterSpacing: 0.5)),
    );
  }

  Widget _buildTotalSeksi(String label, double nilai) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text(_formatRp.format(nilai),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppStyles.primaryGreen)),
        ],
      ),
    );
  }

  Widget _buildBaris(String label, String nilai) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
        Flexible(
          child: Text(nilai,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
        ),
      ],
    );
  }

  Widget _buildDivider() => Container(height: 8, color: Colors.grey[100]);

  // Empty State
  Widget _buildBelumAda(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Hasil Estimasi',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calculate_outlined, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text('Data belum tersedia',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
              const SizedBox(height: 8),
              Text(
                'Selesaikan semua menu (A–F) dan tekan\n"Simpan Data Akhir & Hitung" di Finishing.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
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
}

class _Item {
  final String nama;
  final double biaya;
  const _Item(this.nama, this.biaya);
}