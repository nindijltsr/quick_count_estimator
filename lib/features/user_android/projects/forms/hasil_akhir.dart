import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../project_estimation_page.dart';
import '../../../../shared/services/estimasi_provider.dart';
import '../../../../shared/utils/styles.dart';
import '../../../../shared/utils/pdf_generator.dart';

class HasilAkhirPage extends StatefulWidget {
  final String projectId;
  final String projectName;
  final String clientName;

  const HasilAkhirPage({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.clientName,
  });

  @override
  State<HasilAkhirPage> createState() => _HasilAkhirPageState();
}

class _HasilAkhirPageState extends State<HasilAkhirPage> {
  // Tambahkan state loading untuk PDF
  bool _isGeneratingPdf = false;

  static final _formatRp = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
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
    final totalOh =
        hasilG.totalOhPekerja + hasilG.totalOhTukang + hasilG.totalOhMandor;
    final estimasiHari =
        (totalOh / (_stdPekerja + _stdTukang + _stdMandor)).ceil();

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
            const Text(
              'Hasil Estimasi',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            Text(
              widget.projectName,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),

      // Sticky Grand Total di bawah
      bottomNavigationBar: _buildStickyGrandTotal(grandTotal),

      body: ListView(
        children: [
          // Ringkasan 2 komponen
          _buildRingkasanKomponen(
            rekap.totalBiayaMaterial,
            hasilG.totalBiayaUpah,
          ),
          _buildDivider(),

          // Estimasi Durasi
          _buildSectionLabel('ESTIMASI DURASI'),
          _buildDurasiTile(totalOh, estimasiHari),
          _buildDivider(),

          // Rincian Biaya Material
          _buildSectionLabel('RINCIAN BIAYA MATERIAL'),

          if (a != null)
            _buildAccordion(
              kode: 'A',
              judul: 'Persiapan, Tanah & Pondasi',
              subTotal: rekap.biayaPasirPondasi +
                  rekap.biayaAanstamping +
                  rekap.biayaBatuKali +
                  rekap.biayaBetonTapak,
              items: [
                _Item('Urugan Pasir Pondasi', rekap.biayaPasirPondasi),
                _Item('Aanstamping / Batu Kosong', rekap.biayaAanstamping),
                _Item('Pasangan Batu Kali 1:4', rekap.biayaBatuKali),
                _Item('Beton Pondasi Tapak K-175', rekap.biayaBetonTapak),
              ],
            ),

          if (b != null)
            _buildAccordion(
              kode: 'B',
              judul: 'Struktur & Dinding',
              subTotal: rekap.biayaBesi +
                  rekap.biayaDinding +
                  rekap.biayaSemenPlester,
              items: [
                _Item(
                  'Besi Tulangan (Sloof + Kolom + Ring Balok)',
                  rekap.biayaBesi,
                ),
                _Item('Pasangan Dinding Bata 1:4', rekap.biayaDinding),
                _Item('Plesteran & Acian', rekap.biayaSemenPlester),
              ],
            ),

          if (c != null)
            _buildAccordion(
              kode: 'C',
              judul: 'Lantai & Timbunan',
              subTotal: rekap.biayaTanahTimbun + rekap.biayaKeramik,
              items: [
                _Item('Timbunan Tanah Bawah Lantai', rekap.biayaTanahTimbun),
                _Item('Pasangan Keramik Lantai 40×40', rekap.biayaKeramik),
              ],
            ),

          if (d != null)
            _buildAccordion(
              kode: 'D',
              judul: 'Pintu, Jendela & Pengunci',
              subTotal: rekap.biayaKusen +
                  rekap.biayaDaunPintu +
                  rekap.biayaDaunJendela +
                  rekap.biayaKaca +
                  rekap.biayaKunci +
                  rekap.biayaEngsel,
              items: [
                _Item('Kusen Pintu + Ventilasi + Jendela', rekap.biayaKusen),
                _Item('Daun Pintu (Kayu Kls II)', rekap.biayaDaunPintu),
                _Item('Daun Jendela (Kayu Kls II)', rekap.biayaDaunJendela),
                _Item('Kaca Polos 5mm', rekap.biayaKaca),
                _Item('Kunci Pintu Silinder', rekap.biayaKunci),
                _Item('Engsel Pintu + Engsel Jendela', rekap.biayaEngsel),
              ],
            ),

          if (e != null)
            _buildAccordion(
              kode: 'E',
              judul: 'Atap & Plafon',
              subTotal: rekap.biayaRangkaPlafon +
                  rekap.biayaGypsum +
                  rekap.biayaListPlafon +
                  rekap.biayaAtap +
                  rekap.biayaListplank,
              items: [
                _Item(
                  'Rangka Plafon Hollow 4×4 & 2×4',
                  rekap.biayaRangkaPlafon,
                ),
                _Item('Papan Gypsum 9mm', rekap.biayaGypsum),
                _Item('List Profil Kayu Plafon', rekap.biayaListPlafon),
                _Item('Rangka Atap + Genteng Galvalum + Nok', rekap.biayaAtap),
                _Item('Papan Listplank', rekap.biayaListplank),
              ],
            ),

          if (f != null)
            _buildAccordion(
              kode: 'F',
              judul: 'Finishing, Cat & Instalasi Listrik',
              subTotal: rekap.biayaCatTembok +
                  rekap.biayaCatKayu +
                  rekap.biayaListrik,
              items: [
                _Item('Pengecatan Tembok & Plafon', rekap.biayaCatTembok),
                _Item('Pengecatan Kayu', rekap.biayaCatKayu),
                _Item('Lampu + Saklar + Stop Kontak', rekap.biayaListrik),
              ],
            ),

          _buildTotalSeksi('Total Biaya Material', rekap.totalBiayaMaterial),
          _buildDivider(),

          // Rincian Biaya Upah
          _buildSectionLabel('RINCIAN BIAYA UPAH'),
          _buildAccordionUpah(hasilG),
          _buildTotalSeksi('Total Biaya Upah', hasilG.totalBiayaUpah),
          _buildDivider(),

          // Tombol cetak PDF DENGAN LOADING
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _isGeneratingPdf
                    ? null
                    : () async {
                        setState(() => _isGeneratingPdf = true);

                        try {
                          final p = context.read<EstimasiProvider>();
                          final surveyor = FirebaseAuth
                                  .instance.currentUser?.displayName ??
                              '';

                          // Jeda sedikit agar UI sempat render indikator muter
                          await Future.delayed(
                              const Duration(milliseconds: 150));

                          await generateRABPdf(
                            data: DataPdfRAB(
                              namaProyek: widget.projectName,
                              namaKlien: widget.clientName,
                              namaSurveyor: surveyor,
                              tanggalDibuat: DateTime.now(),
                              menuA: p.hasilMenuA,
                              menuB: p.hasilMenuB,
                              menuC: p.hasilMenuC,
                              menuD: p.hasilMenuD,
                              menuE: p.hasilMenuE,
                              menuF: p.hasilMenuF,
                              menuG: p.hasilMenuG,
                              rekap: p.rekapMaterial,
                              snapshotHarga: p.snapshotHargaMaterial,
                              snapshotKoefisien: p.snapshotKoefisien,
                            ),
                          );
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal mencetak PDF: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isGeneratingPdf = false);
                          }
                        }
                      },
                icon: _isGeneratingPdf
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: AppStyles.primaryGreen,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.picture_as_pdf_outlined, size: 18),
                label: Text(
                  _isGeneratingPdf ? 'Menyiapkan PDF...' : 'Cetak Estimasi (PDF)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppStyles.primaryGreen,
                  side: const BorderSide(color: AppStyles.primaryGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),

          // Tombol kembali
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProjectEstimationPage(
                      projectId: widget.projectId,
                      projectName: widget.projectName,
                      clientName: widget.clientName,
                    ),
                  ),
                  (route) => route.isFirst,
                ),
                icon: const Icon(Icons.home_outlined, color: Colors.white),
                label: const Text(
                  'Kembali ke Menu Estimasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
    );
  }

  // Sticky Grand Total
  Widget _buildStickyGrandTotal(double grandTotal) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppStyles.primaryGreen,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GRAND TOTAL ESTIMASI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Material + Upah',
                  style: TextStyle(fontSize: 10, color: Colors.white54),
                ),
              ],
            ),
            Text(
              _formatRp.format(grandTotal),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Ringkasan 2 komponen
  Widget _buildRingkasanKomponen(double totalMaterial, double totalUpah) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: _buildChipKomponen(
              'Material',
              totalMaterial,
              const Color(0xFF1565C0),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildChipKomponen(
              'Upah',
              totalUpah,
              const Color(0xFFE65100),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipKomponen(String label, double nilai, Color warna) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: warna.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: warna.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: warna,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatRp.format(nilai),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: warna,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Estimasi Durasi
  Widget _buildDurasiTile(double totalOh, int estimasiHari) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppStyles.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.schedule_outlined,
              color: AppStyles.primaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$estimasiHari Hari Kerja',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatOh.format(totalOh)} OH ÷ ${_stdPekerja + _stdTukang + _stdMandor} orang',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //  Accordion Material
  Widget _buildAccordion({
    required String kode,
    required String judul,
    required double subTotal,
    required List<_Item> items,
  }) {
    final itemAda = items.where((i) => i.biaya > 0).toList();
    if (itemAda.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        childrenPadding: EdgeInsets.zero,
        leading: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppStyles.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            kode,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppStyles.primaryGreen,
            ),
          ),
        ),
        title: Text(
          judul,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatRp.format(subTotal),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppStyles.primaryGreen,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more, color: Colors.grey, size: 18),
          ],
        ),
        expandedAlignment: Alignment.topLeft,
        children: [
          const Divider(height: 1, indent: 16, endIndent: 16),
          ...itemAda.map((item) => _buildBarisItem(item)),
          Container(height: 1, color: Colors.grey[100]),
        ],
      ),
    );
  }

  Widget _buildBarisItem(_Item item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(56, 10, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.nama,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatRp.format(item.biaya),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Accordion Upah
  Widget _buildAccordionUpah(dynamic hasilG) {
    final upahPekerja = hasilG.totalOhPekerja > 0
        ? hasilG.biayaUpahPekerja / hasilG.totalOhPekerja
        : 0.0;
    final upahTukang = hasilG.totalOhTukang > 0
        ? hasilG.biayaUpahTukang / hasilG.totalOhTukang
        : 0.0;
    final upahMandor = hasilG.totalOhMandor > 0
        ? hasilG.biayaUpahMandor / hasilG.totalOhMandor
        : 0.0;

    return Container(
      color: Colors.white,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        childrenPadding: EdgeInsets.zero,
        leading: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppStyles.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'G',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppStyles.primaryGreen,
            ),
          ),
        ),
        title: const Text(
          'Biaya Upah Tenaga Kerja',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatRp.format(hasilG.totalBiayaUpah),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppStyles.primaryGreen,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more, color: Colors.grey, size: 18),
          ],
        ),
        expandedAlignment: Alignment.topLeft,
        children: [
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildBarisUpah(
            'Pekerja',
            hasilG.totalOhPekerja,
            upahPekerja,
            hasilG.biayaUpahPekerja,
          ),
          Divider(height: 1, color: Colors.grey[100]),
          _buildBarisUpah(
            'Tukang',
            hasilG.totalOhTukang,
            upahTukang,
            hasilG.biayaUpahTukang,
          ),
          Divider(height: 1, color: Colors.grey[100]),
          _buildBarisUpah(
            'Mandor',
            hasilG.totalOhMandor,
            upahMandor,
            hasilG.biayaUpahMandor,
          ),
          Container(height: 1, color: Colors.grey[100]),
        ],
      ),
    );
  }

  Widget _buildBarisUpah(
    String jenis,
    double oh,
    double tarifPerOh,
    double totalBiaya,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(56, 10, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jenis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatOh.format(oh)} OH × ${_formatRp.format(tarifPerOh)}/OH',
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Text(
            _formatRp.format(totalBiaya),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildSectionLabel(String label) {
    return Container(
      width: double.infinity,
      color: Colors.grey[50],
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey[500],
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildTotalSeksi(String label, double nilai) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            _formatRp.format(nilai),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppStyles.primaryGreen,
            ),
          ),
        ],
      ),
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
        title: const Text(
          'Hasil Estimasi',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calculate_outlined, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text(
                'Data belum tersedia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Kembali',
                  style: TextStyle(color: Colors.white),
                ),
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