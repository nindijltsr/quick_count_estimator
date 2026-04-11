import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/project_model.dart';
import '../../../shared/models/model_rekap_dan_lainnya.dart';
import '../../../shared/models/model_hasil_perhitungan.dart';
import '../../../shared/services/layanan_master_harga.dart';
import '../../../shared/utils/styles.dart';

class ProjectDetailPage extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailPage({super.key, required this.project});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  final LayananMasterHarga _layananHarga = LayananMasterHarga();

  static final _formatRp =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  static final _formatTanggal = DateFormat('dd/MM/yyyy');

  static const _koleksiRekap = 'rekap_akhir';
  static const _docRekap = 'material';
  static const _koleksiHasil = 'hasil_perhitungan';
  static const _docMenuG = 'estimasi_upah';

  RekapMaterial? _rekap;
  HasilMenuG? _hasilG;
  Map<String, HargaMaterial> _hargaMap = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _muatSemuaData();
  }

  // muat data
  Future<void> _muatSemuaData() async {
    try {
      final idProyek = widget.project.projectId;
      final refProyek =
          FirebaseFirestore.instance.collection('projects').doc(idProyek);

      final results = await Future.wait([
        refProyek.collection(_koleksiRekap).doc(_docRekap).get(),
        refProyek.collection(_koleksiHasil).doc(_docMenuG).get(),
        _layananHarga.streamSemuaHargaMaterial().first,
      ]);

      final rekapDoc = results[0] as DocumentSnapshot<Map<String, dynamic>>;
      final hasilGDoc = results[1] as DocumentSnapshot<Map<String, dynamic>>;
      final daftarHarga = results[2] as List<HargaMaterial>;

      setState(() {
        _rekap = rekapDoc.exists
            ? RekapMaterial.dariFirestore(rekapDoc.data()!)
            : null;
        _hasilG = hasilGDoc.exists
            ? HasilMenuG.dariFirestore(hasilGDoc.data()!)
            : null;
        _hargaMap = {for (final h in daftarHarga) h.id: h};
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text('Gagal memuat data: $_error',
                              style: const TextStyle(color: Colors.red)),
                        ))
                    : _buildKonten(),
          ),
        ],
      ),
    );
  }

  // top bar
  Widget _buildTopBar() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                const Icon(Icons.arrow_back, size: 18, color: Colors.black87),
                const SizedBox(width: 6),
                Text('Kembali ke daftar',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // konten utama
  Widget _buildKonten() {
    final rekap = _rekap;
    final hasilG = _hasilG;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoProyek(),
          const SizedBox(height: 28),

          if (rekap == null && hasilG == null)
            _buildBelumAda()
          else ...[
            _buildHeaderSeksi('A. Analisis Estimasi Biaya'),
            const SizedBox(height: 16),

            if (rekap != null) ...[
              _buildSubSeksi('1. Pekerjaan Persiapan', [
                _Baris('Pembersihan Lapangan', rekap.tanahTimbun_m3, 'm²', 'tanah_timbun'),
                _Baris('Pengukuran / Pemasangan Bouwplank', rekap.pasirUrug_m3, 'm\'', 'pasir_urug'),
              ]),
              _buildSubSeksi('2. Pekerjaan Tanah & Pondasi', [
                _Baris('Urugan Pasir Pondasi', rekap.pasirUrug_m3, 'm³', 'pasir_urug'),
                _Baris('Aanstamping Batu Kali', rekap.batuKali_m3, 'm³', 'batu_kali'),
                _Baris('Pasangan Batu Kali 1:4', rekap.batuKali_m3, 'm³', 'batu_kali'),
                _Baris('Beton Pondasi Tapak K-175 (Kerikil)', rekap.kerikil_kg, 'kg', 'kerikil'),
                _Baris('Pasir Pasang', rekap.pasirPasang_m3, 'm³', 'pasir_pasang'),
                _Baris('Pasir Beton', rekap.pasirBeton_kg, 'kg', 'pasir_beton'),
                _Baris('Semen PC', rekap.semen_kg, 'kg', 'semen_pc'),
                _Baris('Papan Bekisting', rekap.papanBekisting_m2, 'm²', 'papan_bekisting'),
              ]),
              _buildSubSeksi('3. Pekerjaan Struktur & Dinding', [
                _Baris('Besi Tulangan Polos (Sloof + Kolom + Ring Balok)', rekap.besiPolos_kg, 'kg', 'besi_polos'),
                _Baris('Bata Merah', rekap.bataMerah_buah, 'buah', 'bata_merah'),
              ]),
              _buildSubSeksi('4. Pekerjaan Lantai & Timbunan', [
                _Baris('Tanah Timbun Bawah Lantai', rekap.tanahTimbun_m3, 'm³', 'tanah_timbun'),
                _Baris('Pasir Urug Bawah Lantai', rekap.pasirUrug_m3, 'm³', 'pasir_urug'),
                _Baris('Keramik Lantai 40×40 cm', rekap.keramik40x40_buah, 'buah', 'keramik_40x40'),
              ]),
              _buildSubSeksi('5. Pekerjaan Pintu, Jendela & Pengunci', [
                _Baris('Balok Kayu Kelas I (Kusen)', rekap.balkKayuKelas1_m3, 'm³', 'balok_kayu_kelas1'),
                _Baris('Balok Kayu Kelas II (Daun Pintu)', rekap.balkKayuKelas2_m3, 'm³', 'balok_kayu_kelas2'),
                _Baris('Papan Kayu Kelas II (Daun Jendela)', rekap.papanKayuKelas2_m3, 'm³', 'papan_kayu_kelas2'),
                _Baris('Kaca Polos 5mm', rekap.kaca5mm_m2, 'm²', 'kaca_5mm'),
                _Baris('Kunci Pintu Silinder', rekap.kunciPintu_buah, 'buah', 'kunci_pintu'),
                _Baris('Engsel Pintu', rekap.engselPintu_buah, 'buah', 'engsel_pintu'),
                _Baris('Engsel Jendela', rekap.engselJendela_buah, 'buah', 'engsel_jendela'),
              ]),
              _buildSubSeksi('6. Pekerjaan Atap & Plafon', [
                _Baris('Besi Hollow 4×4 cm (Rangka Plafon)', rekap.hollow4x4_batang, 'batang', 'hollow_4x4'),
                _Baris('Besi Hollow 2×4 cm', rekap.hollow2x4_batang, 'batang', 'hollow_2x4'),
                _Baris('Papan Gypsum 9mm', rekap.papanGypsum_lembar, 'lembar', 'papan_gypsum'),
                _Baris('List Profil Kayu (List Plafon)', rekap.listProfilKayu_m, 'm', 'list_profil_kayu'),
                _Baris('Profil Baja Ringan C-75 (Kuda-kuda)', rekap.profilC75_m, 'm', 'profil_c75'),
                _Baris('Reng Baja Ringan', rekap.rengBaja_m, 'm', 'reng_baja'),
                _Baris('Genteng Galvalum / Metal', rekap.gentengGalvalum_m2, 'm²', 'genteng_galvalum'),
                _Baris('Nok / Bubungan Galvalum', rekap.nokGalvalum_m, 'm', 'nok_galvalum'),
                _Baris('Papan Listplank', rekap.papanListplank_m3, 'm', 'papan_listplank'),
                _Baris('Kayu Balok 5/7', rekap.kayuBalok57_m3, 'm³', 'kayu_balok_57'),
              ]),
              _buildSubSeksi('7. Pekerjaan Finishing Cat & Listrik', [
                _Baris('Plamir Tembok', rekap.plamirTembok_kg, 'kg', 'plamir_tembok'),
                _Baris('Cat Dasar Tembok', rekap.catDasarTembok_kg, 'kg', 'cat_dasar_tembok'),
                _Baris('Cat Tembok (Warna)', rekap.catTembok_kg, 'kg', 'cat_tembok'),
                _Baris('Cat Menie Kayu', rekap.catMenie_kg, 'kg', 'cat_menie'),
                _Baris('Plamir Kayu', rekap.plamirKayu_kg, 'kg', 'plamir_kayu'),
                _Baris('Cat Dasar Kayu', rekap.catDasarKayu_kg, 'kg', 'cat_dasar_kayu'),
                _Baris('Cat Kayu / Gloss', rekap.catKayu_kg, 'kg', 'cat_kayu'),
                _Baris('Lampu LED 18 Watt', rekap.lampuLed_buah, 'buah', 'lampu_led_18w'),
                _Baris('Saklar Tunggal', rekap.saklarTunggal_buah, 'buah', 'saklar_tunggal'),
                _Baris('Saklar Ganda', rekap.saklarGanda_buah, 'buah', 'saklar_ganda'),
                _Baris('Stop Kontak', rekap.stopKontak_buah, 'buah', 'stop_kontak'),
              ]),
              _buildRowSubTotal(
                  'Sub Total Biaya Material', rekap.totalBiayaMaterial),
              const SizedBox(height: 28),
            ],

            if (hasilG != null) ...[
              _buildHeaderSeksi('B. Biaya Upah Tenaga Kerja'),
              const SizedBox(height: 16),
              _buildTabelUpah(hasilG),
              _buildRowSubTotal('Sub Total Biaya Upah', hasilG.totalBiayaUpah),
              const SizedBox(height: 28),
            ],

            if (rekap != null && hasilG != null)
              _buildGrandTotal(
                  rekap.totalBiayaMaterial + hasilG.totalBiayaUpah),
          ],
        ],
      ),
    );
  }

  // info proyek
  Widget _buildInfoProyek() {
    final p = widget.project;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Detail Proyek',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoItem(Icons.home_work_outlined, 'Nama Proyek',
                  p.projectName, const Color(0xFF4CAF50)),
              const SizedBox(width: 16),
              _buildInfoItem(Icons.person_outline, 'Nama Klien', p.clientName,
                  const Color(0xFF2196F3)),
              const SizedBox(width: 16),
              _buildInfoItem(Icons.engineering_outlined, 'Nama Surveyor',
                  p.surveyorName, const Color(0xFF9C27B0)),
              const SizedBox(width: 16),
              _buildInfoItem(Icons.calendar_today_outlined, 'Tanggal Survey',
                  _formatTanggal.format(p.createdAt), const Color(0xFFFF9800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      IconData icon, String label, String nilai, Color warna) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: warna.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: warna),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                const SizedBox(height: 2),
                Text(nilai,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // header
  Widget _buildHeaderSeksi(String judul) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF3D5A4C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(judul,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  // sub+tabel
  Widget _buildSubSeksi(String judul, List<_Baris> items) {
    // Hanya tampilkan baris dengan qty > 0
    final itemAda = items.where((i) => i.qty > 0).toList();
    if (itemAda.isEmpty) return const SizedBox.shrink();

    double subTotal = 0;
    for (final item in itemAda) {
      subTotal += item.qty * (_hargaMap[item.idMaterial]?.hargaSatuan ?? 0);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub-header judul
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: Text(judul,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold)),
          ),

          // Header kolom
          _buildHeaderKolom(),

          // Baris data
          ...itemAda.asMap().entries.map((e) {
            final item = e.value;
            final hargaSatuan =
                _hargaMap[item.idMaterial]?.hargaSatuan ?? 0;
            return _buildBarisData(e.key + 1, item.nama, item.qty,
                item.satuan, hargaSatuan, item.qty * hargaSatuan);
          }),

          // Sub total seksi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Sub Total $judul:',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(width: 16),
                Text(_formatRp.format(subTotal),
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderKolom() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: const Color(0xFFE3EAE6),
      child: Row(
        children: [
          _thCell('No', flex: 1),
          _thCell('Uraian Pekerjaan / Material', flex: 5),
          _thCell('Volume', flex: 2, align: TextAlign.right),
          _thCell('Satuan', flex: 2, align: TextAlign.center),
          _thCell('Harga Satuan', flex: 3, align: TextAlign.right),
          _thCell('Jumlah Harga', flex: 3, align: TextAlign.right),
        ],
      ),
    );
  }

  Widget _thCell(String label,
      {int flex = 1, TextAlign align = TextAlign.left}) {
    return Expanded(
      flex: flex,
      child: Text(label,
          textAlign: align,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87)),
    );
  }

  Widget _buildBarisData(int no, String nama, double qty, String satuan,
      double hargaSatuan, double jumlahHarga) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[100]!))),
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Text(no.toString(),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]))),
          Expanded(
              flex: 5,
              child: Text(nama,
                  style:
                      const TextStyle(fontSize: 12, color: Colors.black87))),
          Expanded(
              flex: 2,
              child: Text(_formatQty(qty),
                  textAlign: TextAlign.right,
                  style:
                      const TextStyle(fontSize: 12, color: Colors.black87))),
          Expanded(
              flex: 2,
              child: Text(satuan,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]))),
          Expanded(
              flex: 3,
              child: Text(_formatRp.format(hargaSatuan),
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]))),
          Expanded(
              flex: 3,
              child: Text(_formatRp.format(jumlahHarga),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87))),
        ],
      ),
    );
  }

  // tabel upah
  Widget _buildTabelUpah(HasilMenuG g) {
    final upahPekerja =
        g.totalOhPekerja > 0 ? g.biayaUpahPekerja / g.totalOhPekerja : 0.0;
    final upahTukang =
        g.totalOhTukang > 0 ? g.biayaUpahTukang / g.totalOhTukang : 0.0;
    final upahMandor =
        g.totalOhMandor > 0 ? g.biayaUpahMandor / g.totalOhMandor : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFE3EAE6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                _thCell('No', flex: 1),
                _thCell('Jenis Tenaga Kerja', flex: 4),
                _thCell('Total OH', flex: 2, align: TextAlign.right),
                _thCell('Satuan', flex: 2, align: TextAlign.center),
                _thCell('Tarif / OH', flex: 3, align: TextAlign.right),
                _thCell('Jumlah Biaya', flex: 3, align: TextAlign.right),
              ],
            ),
          ),
          _buildBarisData(1, 'Pekerja', g.totalOhPekerja, 'OH', upahPekerja,
              g.biayaUpahPekerja),
          _buildBarisData(2, 'Tukang', g.totalOhTukang, 'OH', upahTukang,
              g.biayaUpahTukang),
          _buildBarisData(3, 'Mandor', g.totalOhMandor, 'OH', upahMandor,
              g.biayaUpahMandor),
        ],
      ),
    );
  }

  // footer
  Widget _buildRowSubTotal(String label, double nilai) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
          color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(label,
              style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          const SizedBox(width: 24),
          Text(_formatRp.format(nilai),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildGrandTotal(double grandTotal) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: AppStyles.primaryGreen,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('GRAND TOTAL ESTIMASI BIAYA',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5)),
          Text(_formatRp.format(grandTotal),
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ],
      ),
    );
  }

  // empty state
  Widget _buildBelumAda() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Icon(Icons.calculate_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Kalkulasi belum tersedia',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54)),
          const SizedBox(height: 8),
          Text('Surveyor belum menyelesaikan kalkulasi untuk proyek ini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        ],
      ),
    );
  }

  String _formatQty(double qty) =>
      qty == qty.toInt() ? qty.toInt().toString() : qty.toStringAsFixed(2);
}

// tabel lokal
class _Baris {
  final String nama;
  final double qty;
  final String satuan;
  final String idMaterial;

  const _Baris(this.nama, this.qty, this.satuan, this.idMaterial);
}