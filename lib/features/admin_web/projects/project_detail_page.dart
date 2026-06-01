import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/project_model.dart';
import '../../../shared/models/model_input_surveyor.dart';
import '../../../shared/models/model_hasil_perhitungan.dart';
import '../../../shared/utils/styles.dart';
import '../../../shared/utils/pdf_generator.dart';

class ProjectDetailPage extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailPage({super.key, required this.project});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  static final _formatRp = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  static final _formatTanggal = DateFormat('dd/MM/yyyy');
  static final _formatAngka = NumberFormat('#,##0.##', 'id_ID');

  // Data dari Firestore
  InputSurveyor? _input;
  HasilMenuG? _hasilG;

  // Opsi B — hasil menu A-F untuk PDF full detail
  HasilMenuA? _hasilA;
  HasilMenuB? _hasilB;
  HasilMenuC? _hasilC;
  HasilMenuD? _hasilD;
  HasilMenuE? _hasilE;
  HasilMenuF? _hasilF;

  bool _isLoading = true;
  String? _error;

  // Hasil kalkulasi volume
  _VolumePerhitungan? _vol;

  // Harga dari snapshot proyek
  late Map<String, double> _snapshotHarga;
  late Map<String, double> _snapshotKoefisien;

  @override
  void initState() {
    super.initState();
    _snapshotHarga = widget.project.snapshotHargaMaterial;
    _snapshotKoefisien = widget.project.snapshotKoefisien;
    _muatData();
  }

  Future<void> _muatData() async {
    try {
      final idProyek = widget.project.projectId;
      final refProyek = FirebaseFirestore.instance
          .collection('projects')
          .doc(idProyek);
      final refHasil = refProyek.collection('hasil_perhitungan');

      // Fetch semua data sekaligus — 8 read paralel
      final results = await Future.wait([
        refProyek.collection('inputUser').doc('data').get(), // [0]
        refHasil.doc('estimasi_upah').get(), // [1]
        refHasil.doc('menu_a').get(), // [2]
        refHasil.doc('menu_b').get(), // [3]
        refHasil.doc('menu_c').get(), // [4]
        refHasil.doc('menu_d').get(), // [5]
        refHasil.doc('menu_e').get(), // [6]
        refHasil.doc('menu_f').get(), // [7]
      ]);

      final inputDoc = results[0] as DocumentSnapshot<Map<String, dynamic>>;
      final menuGDoc = results[1] as DocumentSnapshot<Map<String, dynamic>>;
      final menuADoc = results[2] as DocumentSnapshot<Map<String, dynamic>>;
      final menuBDoc = results[3] as DocumentSnapshot<Map<String, dynamic>>;
      final menuCDoc = results[4] as DocumentSnapshot<Map<String, dynamic>>;
      final menuDDoc = results[5] as DocumentSnapshot<Map<String, dynamic>>;
      final menuEDoc = results[6] as DocumentSnapshot<Map<String, dynamic>>;
      final menuFDoc = results[7] as DocumentSnapshot<Map<String, dynamic>>;

      InputSurveyor? input;
      if (inputDoc.exists) input = InputSurveyor.dariFirestore(inputDoc);

      HasilMenuG? hasilG;
      if (menuGDoc.exists && menuGDoc.data() != null) {
        hasilG = HasilMenuG.dariFirestore(menuGDoc.data()!);
      }

      HasilMenuA? hasilA;
      if (menuADoc.exists && menuADoc.data() != null) {
        hasilA = HasilMenuA.dariFirestore(menuADoc.data()!);
      }

      HasilMenuB? hasilB;
      if (menuBDoc.exists && menuBDoc.data() != null) {
        hasilB = HasilMenuB.dariFirestore(menuBDoc.data()!);
      }

      HasilMenuC? hasilC;
      if (menuCDoc.exists && menuCDoc.data() != null) {
        hasilC = HasilMenuC.dariFirestore(menuCDoc.data()!);
      }

      HasilMenuD? hasilD;
      if (menuDDoc.exists && menuDDoc.data() != null) {
        hasilD = HasilMenuD.dariFirestore(menuDDoc.data()!);
      }

      HasilMenuE? hasilE;
      if (menuEDoc.exists && menuEDoc.data() != null) {
        hasilE = HasilMenuE.dariFirestore(menuEDoc.data()!);
      }

      HasilMenuF? hasilF;
      if (menuFDoc.exists && menuFDoc.data() != null) {
        hasilF = HasilMenuF.dariFirestore(menuFDoc.data()!);
      }

      _VolumePerhitungan? vol;
      if (input != null) vol = _VolumePerhitungan.dariInput(input);

      setState(() {
        _input = input;
        _hasilG = hasilG;
        _hasilA = hasilA;
        _hasilB = hasilB;
        _hasilC = hasilC;
        _hasilD = hasilD;
        _hasilE = hasilE;
        _hasilF = hasilF;
        _vol = vol;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Ambil harga dari snapshot
  double _hp(String id) => _snapshotHarga[id] ?? 0;

  // Ambil koefisien dari snapshot
  double _k(String key) => _snapshotKoefisien[key] ?? 0.0;

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
                      child: Text(
                        'Gagal memuat data: $_error',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  )
                : _buildKonten(),
          ),
        ],
      ),
    );
  }

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
                Text(
                  'Kembali ke daftar Proyek',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          const Spacer(),

          // Tombol cetak PDF
          ElevatedButton.icon(
            onPressed: (_hasilG == null || _vol == null)
                ? null
                : () async {
                    // Hitung total material biar akurat 100% persis kayak di layar
                    final subA = _hitungSubTotalA(_vol!);
                    final subB = _hitungSubTotalB(_vol!);
                    final subC = _hitungSubTotalC(_vol!);
                    final subD = _hitungSubTotalD(_vol!);
                    final subE = _hitungSubTotalE(_vol!);
                    final subF = _hitungSubTotalF(_vol!);
                    final totalMatAkurat =
                        subA + subB + subC + subD + subE + subF;

                    final a = HasilMenuA(
                      volBersih: _vol!.volBersih,
                      volBouwplank: _vol!.volBouwplank,
                      volGalianMenerus: _vol!.volGalianMenerus,
                      volPasirMenerus: _vol!.volPasirMenerus,
                      volAanstampMenerus: _vol!.volAanstampMenerus,
                      volBatuKali: _vol!.volBatuKali,
                      volGalianTapak: _vol!.volGalianTapak,
                      volPasirTapak: _vol!.volPasirTapak,
                      volAanstampTapak: _vol!.volAanstampTapak,
                      volBetonTapak: _vol!.volBetonTapak,
                      volUrugMenerus: _vol!.volUrugMenerus,
                      volUrugTapak: _vol!.volUrugTapak,
                      dihitungPada: DateTime.now(),
                    );
                    final b = HasilMenuB(
                      volSloof: _vol!.volSloof,
                      volKolom: _vol!.volKolom,
                      volRingBalok: _vol!.volRingBalok,
                      volDinding: _vol!.volDinding,
                      volPlester: _vol!.volPlester,
                      volAcian: _vol!.volAcian,
                      dihitungPada: DateTime.now(),
                    );
                    final c = HasilMenuC(
                      luasLantai: _vol!.luasLantai,
                      volTimbunan: _vol!.volTimbunan,
                      volPasirLantai: _vol!.volPasirLantai,
                      volCorLantai: _vol!.volCorLantai,
                      volKeramik: _vol!.volKeramik,
                      dihitungPada: DateTime.now(),
                    );
                    final d = HasilMenuD(
                      volKusenPintu: _vol!.volKusenPintu,
                      volDaunPintu: _vol!.volDaunPintu,
                      volKusenVentilasi: _vol!.volKusenVentilasi,
                      jmlKunci: _vol!.jmlKunci,
                      jmlEngselPintu: _vol!.jmlEngselPintu,
                      volKusenJendela: _vol!.volKusenJendela,
                      volDaunJendela: _vol!.volDaunJendela,
                      volKaca: _vol!.volKaca,
                      jmlEngselJendela: _vol!.jmlEngselJendela,
                      volKusenTotal:
                          _vol!.volKusenPintu +
                          _vol!.volKusenVentilasi +
                          _vol!.volKusenJendela,
                      dihitungPada: DateTime.now(),
                    );
                    final e = HasilMenuE(
                      volPlafon: _vol!.volPlafon,
                      volListPlafon: _vol!.volListPlafon,
                      volRangkaAtap: _vol!.volRangkaAtap,
                      volGenteng: _vol!.volGenteng,
                      volListplank: _vol!.volListplank,
                      volNok: _vol!.volNok,
                      dihitungPada: DateTime.now(),
                    );
                    final f = HasilMenuF(
                      volCatTembok: _vol!.volCatTembok,
                      volCatPlafon: _vol!.volCatPlafon,
                      volCatKayu: _vol!.volCatKayu,
                      volLampu: _vol!.jmlLampu,
                      volSaklar1: _vol!.jmlSaklar1,
                      volSaklar2: _vol!.jmlSaklar2,
                      volStopKontak: _vol!.jmlStopKontak,
                      dihitungPada: DateTime.now(),
                    );

                    await generateRABPdf(
                      data: DataPdfRAB(
                        namaProyek: widget.project.projectName,
                        namaKlien: widget.project.clientName,
                        namaSurveyor: widget.project.surveyorName,

                        // tanggal dokumen dicetak
                        tanggalDibuat: DateTime.now(),

                        // FIX TOTAL: Pake total dari layar!
                        overrideTotalMaterial: totalMatAkurat,

                        menuA: a,
                        menuB: b,
                        menuC: c,
                        menuD: d,
                        menuE: e,
                        menuF: f,
                        menuG: _hasilG,
                        snapshotHarga: _snapshotHarga,
                        snapshotKoefisien: _snapshotKoefisien,
                      ),
                    );
                  },
            icon: const Icon(
              Icons.picture_as_pdf_outlined,
              size: 15,
              color: Colors.white,
            ),
            label: const Text(
              'Unduh Laporan PDF',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.primaryGreen,
              disabledBackgroundColor: Colors.grey[300],
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(width: 12),

          if (widget.project.tanggalSnapshotDiambil != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 13, color: Colors.green[700]),
                  const SizedBox(width: 5),
                  Text(
                    'Referensi Harga Terkunci Per ${_formatTanggal.format(widget.project.tanggalSnapshotDiambil!)}',
                    style: TextStyle(fontSize: 11, color: Colors.green[700]),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKonten() {
    final vol = _vol;
    final hasilG = _hasilG;
    final snapshotTersedia = _snapshotHarga.isNotEmpty;

    if (vol == null || !snapshotTersedia) {
      return _buildBelumAda();
    }

    // Hitung sub-total per kelompok pekerjaan
    final subA = _hitungSubTotalA(vol);
    final subB = _hitungSubTotalB(vol);
    final subC = _hitungSubTotalC(vol);
    final subD = _hitungSubTotalD(vol);
    final subE = _hitungSubTotalE(vol);
    final subF = _hitungSubTotalF(vol);
    final totalMaterial = subA + subB + subC + subD + subE + subF;
    final totalUpah = hasilG?.totalBiayaUpah ?? 0;
    final grandTotal = totalMaterial + totalUpah;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoProyek(),
          const SizedBox(height: 28),

          // Judul dokumen RAB
          Center(
            child: Column(
              children: [
                const Text(
                  'ESTIMASI ANGGARAN BIAYA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'QUICK COUNT ESTIMASI — ${widget.project.projectName.toUpperCase()}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Klien: ${widget.project.clientName}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Catatan snapshot
          if (_snapshotHarga.isEmpty)
            _buildWarningBanner(
              'Snapshot harga belum tersedia. Mohon selesaikan kalkulasi pada aplikasi mobile terlebih dahulu.',
            ),

          // A. Persiapan Tanah & Pondasi
          _buildSeksiRAB(
            kode: 'A',
            judul: 'PEKERJAAN PERSIAPAN, TANAH & PONDASI',
            items: _itemsMenuA(vol),
            subTotal: subA,
          ),

          // B. Struktur & Dinding
          _buildSeksiRAB(
            kode: 'B',
            judul: 'PEKERJAAN STRUKTUR & DINDING',
            items: _itemsMenuB(vol),
            subTotal: subB,
          ),

          // C. Lantai & Timbunan
          _buildSeksiRAB(
            kode: 'C',
            judul: 'PEKERJAAN LANTAI & TIMBUNAN',
            items: _itemsMenuC(vol),
            subTotal: subC,
          ),

          // D. Pintu, Jendela & Pengunci
          _buildSeksiRAB(
            kode: 'D',
            judul: 'PEKERJAAN PINTU, JENDELA & PENGUNCI',
            items: _itemsMenuD(vol),
            subTotal: subD,
          ),

          // E. Atap & Plafon
          _buildSeksiRAB(
            kode: 'E',
            judul: 'PEKERJAAN ATAP & PLAFON',
            items: _itemsMenuE(vol),
            subTotal: subE,
          ),

          // F. Finishing Cat & Listrik
          _buildSeksiRAB(
            kode: 'F',
            judul: 'PEKERJAAN FINISHING, CAT & INSTALASI LISTRIK',
            items: _itemsMenuF(vol),
            subTotal: subF,
          ),

          _buildRowSubTotal('Total Biaya Material', totalMaterial),
          const SizedBox(height: 24),

          // G. Upah Tenaga Kerja
          if (hasilG != null) ...[
            _buildSeksiUpah(hasilG),
            _buildRowSubTotal('Total Biaya Upah Tenaga Kerja', totalUpah),
            const SizedBox(height: 24),
          ],

          _buildGrandTotal(grandTotal),
          const SizedBox(height: 16),
          _buildCatatanKaki(),
        ],
      ),
    );
  }

  // Item rows per menu

  List<_BarisRAB> _itemsMenuA(_VolumePerhitungan v) => [
    _BarisRAB('Pembersihan Lapangan', v.volBersih, 'm²', 0, override: 0),
    _BarisRAB(
      'Pemasangan Bouwplank',
      v.volBouwplank,
      'm\'',
      _hp('kayu_balok_57') * _k('mat_kayu_balok57') +
          _hp('papan_bekisting') * _k('mat_papan_bekisting_bouwplank'),
    ),
    _BarisRAB(
      'Galian Tanah Pondasi Menerus',
      v.volGalianMenerus,
      'm³',
      0,
      override: 0,
    ),
    _BarisRAB(
      'Galian Tanah Pondasi Tapak',
      v.volGalianTapak,
      'm³',
      0,
      override: 0,
    ),
    _BarisRAB(
      'Urugan Pasir Pondasi Menerus',
      v.volPasirMenerus,
      'm³',
      _hp('pasir_urug') * _k('mat_pasir_urug'),
    ),
    _BarisRAB(
      'Urugan Pasir Pondasi Tapak',
      v.volPasirTapak,
      'm³',
      _hp('pasir_urug') * _k('mat_pasir_urug'),
    ),
    _BarisRAB(
      'Aanstamping / Batu Kosong (Menerus)',
      v.volAanstampMenerus,
      'm³',
      _hp('pasir_urug') * _k('mat_aanstamp_pasir_urug'),
    ),
    _BarisRAB(
      'Aanstamping / Batu Kosong (Tapak)',
      v.volAanstampTapak,
      'm³',
      _hp('pasir_urug') * _k('mat_aanstamp_pasir_urug'),
    ),
    _BarisRAB(
      'Pasangan Batu Kali 1:4 (termasuk Aanstamping)',
      v.volAanstampMenerus + v.volAanstampTapak + v.volBatuKali,
      'm³',
      _hp('batu_kali') * _k('mat_batu_kali'),
    ),
    _BarisRAB(
      'Pasangan Batu Kali — Semen PC',
      v.volBatuKali,
      'm³',
      _hp('semen_pc') * _k('mat_semen_batu_kali') +
          _hp('pasir_pasang') * _k('mat_pasir_pasang_batu_kali'),
    ),
    _BarisRAB(
      'Beton Pondasi Tapak K-175',
      v.volBetonTapak,
      'm³',
      _hp('kerikil') * _k('mat_kerikil_beton') +
          _hp('pasir_beton') * _k('mat_pasir_beton') +
          _hp('semen_pc') * _k('mat_semen_beton'),
    ),
    _BarisRAB(
      'Urugan Kembali Galian Menerus',
      v.volUrugMenerus,
      'm³',
      0,
      override: 0,
    ),
    _BarisRAB(
      'Urugan Kembali Galian Tapak',
      v.volUrugTapak,
      'm³',
      0,
      override: 0,
    ),
  ];

  List<_BarisRAB> _itemsMenuB(_VolumePerhitungan v) => [
    _BarisRAB(
      'Sloof Beton Bertulang 15/20',
      v.volSloof,
      'm³',
      _hp('besi_polos') * _k('mat_besi_sloof') +
          _hp('kerikil') * _k('mat_kerikil_beton') +
          _hp('pasir_beton') * _k('mat_pasir_beton') +
          _hp('semen_pc') * _k('mat_semen_beton') +
          _hp('papan_bekisting') * _k('mat_papan_bekisting_sloof'),
    ),
    _BarisRAB(
      'Kolom Praktis 13/13',
      v.volKolom,
      'm³',
      _hp('besi_polos') * _k('mat_besi_kolom') +
          _hp('kerikil') * _k('mat_kerikil_beton') +
          _hp('pasir_beton') * _k('mat_pasir_beton') +
          _hp('semen_pc') * _k('mat_semen_beton') +
          _hp('papan_bekisting') * _k('mat_papan_bekisting_kolom'),
    ),
    _BarisRAB(
      'Ring Balok 15/15',
      v.volRingBalok,
      'm³',
      _hp('besi_polos') * _k('mat_besi_ring_balok') +
          _hp('kerikil') * _k('mat_kerikil_beton') +
          _hp('pasir_beton') * _k('mat_pasir_beton') +
          _hp('semen_pc') * _k('mat_semen_beton') +
          _hp('papan_bekisting') * _k('mat_papan_bekisting_ring'),
    ),
    _BarisRAB(
      'Pasangan Dinding Bata 1:4',
      v.volDinding,
      'm²',
      _hp('bata_merah') * _k('mat_bata_merah') +
          _hp('semen_pc') * _k('mat_semen_dinding') +
          _hp('pasir_pasang') * _k('mat_pasir_pasang_dinding'),
    ),
    _BarisRAB(
      'Plesteran Dinding 1:4',
      v.volPlester,
      'm²',
      _hp('semen_pc') * _k('mat_semen_plester') +
          _hp('pasir_pasang') * _k('mat_pasir_pasang_plester'),
    ),
    _BarisRAB(
      'Acian Dinding',
      v.volAcian,
      'm²',
      _hp('semen_pc') * _k('mat_semen_acian'),
    ),
  ];

  List<_BarisRAB> _itemsMenuC(_VolumePerhitungan v) => [
    _BarisRAB(
      'Timbunan Tanah Bawah Lantai',
      v.volTimbunan,
      'm³',
      _hp('tanah_timbun') * _k('mat_tanah_timbun'),
    ),
    _BarisRAB(
      'Urugan Pasir Bawah Lantai',
      v.volPasirLantai,
      'm³',
      _hp('pasir_urug') * _k('mat_pasir_urug'),
    ),
    _BarisRAB(
      'Cor Lantai Beton Tumbuk',
      v.volCorLantai,
      'm³',
      _hp('kerikil') * _k('mat_kerikil_lantai') +
          _hp('pasir_beton') * _k('mat_pasir_beton_lantai') +
          _hp('semen_pc') * _k('mat_semen_lantai'),
    ),
    _BarisRAB(
      'Pasangan Keramik Lantai 40×40',
      v.volKeramik,
      'm²',
      _hp('keramik_40x40') * _k('mat_keramik') +
          _hp('semen_pc') * _k('mat_semen_keramik') +
          _hp('pasir_pasang') * _k('mat_pasir_pasang_keramik'),
    ),
  ];

  List<_BarisRAB> _itemsMenuD(_VolumePerhitungan v) => [
    _BarisRAB(
      'Kusen Pintu + Ventilasi (Kayu Kls I)',
      v.volKusenPintu + v.volKusenVentilasi,
      'm³',
      _hp('balok_kayu_kelas1') * _k('mat_balk_kayu_kelas1'),
    ),
    _BarisRAB(
      'Daun Pintu (Kayu Kls II)',
      v.volDaunPintu,
      'm²',
      _hp('balok_kayu_kelas2') * _k('mat_balk_kayu_kelas2'),
    ),
    _BarisRAB(
      'Kusen Jendela (Kayu Kls I)',
      v.volKusenJendela,
      'm³',
      _hp('balok_kayu_kelas1') * _k('mat_balk_kayu_kelas1'),
    ),
    _BarisRAB(
      'Daun Jendela (Kayu Kls II)',
      v.volDaunJendela,
      'm²',
      _hp('papan_kayu_kelas2') * _k('mat_papan_kayu_kelas2'),
    ),
    _BarisRAB(
      'Kaca Polos 5mm',
      v.volKaca,
      'm²',
      _hp('kaca_5mm') * _k('mat_kaca_5mm'),
    ),
    _BarisRAB(
      'Kunci Pintu Silinder',
      v.jmlKunci.toDouble(),
      'buah',
      _hp('kunci_pintu'),
    ),
    _BarisRAB(
      'Engsel Pintu',
      v.jmlEngselPintu.toDouble(),
      'buah',
      _hp('engsel_pintu'),
    ),
    _BarisRAB(
      'Engsel Jendela',
      v.jmlEngselJendela.toDouble(),
      'buah',
      _hp('engsel_jendela'),
    ),
  ];

  List<_BarisRAB> _itemsMenuE(_VolumePerhitungan v) => [
    _BarisRAB(
      'Rangka Plafon Hollow 4×4',
      v.volPlafon,
      'm²',
      _hp('hollow_4x4') * _k('mat_hollow_4x4'),
    ),
    _BarisRAB(
      'Rangka Plafon Hollow 2×4',
      v.volPlafon,
      'm²',
      _hp('hollow_2x4') * _k('mat_hollow_2x4'),
    ),
    _BarisRAB(
      'Papan Gypsum 9mm',
      v.volPlafon,
      'm²',
      _hp('papan_gypsum') * _k('mat_papan_gypsum'),
    ),
    _BarisRAB(
      'List Profil Kayu Plafon',
      v.volListPlafon,
      'm\'',
      _hp('list_profil_kayu') * _k('mat_list_profil_kayu'),
    ),
    _BarisRAB(
      'Rangka Atap Baja Ringan C-75',
      v.volRangkaAtap,
      'm²',
      _hp('profil_c75') * _k('mat_profil_c75') +
          _hp('reng_baja') * _k('mat_reng_baja'),
    ),
    _BarisRAB(
      'Penutup Atap Genteng Galvalum',
      v.volGenteng,
      'm²',
      _hp('genteng_galvalum') * _k('mat_genteng_galvalum'),
    ),
    _BarisRAB(
      'Nok / Bubungan Galvalum',
      v.volNok,
      'm\'',
      _hp('nok_galvalum') * _k('mat_nok_galvalum'),
    ),
    _BarisRAB(
      'Papan Listplank',
      v.volListplank,
      'm\'',
      _hp('papan_listplank') * _k('mat_papan_listplank'),
    ),
  ];

  List<_BarisRAB> _itemsMenuF(_VolumePerhitungan v) => [
    _BarisRAB(
      'Plamir Tembok',
      v.volCatTembokPlafon,
      'm²',
      _hp('plamir_tembok') * _k('mat_plamir_tembok'),
    ),
    _BarisRAB(
      'Cat Dasar Tembok',
      v.volCatTembokPlafon,
      'm²',
      _hp('cat_dasar_tembok') * _k('mat_cat_dasar_tembok'),
    ),
    _BarisRAB(
      'Cat Tembok & Plafon',
      v.volCatTembokPlafon,
      'm²',
      _hp('cat_tembok') * _k('mat_cat_tembok'),
    ),
    _BarisRAB(
      'Cat Menie Kayu',
      v.volCatKayu,
      'm²',
      _hp('cat_menie') * _k('mat_cat_menie'),
    ),
    _BarisRAB(
      'Plamir Kayu',
      v.volCatKayu,
      'm²',
      _hp('plamir_kayu') * _k('mat_plamir_kayu'),
    ),
    _BarisRAB(
      'Cat Dasar Kayu',
      v.volCatKayu,
      'm²',
      _hp('cat_dasar_kayu') * _k('mat_cat_dasar_kayu'),
    ),
    _BarisRAB(
      'Cat Kayu / Gloss',
      v.volCatKayu,
      'm²',
      _hp('cat_kayu') * _k('mat_cat_kayu'),
    ),
    _BarisRAB(
      'Lampu LED 18 Watt',
      v.jmlLampu.toDouble(),
      'buah',
      _hp('lampu_led_18w'),
    ),
    _BarisRAB(
      'Saklar Tunggal',
      v.jmlSaklar1.toDouble(),
      'buah',
      _hp('saklar_tunggal'),
    ),
    _BarisRAB(
      'Saklar Ganda',
      v.jmlSaklar2.toDouble(),
      'buah',
      _hp('saklar_ganda'),
    ),
    _BarisRAB(
      'Stop Kontak',
      v.jmlStopKontak.toDouble(),
      'buah',
      _hp('stop_kontak'),
    ),
  ];

  // Sub-total per bagian
  double _hitungSubTotalA(_VolumePerhitungan v) {
    double t = 0;
    for (final b in _itemsMenuA(v)) {
      t += b.volume * b.hargaSatuan;
    }
    return t;
  }

  double _hitungSubTotalB(_VolumePerhitungan v) {
    double t = 0;
    for (final b in _itemsMenuB(v)) {
      t += b.volume * b.hargaSatuan;
    }
    return t;
  }

  double _hitungSubTotalC(_VolumePerhitungan v) {
    double t = 0;
    for (final b in _itemsMenuC(v)) {
      t += b.volume * b.hargaSatuan;
    }
    return t;
  }

  double _hitungSubTotalD(_VolumePerhitungan v) {
    double t = 0;
    for (final b in _itemsMenuD(v)) {
      t += b.volume * b.hargaSatuan;
    }
    return t;
  }

  double _hitungSubTotalE(_VolumePerhitungan v) {
    double t = 0;
    for (final b in _itemsMenuE(v)) {
      t += b.volume * b.hargaSatuan;
    }
    return t;
  }

  double _hitungSubTotalF(_VolumePerhitungan v) {
    double t = 0;
    for (final b in _itemsMenuF(v)) {
      t += b.volume * b.hargaSatuan;
    }
    return t;
  }

  //UI Widgets
  Widget _buildSeksiRAB({
    required String kode,
    required String judul,
    required List<_BarisRAB> items,
    required double subTotal,
  }) {
    final itemAda = items.where((i) => i.volume > 0).toList();
    if (itemAda.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF3D5A4C),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Text(
              '$kode.  $judul',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
          _buildHeaderKolom(),
          ...itemAda.asMap().entries.map((e) {
            final item = e.value;
            return _buildBarisData(
              e.key + 1,
              item.nama,
              item.volume,
              item.satuan,
              item.hargaSatuan,
              item.volume * item.hargaSatuan,
            );
          }),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Sub Total $kode:',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Text(
                  _formatRp.format(subTotal),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
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
          _thCell('No.', flex: 1),
          _thCell('Uraian Pekerjaan', flex: 5),
          _thCell('Volume', flex: 2, align: TextAlign.right),
          _thCell('Sat.', flex: 2, align: TextAlign.center),
          _thCell('Harga Satuan', flex: 3, align: TextAlign.right),
          _thCell('Jumlah Harga', flex: 3, align: TextAlign.right),
        ],
      ),
    );
  }

  Widget _buildBarisData(
    int no,
    String nama,
    double qty,
    String satuan,
    double hargaSatuan,
    double jumlahHarga,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              no.toString(),
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              nama,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatAngka.format(qty),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              satuan,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              hargaSatuan > 0 ? _formatRp.format(hargaSatuan) : '-',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              jumlahHarga > 0 ? _formatRp.format(jumlahHarga) : '-',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeksiUpah(HasilMenuG g) {
    final upahPekerja = g.totalOhPekerja > 0
        ? g.biayaUpahPekerja / g.totalOhPekerja
        : 0.0;
    final upahTukang = g.totalOhTukang > 0
        ? g.biayaUpahTukang / g.totalOhTukang
        : 0.0;
    final upahMandor = g.totalOhMandor > 0
        ? g.biayaUpahMandor / g.totalOhMandor
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF3D5A4C),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: const Text(
              'G.  BIAYA UPAH TENAGA KERJA',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            color: const Color(0xFFE3EAE6),
            child: Row(
              children: [
                _thCell('No.', flex: 1),
                _thCell('Jenis Tenaga Kerja', flex: 5),
                _thCell('Total OH', flex: 2, align: TextAlign.right),
                _thCell('Sat.', flex: 2, align: TextAlign.center),
                _thCell('Upah per OH', flex: 3, align: TextAlign.right),
                _thCell('Total Upah', flex: 3, align: TextAlign.right),
              ],
            ),
          ),
          _buildBarisData(
            1,
            'Pekerja',
            g.totalOhPekerja,
            'OH',
            upahPekerja,
            g.biayaUpahPekerja,
          ),
          _buildBarisData(
            2,
            'Tukang',
            g.totalOhTukang,
            'OH',
            upahTukang,
            g.biayaUpahTukang,
          ),
          _buildBarisData(
            3,
            'Mandor',
            g.totalOhMandor,
            'OH',
            upahMandor,
            g.biayaUpahMandor,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Sub Total G:',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Text(
                  _formatRp.format(g.totalBiayaUpah),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowSubTotal(String label, double nilai) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          const SizedBox(width: 24),
          Text(
            _formatRp.format(nilai),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
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
          const Text(
            'TOTAL AKHIR ESTIMASI BIAYA',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
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
    );
  }

  Widget _buildCatatanKaki() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Catatan:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.amber[900],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '• Dokumen ini merupakan Estimasi Cepat (Quick Count), bukan RAB detail.\n'
            '• Harga satuan menggunakan referensi data yang telah dikunci pada saat pengambilan snapshot proyek.\n'
            '• Analisa koefisien material mengacu pada Standar Nasional Indonesia (SNI) yang berlaku.\n'
            '• Untuk kebutuhan RAB teknis secara formal, diperlukan survei lapangan mendalam dan analisa harga satuan wilayah setempat.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.amber[800],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanner(String pesan) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange[700],
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              pesan,
              style: TextStyle(fontSize: 12, color: Colors.orange[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoProyek() {
    final p = widget.project;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Umum Proyek',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoItem(
                Icons.home_work_outlined,
                'Judul Proyek',
                p.projectName,
                const Color(0xFF4CAF50),
              ),
              const SizedBox(width: 16),
              _buildInfoItem(
                Icons.person_outline,
                'Nama Klien',
                p.clientName,
                const Color(0xFF2196F3),
              ),
              const SizedBox(width: 16),
              _buildInfoItem(
                Icons.engineering_outlined,
                'Surveyor',
                p.surveyorName,
                const Color(0xFF9C27B0),
              ),
              const SizedBox(width: 16),
              _buildInfoItem(
                Icons.calendar_today_outlined,
                'Tanggal Survey Lapangan',
                _formatTanggal.format(p.createdAt),
                const Color(0xFFFF9800),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String nilai,
    Color warna,
  ) {
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
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                const SizedBox(height: 2),
                Text(
                  nilai,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
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

  Widget _buildBelumAda() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.calculate_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Data Kalkulasi Belum Tersedia',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Surveyor belum melakukan finalisasi kalkulasi pada sistem.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _thCell(
    String label, {
    int flex = 1,
    TextAlign align = TextAlign.left,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: align,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}

// kalkulasi volume identik dengan LayananPerhitungan

class _VolumePerhitungan {
  final double volBersih, volBouwplank, volGalianMenerus, volPasirMenerus;
  final double volAanstampMenerus, volBatuKali, volGalianTapak, volPasirTapak;
  final double volAanstampTapak, volBetonTapak, volUrugMenerus, volUrugTapak;
  final double volSloof,
      volKolom,
      volRingBalok,
      volDinding,
      volPlester,
      volAcian;
  final double luasLantai,
      volTimbunan,
      volPasirLantai,
      volCorLantai,
      volKeramik;
  final double volKusenPintu, volDaunPintu, volKusenVentilasi;
  final int jmlKunci, jmlEngselPintu;
  final double volKusenJendela, volDaunJendela, volKaca;
  final int jmlEngselJendela;
  final double volPlafon,
      volListPlafon,
      volRangkaAtap,
      volGenteng,
      volListplank,
      volNok;
  final double volCatTembok, volCatPlafon, volCatKayu, volCatTembokPlafon;
  final int jmlLampu, jmlSaklar1, jmlSaklar2, jmlStopKontak;

  const _VolumePerhitungan({
    required this.volBersih,
    required this.volBouwplank,
    required this.volGalianMenerus,
    required this.volPasirMenerus,
    required this.volAanstampMenerus,
    required this.volBatuKali,
    required this.volGalianTapak,
    required this.volPasirTapak,
    required this.volAanstampTapak,
    required this.volBetonTapak,
    required this.volUrugMenerus,
    required this.volUrugTapak,
    required this.volSloof,
    required this.volKolom,
    required this.volRingBalok,
    required this.volDinding,
    required this.volPlester,
    required this.volAcian,
    required this.luasLantai,
    required this.volTimbunan,
    required this.volPasirLantai,
    required this.volCorLantai,
    required this.volKeramik,
    required this.volKusenPintu,
    required this.volDaunPintu,
    required this.volKusenVentilasi,
    required this.jmlKunci,
    required this.jmlEngselPintu,
    required this.volKusenJendela,
    required this.volDaunJendela,
    required this.volKaca,
    required this.jmlEngselJendela,
    required this.volPlafon,
    required this.volListPlafon,
    required this.volRangkaAtap,
    required this.volGenteng,
    required this.volListplank,
    required this.volNok,
    required this.volCatTembok,
    required this.volCatPlafon,
    required this.volCatKayu,
    required this.volCatTembokPlafon,
    required this.jmlLampu,
    required this.jmlSaklar1,
    required this.jmlSaklar2,
    required this.jmlStopKontak,
  });

  /// Rumus identik dengan LayananPerhitungan di Mobile
  factory _VolumePerhitungan.dariInput(InputSurveyor i) {
    final volBersih = i.pTanah * i.lTanah;
    final volBouwplank = (i.pTanah + i.lTanah) * 2;
    final volGalianMenerus = i.pPondasi * 0.80 * 0.85;
    final volPasirMenerus = i.pPondasi * 1.00 * 0.05;
    final volAanstampMenerus = i.pPondasi * 1.00 * 0.10;
    final volBatuKali = i.pPondasi * 0.48;
    final volGalianTapak = i.jmlTitikTapak * 1.5;
    final volPasirTapak = i.jmlTitikTapak * 0.072;
    final volAanstampTapak = i.jmlTitikTapak * 0.144;
    final volBetonTapak = i.jmlTitikTapak * 0.3335;
    final volUrugMenerus = volGalianMenerus * 0.25;
    final volUrugTapak = volGalianTapak * 0.75;
    final volSloof = i.pDinding * 0.15 * 0.20;
    final volKolom = i.jmlKolom * 0.13 * 0.13 * 3.60;
    final volRingBalok = i.pDinding * 0.15 * 0.15;
    final volDinding = (i.pDinding * 3.60) * 0.825;
    final volPlester = volDinding * 2;
    final volAcian = volDinding * 2;
    final luasLantai = i.pBangunan * i.lBangunan;
    final volTimbunan = luasLantai * 0.40;
    final volPasirLantai = luasLantai * 0.05;
    final volCorLantai = luasLantai * 0.05;
    final volKeramik = luasLantai;
    final volKusenPintu = i.jmlPintu * (5.36 * 0.13 * 0.06);
    final volDaunPintu = i.jmlPintu * (2.10 * 0.80);
    final volKusenVentilasi = i.jmlPintu * (3.08 * 0.13 * 0.06);
    final jmlKunci = i.jmlPintu * 1;
    final jmlEngselPintu = i.jmlPintu * 3;
    final volKusenJendela = i.jmlJendela * (5.40 * 0.13 * 0.06);
    final volDaunJendela = i.jmlJendela * (0.80 * 0.60);
    final volKaca = i.jmlJendela * (0.68 * 0.46);
    final jmlEngselJendela = i.jmlJendela * 2;
    final volPlafon = i.pBangunan * i.lBangunan;
    final volListPlafon = 2 * (i.pBangunan + i.lBangunan);
    final volRangkaAtap = ((i.pBangunan + 2) * (i.lBangunan + 2)) / 0.866;
    final volGenteng = volRangkaAtap;
    final volListplank = 2 * ((i.pBangunan + 2) + (i.lBangunan + 2));
    final volNok = i.pBangunan + 2;
    final volCatTembok = volDinding;
    final volCatPlafon = volPlafon;
    final volCatKayu = volDaunPintu + volDaunJendela;
    final volCatTembokPlafon = volCatTembok + volCatPlafon;

    return _VolumePerhitungan(
      volBersih: volBersih,
      volBouwplank: volBouwplank,
      volGalianMenerus: volGalianMenerus,
      volPasirMenerus: volPasirMenerus,
      volAanstampMenerus: volAanstampMenerus,
      volBatuKali: volBatuKali,
      volGalianTapak: volGalianTapak,
      volPasirTapak: volPasirTapak,
      volAanstampTapak: volAanstampTapak,
      volBetonTapak: volBetonTapak,
      volUrugMenerus: volUrugMenerus,
      volUrugTapak: volUrugTapak,
      volSloof: volSloof,
      volKolom: volKolom,
      volRingBalok: volRingBalok,
      volDinding: volDinding,
      volPlester: volPlester,
      volAcian: volAcian,
      luasLantai: luasLantai,
      volTimbunan: volTimbunan,
      volPasirLantai: volPasirLantai,
      volCorLantai: volCorLantai,
      volKeramik: volKeramik,
      volKusenPintu: volKusenPintu,
      volDaunPintu: volDaunPintu,
      volKusenVentilasi: volKusenVentilasi,
      jmlKunci: jmlKunci,
      jmlEngselPintu: jmlEngselPintu,
      volKusenJendela: volKusenJendela,
      volDaunJendela: volDaunJendela,
      volKaca: volKaca,
      jmlEngselJendela: jmlEngselJendela,
      volPlafon: volPlafon,
      volListPlafon: volListPlafon,
      volRangkaAtap: volRangkaAtap,
      volGenteng: volGenteng,
      volListplank: volListplank,
      volNok: volNok,
      volCatTembok: volCatTembok,
      volCatPlafon: volCatPlafon,
      volCatKayu: volCatKayu,
      volCatTembokPlafon: volCatTembokPlafon,
      jmlLampu: i.jmlLampu,
      jmlSaklar1: i.jmlSaklar1,
      jmlSaklar2: i.jmlSaklar2,
      jmlStopKontak: i.jmlStopKontak,
    );
  }
}

// Baris RAB
class _BarisRAB {
  final String nama;
  final double volume;
  final String satuan;
  final double hargaSatuan;

  const _BarisRAB(
    this.nama,
    this.volume,
    this.satuan,
    double hargaSatuan, {
    double? override,
  }) : hargaSatuan = override ?? hargaSatuan;
}
